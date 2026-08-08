package com.bodegazo.ferreteria.serviceImpl;

import com.bodegazo.ferreteria.dto.EntradaFormDTO;
import com.bodegazo.ferreteria.dto.InventarioResumenDTO;
import com.bodegazo.ferreteria.dto.MovimientoResumenDTO;
import com.bodegazo.ferreteria.dto.SalidaFormDTO;
import com.bodegazo.ferreteria.entity.Entrada;
import com.bodegazo.ferreteria.entity.Inventario;
import com.bodegazo.ferreteria.entity.MovimientoInventario;
import com.bodegazo.ferreteria.entity.Producto;
import com.bodegazo.ferreteria.entity.Proveedor;
import com.bodegazo.ferreteria.entity.Salida;
import com.bodegazo.ferreteria.entity.Usuario;
import com.bodegazo.ferreteria.exception.RecursoNoEncontradoException;
import com.bodegazo.ferreteria.repository.EntradaRepository;
import com.bodegazo.ferreteria.repository.InventarioRepository;
import com.bodegazo.ferreteria.repository.MovimientoInventarioRepository;
import com.bodegazo.ferreteria.repository.ProductoRepository;
import com.bodegazo.ferreteria.repository.ProveedorRepository;
import com.bodegazo.ferreteria.repository.SalidaRepository;
import com.bodegazo.ferreteria.repository.UsuarioRepository;
import com.bodegazo.ferreteria.service.InventarioService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;

/**
 * Lógica de negocio del inventario. Las entradas (compras) suben el
 * stock; las salidas manuales (ajuste, daño, devolución — NO venta,
 * eso ya lo hace CotizacionServiceImpl.aceptar automáticamente) lo
 * bajan. Cada movimiento queda registrado en "movimientos_inventario"
 * para tener trazabilidad completa.
 */
@Service
@Transactional(readOnly = true)
public class InventarioServiceImpl implements InventarioService {

    private final ProductoRepository productoRepository;
    private final InventarioRepository inventarioRepository;
    private final ProveedorRepository proveedorRepository;
    private final UsuarioRepository usuarioRepository;
    private final EntradaRepository entradaRepository;
    private final SalidaRepository salidaRepository;
    private final MovimientoInventarioRepository movimientoInventarioRepository;

    public InventarioServiceImpl(ProductoRepository productoRepository,
                                  InventarioRepository inventarioRepository,
                                  ProveedorRepository proveedorRepository,
                                  UsuarioRepository usuarioRepository,
                                  EntradaRepository entradaRepository,
                                  SalidaRepository salidaRepository,
                                  MovimientoInventarioRepository movimientoInventarioRepository) {
        this.productoRepository = productoRepository;
        this.inventarioRepository = inventarioRepository;
        this.proveedorRepository = proveedorRepository;
        this.usuarioRepository = usuarioRepository;
        this.entradaRepository = entradaRepository;
        this.salidaRepository = salidaRepository;
        this.movimientoInventarioRepository = movimientoInventarioRepository;
    }

    @Override
    public Page<InventarioResumenDTO> listar(String busqueda, Pageable pageable) {
        Page<Producto> pagina = (busqueda != null && !busqueda.isBlank())
                ? productoRepository.findByNombreContainingIgnoreCaseAndActivoTrue(busqueda, pageable)
                : productoRepository.findByActivoTrue(pageable);

        return pagina.map(p -> {
            Inventario inv = p.getInventario();
            BigDecimal stockActual = inv != null ? inv.getStockActual() : BigDecimal.ZERO;
            BigDecimal stockMinimo = inv != null ? inv.getStockMinimo() : BigDecimal.ZERO;
            return InventarioResumenDTO.builder()
                    .productoId(p.getId())
                    .productoNombre(p.getNombre())
                    .productoCodigo(p.getCodigo())
                    .stockActual(stockActual)
                    .stockMinimo(stockMinimo)
                    .ubicacion(inv != null ? inv.getUbicacion() : null)
                    .stockBajo(stockActual.compareTo(stockMinimo) <= 0)
                    .build();
        });
    }

    @Override
    @Transactional
    public void registrarEntrada(EntradaFormDTO form, Long usuarioId) {
        Producto producto = productoRepository.findById(form.getProductoId())
                .orElseThrow(() -> new RecursoNoEncontradoException("Producto no encontrado con id: " + form.getProductoId()));
        Usuario usuario = usuarioRepository.findById(usuarioId)
                .orElseThrow(() -> new RecursoNoEncontradoException("Usuario no encontrado con id: " + usuarioId));

        Proveedor proveedor = null;
        if (form.getProveedorId() != null) {
            proveedor = proveedorRepository.findById(form.getProveedorId())
                    .orElseThrow(() -> new RecursoNoEncontradoException("Proveedor no encontrado con id: " + form.getProveedorId()));
        }

        Entrada entrada = new Entrada();
        entrada.setProducto(producto);
        entrada.setProveedor(proveedor);
        entrada.setUsuario(usuario);
        entrada.setCantidad(form.getCantidad());
        entrada.setCostoUnitario(form.getCostoUnitario());
        entrada.setNumeroFactura(form.getNumeroFactura());
        entrada.setObservaciones(form.getObservaciones());
        entradaRepository.save(entrada);

        Inventario inventario = obtenerOCrearInventario(producto);
        BigDecimal stockAnterior = inventario.getStockActual();
        BigDecimal stockNuevo = stockAnterior.add(form.getCantidad());
        inventario.setStockActual(stockNuevo);
        inventarioRepository.save(inventario);

        registrarMovimiento(producto, MovimientoInventario.ENTRADA, form.getCantidad(),
                stockAnterior, stockNuevo, "ENTRADA", entrada.getId(), usuario);
    }

    @Override
    @Transactional
    public void registrarSalida(SalidaFormDTO form, Long usuarioId) {
        Producto producto = productoRepository.findById(form.getProductoId())
                .orElseThrow(() -> new RecursoNoEncontradoException("Producto no encontrado con id: " + form.getProductoId()));
        Usuario usuario = usuarioRepository.findById(usuarioId)
                .orElseThrow(() -> new RecursoNoEncontradoException("Usuario no encontrado con id: " + usuarioId));

        Inventario inventario = obtenerOCrearInventario(producto);
        BigDecimal stockAnterior = inventario.getStockActual();

        if (stockAnterior.compareTo(form.getCantidad()) < 0) {
            throw new IllegalArgumentException(
                    "No hay suficiente stock: disponible " + stockAnterior + ", se intenta descontar " + form.getCantidad());
        }

        Salida salida = new Salida();
        salida.setProducto(producto);
        salida.setUsuario(usuario);
        salida.setCantidad(form.getCantidad());
        salida.setMotivo(form.getMotivo());
        salida.setObservaciones(form.getObservaciones());
        salidaRepository.save(salida);

        BigDecimal stockNuevo = stockAnterior.subtract(form.getCantidad());
        inventario.setStockActual(stockNuevo);
        inventarioRepository.save(inventario);

        registrarMovimiento(producto, MovimientoInventario.SALIDA, form.getCantidad(),
                stockAnterior, stockNuevo, "SALIDA", salida.getId(), usuario);
    }

    @Override
    public Page<MovimientoResumenDTO> listarMovimientos(Long productoId, Pageable pageable) {
        return movimientoInventarioRepository.findByProductoIdOrderByFechaDesc(productoId, pageable)
                .map(m -> MovimientoResumenDTO.builder()
                        .id(m.getId())
                        .productoNombre(m.getProducto().getNombre())
                        .tipoMovimiento(m.getTipoMovimiento())
                        .cantidad(m.getCantidad())
                        .stockAnterior(m.getStockAnterior())
                        .stockNuevo(m.getStockNuevo())
                        .usuarioNombre(m.getUsuario().getNombre() + " " + m.getUsuario().getApellido())
                        .fecha(m.getFecha())
                        .build());
    }

    private Inventario obtenerOCrearInventario(Producto producto) {
        return inventarioRepository.findByProductoId(producto.getId())
                .orElseGet(() -> {
                    Inventario nuevo = new Inventario();
                    nuevo.setProducto(producto);
                    nuevo.setStockActual(BigDecimal.ZERO);
                    nuevo.setStockMinimo(BigDecimal.ZERO);
                    return inventarioRepository.save(nuevo);
                });
    }

    private void registrarMovimiento(Producto producto, String tipo, BigDecimal cantidad,
                                      BigDecimal stockAnterior, BigDecimal stockNuevo,
                                      String referenciaTipo, Long referenciaId, Usuario usuario) {
        MovimientoInventario movimiento = new MovimientoInventario();
        movimiento.setProducto(producto);
        movimiento.setTipoMovimiento(tipo);
        movimiento.setCantidad(cantidad);
        movimiento.setStockAnterior(stockAnterior);
        movimiento.setStockNuevo(stockNuevo);
        movimiento.setReferenciaTipo(referenciaTipo);
        movimiento.setReferenciaId(referenciaId);
        movimiento.setUsuario(usuario);
        movimientoInventarioRepository.save(movimiento);
    }
}

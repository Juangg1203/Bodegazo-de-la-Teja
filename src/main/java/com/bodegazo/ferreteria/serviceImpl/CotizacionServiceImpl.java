package com.bodegazo.ferreteria.serviceImpl;

import com.bodegazo.ferreteria.dto.CotizacionDetalleDTO;
import com.bodegazo.ferreteria.dto.CotizacionResumenDTO;
import com.bodegazo.ferreteria.dto.ItemCarritoDTO;
import com.bodegazo.ferreteria.dto.ItemDetalleDTO;
import com.bodegazo.ferreteria.entity.Cliente;
import com.bodegazo.ferreteria.entity.Cotizacion;
import com.bodegazo.ferreteria.entity.DetalleCotizacion;
import com.bodegazo.ferreteria.entity.DetalleVenta;
import com.bodegazo.ferreteria.entity.Inventario;
import com.bodegazo.ferreteria.entity.MovimientoInventario;
import com.bodegazo.ferreteria.entity.Producto;
import com.bodegazo.ferreteria.entity.Usuario;
import com.bodegazo.ferreteria.entity.Venta;
import com.bodegazo.ferreteria.exception.RecursoNoEncontradoException;
import com.bodegazo.ferreteria.repository.ClienteRepository;
import com.bodegazo.ferreteria.repository.ConfiguracionRepository;
import com.bodegazo.ferreteria.repository.CotizacionRepository;
import com.bodegazo.ferreteria.repository.InventarioRepository;
import com.bodegazo.ferreteria.repository.MovimientoInventarioRepository;
import com.bodegazo.ferreteria.repository.ProductoRepository;
import com.bodegazo.ferreteria.repository.UsuarioRepository;
import com.bodegazo.ferreteria.repository.VentaRepository;
import com.bodegazo.ferreteria.service.CotizacionService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.util.List;

@Service
@Transactional(readOnly = true)
public class CotizacionServiceImpl implements CotizacionService {

    private final CotizacionRepository cotizacionRepository;
    private final ClienteRepository clienteRepository;
    private final UsuarioRepository usuarioRepository;
    private final ProductoRepository productoRepository;
    private final ConfiguracionRepository configuracionRepository;
    private final VentaRepository ventaRepository;
    private final InventarioRepository inventarioRepository;
    private final MovimientoInventarioRepository movimientoInventarioRepository;

    public CotizacionServiceImpl(CotizacionRepository cotizacionRepository,
                                  ClienteRepository clienteRepository,
                                  UsuarioRepository usuarioRepository,
                                  ProductoRepository productoRepository,
                                  ConfiguracionRepository configuracionRepository,
                                  VentaRepository ventaRepository,
                                  InventarioRepository inventarioRepository,
                                  MovimientoInventarioRepository movimientoInventarioRepository) {
        this.cotizacionRepository = cotizacionRepository;
        this.clienteRepository = clienteRepository;
        this.usuarioRepository = usuarioRepository;
        this.productoRepository = productoRepository;
        this.configuracionRepository = configuracionRepository;
        this.ventaRepository = ventaRepository;
        this.inventarioRepository = inventarioRepository;
        this.movimientoInventarioRepository = movimientoInventarioRepository;
    }

    @Override
    @Transactional
    public Long crear(Long clienteId, Long usuarioId, List<ItemCarritoDTO> items) {
        Cliente cliente = clienteRepository.findById(clienteId)
                .orElseThrow(() -> new RecursoNoEncontradoException("Cliente no encontrado con id: " + clienteId));
        Usuario usuario = usuarioRepository.findById(usuarioId)
                .orElseThrow(() -> new RecursoNoEncontradoException("Usuario no encontrado con id: " + usuarioId));

        BigDecimal ivaPorcentaje = obtenerConfig("IVA_PORCENTAJE", "19");
        int vigenciaDias = obtenerConfig("COTIZACION_VIGENCIA_DIAS", "15").intValue();

        Cotizacion cotizacion = new Cotizacion();
        cotizacion.setCliente(cliente);
        cotizacion.setUsuario(usuario);
        cotizacion.setEstado(Cotizacion.PENDIENTE);
        cotizacion.setFechaValidez(LocalDate.now().plusDays(vigenciaDias));

        BigDecimal subtotal = BigDecimal.ZERO;
        for (ItemCarritoDTO item : items) {
            Producto producto = productoRepository.findById(item.getProductoId())
                    .orElseThrow(() -> new RecursoNoEncontradoException("Producto no encontrado con id: " + item.getProductoId()));

            DetalleCotizacion detalle = new DetalleCotizacion();
            detalle.setCotizacion(cotizacion);
            detalle.setProducto(producto);
            detalle.setCantidad(item.getCantidad());
            detalle.setPrecioUnitario(item.getPrecioUnitario());
            detalle.setSubtotal(item.getSubtotal());
            cotizacion.getDetalles().add(detalle);

            subtotal = subtotal.add(item.getSubtotal());
        }

        BigDecimal impuesto = subtotal.multiply(ivaPorcentaje).divide(BigDecimal.valueOf(100), 2, RoundingMode.HALF_UP);
        cotizacion.setSubtotal(subtotal.setScale(2, RoundingMode.HALF_UP));
        cotizacion.setImpuesto(impuesto);
        cotizacion.setTotal(subtotal.add(impuesto).setScale(2, RoundingMode.HALF_UP));

        return cotizacionRepository.save(cotizacion).getId();
    }

    @Override
    public Page<CotizacionResumenDTO> listarTodas(Pageable pageable) {
        return cotizacionRepository.findAll(pageable).map(this::aResumenDTO);
    }

    @Override
    public Page<CotizacionResumenDTO> listarPorCliente(Long clienteId, Pageable pageable) {
        return cotizacionRepository.findByClienteIdOrderByFechaEmisionDesc(clienteId, pageable).map(this::aResumenDTO);
    }

    @Override
    public CotizacionDetalleDTO obtenerDetalle(Long id) {
        Cotizacion c = cotizacionRepository.findById(id)
                .orElseThrow(() -> new RecursoNoEncontradoException("Cotización no encontrada con id: " + id));

        List<ItemDetalleDTO> items = c.getDetalles().stream()
                .map(d -> new ItemDetalleDTO(
                        d.getProducto().getNombre(), d.getProducto().getCodigo(),
                        d.getCantidad(), d.getPrecioUnitario(), d.getSubtotal()))
                .toList();

        return CotizacionDetalleDTO.builder()
                .id(c.getId())
                .clienteNombre(c.getCliente().getNombre() + " " + c.getCliente().getApellido())
                .clienteDocumento(c.getCliente().getNumeroDocumento())
                .usuarioNombre(c.getUsuario().getNombre() + " " + c.getUsuario().getApellido())
                .fechaEmision(c.getFechaEmision())
                .fechaValidez(c.getFechaValidez())
                .subtotal(c.getSubtotal())
                .impuesto(c.getImpuesto())
                .total(c.getTotal())
                .estado(c.getEstado())
                .items(items)
                .build();
    }

    @Override
    @Transactional
    public Long aceptar(Long id, Long usuarioId) {
        Cotizacion cotizacion = cotizacionRepository.findById(id)
                .orElseThrow(() -> new RecursoNoEncontradoException("Cotización no encontrada con id: " + id));
        Usuario usuario = usuarioRepository.findById(usuarioId)
                .orElseThrow(() -> new RecursoNoEncontradoException("Usuario no encontrado con id: " + usuarioId));

        Venta venta = new Venta();
        venta.setCliente(cotizacion.getCliente());
        venta.setUsuario(usuario);
        venta.setSubtotal(cotizacion.getSubtotal());
        venta.setImpuesto(cotizacion.getImpuesto());
        venta.setTotal(cotizacion.getTotal());
        venta.setEstado(Venta.COMPLETADA);

        for (DetalleCotizacion dc : cotizacion.getDetalles()) {
            DetalleVenta dv = new DetalleVenta();
            dv.setVenta(venta);
            dv.setProducto(dc.getProducto());
            dv.setCantidad(dc.getCantidad());
            dv.setPrecioUnitario(dc.getPrecioUnitario());
            dv.setSubtotal(dc.getSubtotal());
            venta.getDetalles().add(dv);

            // Descontar inventario y dejar registro del movimiento.
            Inventario inventario = inventarioRepository.findByProductoId(dc.getProducto().getId())
                    .orElse(null);
            if (inventario != null) {
                BigDecimal stockAnterior = inventario.getStockActual();
                BigDecimal stockNuevo = stockAnterior.subtract(dc.getCantidad());
                inventario.setStockActual(stockNuevo);
                inventarioRepository.save(inventario);

                MovimientoInventario movimiento = new MovimientoInventario();
                movimiento.setProducto(dc.getProducto());
                movimiento.setTipoMovimiento(MovimientoInventario.VENTA);
                movimiento.setCantidad(dc.getCantidad());
                movimiento.setStockAnterior(stockAnterior);
                movimiento.setStockNuevo(stockNuevo);
                movimiento.setReferenciaTipo("COTIZACION");
                movimiento.setReferenciaId(cotizacion.getId());
                movimiento.setUsuario(usuario);
                movimientoInventarioRepository.save(movimiento);
            }
        }

        Venta ventaGuardada = ventaRepository.save(venta);

        cotizacion.setEstado(Cotizacion.ACEPTADA);
        cotizacionRepository.save(cotizacion);

        return ventaGuardada.getId();
    }

    @Override
    @Transactional
    public void rechazar(Long id) {
        Cotizacion cotizacion = cotizacionRepository.findById(id)
                .orElseThrow(() -> new RecursoNoEncontradoException("Cotización no encontrada con id: " + id));
        cotizacion.setEstado(Cotizacion.RECHAZADA);
        cotizacionRepository.save(cotizacion);
    }

    private CotizacionResumenDTO aResumenDTO(Cotizacion c) {
        return CotizacionResumenDTO.builder()
                .id(c.getId())
                .clienteNombre(c.getCliente().getNombre() + " " + c.getCliente().getApellido())
                .fechaEmision(c.getFechaEmision())
                .fechaValidez(c.getFechaValidez())
                .total(c.getTotal())
                .estado(c.getEstado())
                .build();
    }

    private BigDecimal obtenerConfig(String clave, String valorPorDefecto) {
        return configuracionRepository.findByClave(clave)
                .map(cfg -> new BigDecimal(cfg.getValor()))
                .orElse(new BigDecimal(valorPorDefecto));
    }
}

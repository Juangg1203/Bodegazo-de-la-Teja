package com.bodegazo.ferreteria.serviceImpl;

import com.bodegazo.ferreteria.dto.ItemVentaRapidaDTO;
import com.bodegazo.ferreteria.dto.VentaRapidaFormDTO;
import com.bodegazo.ferreteria.entity.Cliente;
import com.bodegazo.ferreteria.entity.DetalleVenta;
import com.bodegazo.ferreteria.entity.Inventario;
import com.bodegazo.ferreteria.entity.MovimientoInventario;
import com.bodegazo.ferreteria.entity.Producto;
import com.bodegazo.ferreteria.entity.Usuario;
import com.bodegazo.ferreteria.entity.Venta;
import com.bodegazo.ferreteria.exception.RecursoNoEncontradoException;
import com.bodegazo.ferreteria.repository.ClienteRepository;
import com.bodegazo.ferreteria.repository.ConfiguracionRepository;
import com.bodegazo.ferreteria.repository.InventarioRepository;
import com.bodegazo.ferreteria.repository.MovimientoInventarioRepository;
import com.bodegazo.ferreteria.repository.ProductoRepository;
import com.bodegazo.ferreteria.repository.UsuarioRepository;
import com.bodegazo.ferreteria.repository.VentaRepository;
import com.bodegazo.ferreteria.service.VentaRapidaService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;

/**
 * Registro directo de ventas en mostrador — pensado para reemplazar el
 * cuaderno manual: el vendedor elige el producto, escribe la cantidad
 * y puede AJUSTAR el precio a mano si hay rebaja, sin tener que pasar
 * por el flujo completo de cotización → carrito → aceptar.
 */
@Service
public class VentaRapidaServiceImpl implements VentaRapidaService {

    private final ClienteRepository clienteRepository;
    private final UsuarioRepository usuarioRepository;
    private final ProductoRepository productoRepository;
    private final InventarioRepository inventarioRepository;
    private final MovimientoInventarioRepository movimientoInventarioRepository;
    private final VentaRepository ventaRepository;
    private final ConfiguracionRepository configuracionRepository;

    public VentaRapidaServiceImpl(ClienteRepository clienteRepository, UsuarioRepository usuarioRepository,
                                   ProductoRepository productoRepository, InventarioRepository inventarioRepository,
                                   MovimientoInventarioRepository movimientoInventarioRepository,
                                   VentaRepository ventaRepository, ConfiguracionRepository configuracionRepository) {
        this.clienteRepository = clienteRepository;
        this.usuarioRepository = usuarioRepository;
        this.productoRepository = productoRepository;
        this.inventarioRepository = inventarioRepository;
        this.movimientoInventarioRepository = movimientoInventarioRepository;
        this.ventaRepository = ventaRepository;
        this.configuracionRepository = configuracionRepository;
    }

    @Override
    @Transactional
    public Long registrar(VentaRapidaFormDTO form, Long usuarioId) {
        if (form.getItems() == null || form.getItems().isEmpty()) {
            throw new IllegalArgumentException("Agrega al menos un producto a la venta.");
        }

        Usuario usuario = usuarioRepository.findById(usuarioId)
                .orElseThrow(() -> new RecursoNoEncontradoException("Usuario no encontrado con id: " + usuarioId));

        Cliente cliente = obtenerOCrearCliente(form);

        Venta venta = new Venta();
        venta.setCliente(cliente);
        venta.setUsuario(usuario);
        venta.setEstado(Venta.COMPLETADA);
        venta.setMetodoPago((form.getMetodoPago() != null && !form.getMetodoPago().isBlank())
                ? form.getMetodoPago() : Venta.PAGO_EFECTIVO);

        BigDecimal subtotal = BigDecimal.ZERO;

        for (ItemVentaRapidaDTO item : form.getItems()) {
            if (item.getProductoId() == null || item.getCantidad() == null || item.getPrecioUnitario() == null
                    || item.getCantidad().compareTo(BigDecimal.ZERO) <= 0) {
                continue;
            }
            Producto producto = productoRepository.findById(item.getProductoId())
                    .orElseThrow(() -> new RecursoNoEncontradoException("Producto no encontrado con id: " + item.getProductoId()));

            BigDecimal subtotalLinea = item.getCantidad().multiply(item.getPrecioUnitario());

            DetalleVenta detalle = new DetalleVenta();
            detalle.setVenta(venta);
            detalle.setProducto(producto);
            detalle.setCantidad(item.getCantidad());
            detalle.setPrecioUnitario(item.getPrecioUnitario());
            detalle.setSubtotal(subtotalLinea);
            venta.getDetalles().add(detalle);

            subtotal = subtotal.add(subtotalLinea);

            // Descontar inventario y dejar el movimiento, igual que al aceptar una cotización.
            Inventario inventario = inventarioRepository.findByProductoId(producto.getId()).orElse(null);
            if (inventario != null) {
                BigDecimal stockAnterior = inventario.getStockActual();
                BigDecimal stockNuevo = stockAnterior.subtract(item.getCantidad());
                inventario.setStockActual(stockNuevo);
                inventarioRepository.save(inventario);

                MovimientoInventario movimiento = new MovimientoInventario();
                movimiento.setProducto(producto);
                movimiento.setTipoMovimiento(MovimientoInventario.VENTA);
                movimiento.setCantidad(item.getCantidad());
                movimiento.setStockAnterior(stockAnterior);
                movimiento.setStockNuevo(stockNuevo);
                movimiento.setReferenciaTipo("VENTA_RAPIDA");
                movimiento.setUsuario(usuario);
                movimientoInventarioRepository.save(movimiento);
            }
        }

        if (venta.getDetalles().isEmpty()) {
            throw new IllegalArgumentException("Ninguna línea de la venta tiene producto, cantidad y precio válidos.");
        }

        // El IVA ya viene incluido dentro del precio de cada producto —
        // no se suma aparte, para no cobrarlo dos veces.
        venta.setSubtotal(subtotal.setScale(2, RoundingMode.HALF_UP));
        venta.setImpuesto(BigDecimal.ZERO);
        venta.setTotal(subtotal.setScale(2, RoundingMode.HALF_UP));

        return ventaRepository.save(venta).getId();
    }

    private Cliente obtenerOCrearCliente(VentaRapidaFormDTO form) {
        if (form.getClienteId() != null) {
            return clienteRepository.findById(form.getClienteId())
                    .orElseThrow(() -> new RecursoNoEncontradoException("Cliente no encontrado con id: " + form.getClienteId()));
        }

        // Cliente nuevo (mostrador, sin cuenta de usuario asociada).
        if (form.getClienteNuevoDocumento() == null || form.getClienteNuevoDocumento().isBlank()
                || form.getClienteNuevoNombre() == null || form.getClienteNuevoNombre().isBlank()) {
            throw new IllegalArgumentException("Selecciona un cliente existente o ingresa nombre y documento del cliente nuevo.");
        }

        return clienteRepository.findByNumeroDocumento(form.getClienteNuevoDocumento())
                .orElseGet(() -> {
                    Cliente nuevo = new Cliente();
                    nuevo.setTipoDocumento("CC");
                    nuevo.setNumeroDocumento(form.getClienteNuevoDocumento());
                    nuevo.setNombre(form.getClienteNuevoNombre());
                    nuevo.setApellido(form.getClienteNuevoApellido() != null ? form.getClienteNuevoApellido() : "");
                    nuevo.setTelefono(form.getClienteNuevoTelefono());
                    nuevo.setActivo(true);
                    return clienteRepository.save(nuevo);
                });
    }

    private BigDecimal obtenerConfig(String clave, String valorPorDefecto) {
        return configuracionRepository.findByClave(clave)
                .map(c -> new BigDecimal(c.getValor()))
                .orElse(new BigDecimal(valorPorDefecto));
    }
}

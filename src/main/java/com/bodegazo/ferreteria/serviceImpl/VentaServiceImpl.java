package com.bodegazo.ferreteria.serviceImpl;

import com.bodegazo.ferreteria.dto.ItemDetalleDTO;
import com.bodegazo.ferreteria.dto.VentaDetalleDTO;
import com.bodegazo.ferreteria.dto.VentaResumenDTO;
import com.bodegazo.ferreteria.entity.Venta;
import com.bodegazo.ferreteria.exception.RecursoNoEncontradoException;
import com.bodegazo.ferreteria.repository.VentaRepository;
import com.bodegazo.ferreteria.service.VentaService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional(readOnly = true)
public class VentaServiceImpl implements VentaService {

    private final VentaRepository ventaRepository;

    public VentaServiceImpl(VentaRepository ventaRepository) {
        this.ventaRepository = ventaRepository;
    }

    @Override
    public Page<VentaResumenDTO> listar(Pageable pageable) {
        return ventaRepository.findAll(pageable).map(v -> VentaResumenDTO.builder()
                .id(v.getId())
                .clienteNombre(v.getCliente().getNombre() + " " + v.getCliente().getApellido())
                .fecha(v.getFecha())
                .total(v.getTotal())
                .estado(v.getEstado())
                .metodoPago(v.getMetodoPago())
                .build());
    }

    @Override
    public VentaDetalleDTO obtenerDetalle(Long id) {
        Venta v = ventaRepository.findById(id)
                .orElseThrow(() -> new RecursoNoEncontradoException("Venta no encontrada con id: " + id));

        List<ItemDetalleDTO> items = v.getDetalles().stream()
                .map(d -> new ItemDetalleDTO(
                        d.getProducto().getNombre(), d.getProducto().getCodigo(),
                        d.getCantidad(), d.getPrecioUnitario(), d.getSubtotal()))
                .toList();

        return VentaDetalleDTO.builder()
                .id(v.getId())
                .clienteNombre(v.getCliente().getNombre() + " " + v.getCliente().getApellido())
                .usuarioNombre(v.getUsuario().getNombre() + " " + v.getUsuario().getApellido())
                .fecha(v.getFecha())
                .subtotal(v.getSubtotal())
                .impuesto(v.getImpuesto())
                .total(v.getTotal())
                .estado(v.getEstado())
                .metodoPago(v.getMetodoPago())
                .items(items)
                .build();
    }
}

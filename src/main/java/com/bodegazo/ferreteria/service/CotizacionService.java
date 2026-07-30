package com.bodegazo.ferreteria.service;

import com.bodegazo.ferreteria.dto.CotizacionDetalleDTO;
import com.bodegazo.ferreteria.dto.CotizacionResumenDTO;
import com.bodegazo.ferreteria.dto.ItemCarritoDTO;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;

public interface CotizacionService {

    /** Crea la cotización a partir del carrito armado en sesión. */
    Long crear(Long clienteId, Long usuarioId, List<ItemCarritoDTO> items);

    Page<CotizacionResumenDTO> listarTodas(Pageable pageable);

    Page<CotizacionResumenDTO> listarPorCliente(Long clienteId, Pageable pageable);

    CotizacionDetalleDTO obtenerDetalle(Long id);

    /** Acepta la cotización: genera la venta correspondiente y descuenta inventario. */
    Long aceptar(Long id, Long usuarioId);

    void rechazar(Long id);
}

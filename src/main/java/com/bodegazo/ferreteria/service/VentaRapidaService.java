package com.bodegazo.ferreteria.service;

import com.bodegazo.ferreteria.dto.VentaRapidaFormDTO;

public interface VentaRapidaService {
    /** Registra la venta directamente (sin pasar por cotización), descuenta inventario y deja el movimiento. */
    Long registrar(VentaRapidaFormDTO form, Long usuarioId);
}

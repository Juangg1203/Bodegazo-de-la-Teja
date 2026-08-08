package com.bodegazo.ferreteria.service;

import com.bodegazo.ferreteria.dto.EntradaFormDTO;
import com.bodegazo.ferreteria.dto.InventarioResumenDTO;
import com.bodegazo.ferreteria.dto.MovimientoResumenDTO;
import com.bodegazo.ferreteria.dto.SalidaFormDTO;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface InventarioService {

    Page<InventarioResumenDTO> listar(String busqueda, Pageable pageable);

    /** Registra una entrada de mercancía: sube el stock y deja el movimiento. */
    void registrarEntrada(EntradaFormDTO form, Long usuarioId);

    /** Registra una salida manual (ajuste, daño, devolución — no venta): baja el stock. */
    void registrarSalida(SalidaFormDTO form, Long usuarioId);

    Page<MovimientoResumenDTO> listarMovimientos(Long productoId, Pageable pageable);
}

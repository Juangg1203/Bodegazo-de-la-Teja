package com.bodegazo.ferreteria.service;

import com.bodegazo.ferreteria.dto.VentaDetalleDTO;
import com.bodegazo.ferreteria.dto.VentaResumenDTO;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface VentaService {
    Page<VentaResumenDTO> listar(Pageable pageable);
    VentaDetalleDTO obtenerDetalle(Long id);
}

package com.bodegazo.ferreteria.service;

import com.bodegazo.ferreteria.dto.UsuarioFormDTO;
import com.bodegazo.ferreteria.dto.UsuarioResumenDTO;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface UsuarioService {

    Page<UsuarioResumenDTO> listar(String busqueda, Pageable pageable);

    UsuarioFormDTO obtenerFormularioPorId(Long id);

    /** Crea o actualiza (según si form.getId() es null). Si password viene vacío al editar, no la cambia. */
    Long guardar(UsuarioFormDTO form);

    void desactivar(Long id);

    void activar(Long id);
}

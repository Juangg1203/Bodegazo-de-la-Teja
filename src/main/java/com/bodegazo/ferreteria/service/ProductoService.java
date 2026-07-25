package com.bodegazo.ferreteria.service;

import com.bodegazo.ferreteria.dto.ProductoDetalleDTO;
import com.bodegazo.ferreteria.dto.ProductoFormDTO;
import com.bodegazo.ferreteria.dto.ProductoResumenDTO;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface ProductoService {

    /**
     * Lista productos activos, con filtros opcionales por tipo de
     * producto (IMPERMEABILIZANTE / TEJA_UPVC / ACCESORIO), categoría
     * y término de búsqueda por nombre. Cualquier filtro en null se
     * ignora.
     */
    Page<ProductoResumenDTO> listar(String tipoProducto, Long categoriaId, String busqueda, Pageable pageable);

    ProductoDetalleDTO obtenerPorId(Long id);

    // ==================== Administración (Admin / Jefe de Bodega) ====================

    /** Lista TODOS los productos (activos e inactivos) para el panel de administración,
     *  filtrados por los tipos de producto que le corresponden a cada empresa. */
    Page<ProductoResumenDTO> listarParaAdmin(String busqueda, java.util.List<String> tiposProducto, Pageable pageable);

    /** Carga un producto existente en el formulario de edición. */
    ProductoFormDTO obtenerFormularioPorId(Long id);

    /** Crea un producto nuevo o actualiza uno existente (según si form.getId() es null). */
    Long guardar(ProductoFormDTO form);

    /** Borrado lógico: marca el producto como inactivo, no lo elimina de la base. */
    void desactivar(Long id);

    /** Reactiva un producto previamente desactivado. */
    void activar(Long id);
}

package com.bodegazo.ferreteria.repository;

import com.bodegazo.ferreteria.entity.Producto;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ProductoRepository extends JpaRepository<Producto, Long> {
    Optional<Producto> findByCodigo(String codigo);
    Page<Producto> findByActivoTrue(Pageable pageable);
    Page<Producto> findByTipoProductoAndActivoTrue(String tipoProducto, Pageable pageable);
    Page<Producto> findByCategoriaIdAndActivoTrue(Long categoriaId, Pageable pageable);
    Page<Producto> findByNombreContainingIgnoreCaseAndActivoTrue(String nombre, Pageable pageable);
    Page<Producto> findByNombreContainingIgnoreCase(String nombre, Pageable pageable);
    Page<Producto> findByTipoProductoIn(List<String> tipos, Pageable pageable);
    Page<Producto> findByTipoProductoInAndNombreContainingIgnoreCase(List<String> tipos, String nombre, Pageable pageable);
}

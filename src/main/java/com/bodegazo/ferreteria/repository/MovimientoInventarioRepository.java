package com.bodegazo.ferreteria.repository;

import com.bodegazo.ferreteria.entity.MovimientoInventario;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MovimientoInventarioRepository extends JpaRepository<MovimientoInventario, Long> {
    Page<MovimientoInventario> findByProductoIdOrderByFechaDesc(Long productoId, Pageable pageable);
}

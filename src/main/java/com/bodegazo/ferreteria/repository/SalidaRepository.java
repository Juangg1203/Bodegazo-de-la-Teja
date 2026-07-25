package com.bodegazo.ferreteria.repository;

import com.bodegazo.ferreteria.entity.Salida;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface SalidaRepository extends JpaRepository<Salida, Long> {
    Page<Salida> findByProductoIdOrderByFechaDesc(Long productoId, Pageable pageable);
}

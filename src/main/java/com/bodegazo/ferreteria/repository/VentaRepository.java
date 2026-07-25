package com.bodegazo.ferreteria.repository;

import com.bodegazo.ferreteria.entity.Venta;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.OffsetDateTime;
import java.util.List;

public interface VentaRepository extends JpaRepository<Venta, Long> {
    Page<Venta> findByClienteIdOrderByFechaDesc(Long clienteId, Pageable pageable);
    List<Venta> findByFechaBetween(OffsetDateTime desde, OffsetDateTime hasta);
}

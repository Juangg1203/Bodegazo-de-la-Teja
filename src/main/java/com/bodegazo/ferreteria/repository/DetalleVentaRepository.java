package com.bodegazo.ferreteria.repository;

import com.bodegazo.ferreteria.entity.DetalleVenta;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface DetalleVentaRepository extends JpaRepository<DetalleVenta, Long> {
    List<DetalleVenta> findByVentaId(Long ventaId);

    @org.springframework.data.jpa.repository.Query(
        "SELECT dv.producto.nombre, SUM(dv.cantidad) FROM DetalleVenta dv " +
        "GROUP BY dv.producto.nombre ORDER BY SUM(dv.cantidad) DESC"
    )
    List<Object[]> topProductosVendidos(org.springframework.data.domain.Pageable pageable);
}

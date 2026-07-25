package com.bodegazo.ferreteria.repository;

import com.bodegazo.ferreteria.entity.Cotizacion;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CotizacionRepository extends JpaRepository<Cotizacion, Long> {
    Page<Cotizacion> findByClienteIdOrderByFechaEmisionDesc(Long clienteId, Pageable pageable);
    Page<Cotizacion> findByEstadoOrderByFechaEmisionDesc(String estado, Pageable pageable);
}

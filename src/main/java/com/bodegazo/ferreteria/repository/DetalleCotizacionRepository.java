package com.bodegazo.ferreteria.repository;

import com.bodegazo.ferreteria.entity.DetalleCotizacion;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface DetalleCotizacionRepository extends JpaRepository<DetalleCotizacion, Long> {
    List<DetalleCotizacion> findByCotizacionId(Long cotizacionId);
}

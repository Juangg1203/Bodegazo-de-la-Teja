package com.bodegazo.ferreteria.repository;

import com.bodegazo.ferreteria.entity.Inventario;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface InventarioRepository extends JpaRepository<Inventario, Long> {
    Optional<Inventario> findByProductoId(Long productoId);

    // Alerta de stock mínimo: productos cuyo stock actual es menor o igual al mínimo definido
    @org.springframework.data.jpa.repository.Query(
        "SELECT i FROM Inventario i WHERE i.stockActual <= i.stockMinimo"
    )
    List<Inventario> findConStockBajo();
}

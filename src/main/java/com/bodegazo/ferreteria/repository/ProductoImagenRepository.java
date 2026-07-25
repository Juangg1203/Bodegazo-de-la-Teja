package com.bodegazo.ferreteria.repository;

import com.bodegazo.ferreteria.entity.ProductoImagen;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ProductoImagenRepository extends JpaRepository<ProductoImagen, Long> {
    List<ProductoImagen> findByProductoIdOrderByOrdenAsc(Long productoId);
}

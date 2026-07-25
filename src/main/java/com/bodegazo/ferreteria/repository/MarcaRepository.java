package com.bodegazo.ferreteria.repository;

import com.bodegazo.ferreteria.entity.Marca;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface MarcaRepository extends JpaRepository<Marca, Long> {
    List<Marca> findByActivoTrue();
}

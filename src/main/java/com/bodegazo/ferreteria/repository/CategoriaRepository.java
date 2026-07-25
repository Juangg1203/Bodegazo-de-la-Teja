package com.bodegazo.ferreteria.repository;

import com.bodegazo.ferreteria.entity.Categoria;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface CategoriaRepository extends JpaRepository<Categoria, Long> {
    Optional<Categoria> findBySlug(String slug);
    List<Categoria> findByActivoTrue();
    List<Categoria> findByCategoriaPadreIsNullAndActivoTrue();
}

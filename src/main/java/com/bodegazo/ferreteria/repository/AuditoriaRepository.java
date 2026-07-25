package com.bodegazo.ferreteria.repository;

import com.bodegazo.ferreteria.entity.Auditoria;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AuditoriaRepository extends JpaRepository<Auditoria, Long> {
    Page<Auditoria> findByUsuarioIdOrderByFechaDesc(Long usuarioId, Pageable pageable);
}

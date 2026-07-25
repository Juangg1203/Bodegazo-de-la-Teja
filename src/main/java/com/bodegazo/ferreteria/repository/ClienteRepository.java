package com.bodegazo.ferreteria.repository;

import com.bodegazo.ferreteria.entity.Cliente;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface ClienteRepository extends JpaRepository<Cliente, Long> {
    Optional<Cliente> findByNumeroDocumento(String numeroDocumento);
    Optional<Cliente> findByUsuarioId(Long usuarioId);
}

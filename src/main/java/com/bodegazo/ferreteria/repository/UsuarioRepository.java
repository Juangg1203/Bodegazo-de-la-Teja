package com.bodegazo.ferreteria.repository;

import com.bodegazo.ferreteria.entity.Usuario;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UsuarioRepository extends JpaRepository<Usuario, Long> {
    Optional<Usuario> findByCorreo(String correo);
    boolean existsByCorreo(String correo);
    Page<Usuario> findByNombreContainingIgnoreCaseOrApellidoContainingIgnoreCaseOrCorreoContainingIgnoreCase(
            String nombre, String apellido, String correo, Pageable pageable);
}

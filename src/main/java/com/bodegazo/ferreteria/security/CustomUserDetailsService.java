package com.bodegazo.ferreteria.security;

import com.bodegazo.ferreteria.entity.Usuario;
import com.bodegazo.ferreteria.repository.UsuarioRepository;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Implementación real de UserDetailsService: autentica contra la tabla
 * "usuarios". El "username" de Spring Security es el correo electrónico
 * (ver usernameParameter("correo") en SecurityConfig).
 */
@Service
public class CustomUserDetailsService implements UserDetailsService {

    private final UsuarioRepository usuarioRepository;

    public CustomUserDetailsService(UsuarioRepository usuarioRepository) {
        this.usuarioRepository = usuarioRepository;
    }

    @Override
    @Transactional(readOnly = true)
    public UserDetails loadUserByUsername(String correo) throws UsernameNotFoundException {
        Usuario usuario = usuarioRepository.findByCorreo(correo)
                .orElseThrow(() -> new UsernameNotFoundException(
                        "No existe un usuario registrado con el correo: " + correo));
        return new CustomUserPrincipal(usuario);
    }
}

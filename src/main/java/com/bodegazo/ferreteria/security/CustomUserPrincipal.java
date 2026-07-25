package com.bodegazo.ferreteria.security;

import com.bodegazo.ferreteria.entity.Usuario;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * Adaptador entre la entidad Usuario (JPA) y el contrato UserDetails
 * que exige Spring Security. Cada rol se expone como autoridad con
 * el prefijo "ROLE_", que es lo que consumen las reglas hasRole(...)
 * definidas en SecurityConfig.
 */
public class CustomUserPrincipal implements UserDetails {

    private final Long id;
    private final String nombre;
    private final String apellido;
    private final String correo;
    private final String password;
    private final boolean activo;
    private final boolean cuentaNoExpirada;
    private final boolean cuentaNoBloqueada;
    private final boolean credencialesOk;
    private final Set<GrantedAuthority> authorities;

    public CustomUserPrincipal(Usuario usuario) {
        this.id = usuario.getId();
        this.nombre = usuario.getNombre();
        this.apellido = usuario.getApellido();
        this.correo = usuario.getCorreo();
        this.password = usuario.getPassword();
        this.activo = Boolean.TRUE.equals(usuario.getActivo());
        this.cuentaNoExpirada = Boolean.TRUE.equals(usuario.getCuentaNoExpirada());
        this.cuentaNoBloqueada = Boolean.TRUE.equals(usuario.getCuentaNoBloqueada());
        this.credencialesOk = Boolean.TRUE.equals(usuario.getCredencialesOk());
        this.authorities = usuario.getRoles().stream()
                .map(rol -> new SimpleGrantedAuthority("ROLE_" + rol.getNombre()))
                .collect(Collectors.toSet());
    }

    public Long getId() {
        return id;
    }

    public String getNombre() {
        return nombre;
    }

    public String getApellido() {
        return apellido;
    }

    public String getCorreo() {
        return correo;
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return authorities;
    }

    @Override
    public String getPassword() {
        return password;
    }

    @Override
    public String getUsername() {
        return correo;
    }

    @Override
    public boolean isAccountNonExpired() {
        return cuentaNoExpirada;
    }

    @Override
    public boolean isAccountNonLocked() {
        return cuentaNoBloqueada;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return credencialesOk;
    }

    @Override
    public boolean isEnabled() {
        return activo;
    }
}

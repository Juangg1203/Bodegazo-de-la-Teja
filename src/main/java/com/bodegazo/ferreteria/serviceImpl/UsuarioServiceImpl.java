package com.bodegazo.ferreteria.serviceImpl;

import com.bodegazo.ferreteria.dto.UsuarioFormDTO;
import com.bodegazo.ferreteria.dto.UsuarioResumenDTO;
import com.bodegazo.ferreteria.entity.Rol;
import com.bodegazo.ferreteria.entity.Usuario;
import com.bodegazo.ferreteria.exception.RecursoNoEncontradoException;
import com.bodegazo.ferreteria.repository.RolRepository;
import com.bodegazo.ferreteria.repository.UsuarioRepository;
import com.bodegazo.ferreteria.service.UsuarioService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

@Service
@Transactional(readOnly = true)
public class UsuarioServiceImpl implements UsuarioService {

    private final UsuarioRepository usuarioRepository;
    private final RolRepository rolRepository;
    private final PasswordEncoder passwordEncoder;

    public UsuarioServiceImpl(UsuarioRepository usuarioRepository, RolRepository rolRepository,
                               PasswordEncoder passwordEncoder) {
        this.usuarioRepository = usuarioRepository;
        this.rolRepository = rolRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public Page<UsuarioResumenDTO> listar(String busqueda, Pageable pageable) {
        Page<Usuario> pagina = (busqueda != null && !busqueda.isBlank())
                ? usuarioRepository.findByNombreContainingIgnoreCaseOrApellidoContainingIgnoreCaseOrCorreoContainingIgnoreCase(
                        busqueda, busqueda, busqueda, pageable)
                : usuarioRepository.findAll(pageable);

        return pagina.map(u -> UsuarioResumenDTO.builder()
                .id(u.getId())
                .nombre(u.getNombre())
                .apellido(u.getApellido())
                .correo(u.getCorreo())
                .activo(Boolean.TRUE.equals(u.getActivo()))
                .roles(u.getRoles().stream().map(Rol::getNombre).sorted().toList())
                .build());
    }

    @Override
    public UsuarioFormDTO obtenerFormularioPorId(Long id) {
        Usuario u = usuarioRepository.findById(id)
                .orElseThrow(() -> new RecursoNoEncontradoException("Usuario no encontrado con id: " + id));

        UsuarioFormDTO form = new UsuarioFormDTO();
        form.setId(u.getId());
        form.setNombre(u.getNombre());
        form.setApellido(u.getApellido());
        form.setCorreo(u.getCorreo());
        form.setTelefono(u.getTelefono());
        form.setRolesIds(u.getRoles().stream().map(Rol::getId).toList());
        return form;
    }

    @Override
    @Transactional
    public Long guardar(UsuarioFormDTO form) {
        Usuario usuario = (form.getId() != null)
                ? usuarioRepository.findById(form.getId())
                    .orElseThrow(() -> new RecursoNoEncontradoException("Usuario no encontrado con id: " + form.getId()))
                : new Usuario();

        usuario.setNombre(form.getNombre());
        usuario.setApellido(form.getApellido());
        usuario.setCorreo(form.getCorreo());
        usuario.setTelefono(form.getTelefono());

        if (usuario.getId() == null) {
            usuario.setActivo(true);
        }

        if (form.getPassword() != null && !form.getPassword().isBlank()) {
            usuario.setPassword(passwordEncoder.encode(form.getPassword()));
        } else if (usuario.getId() == null) {
            throw new IllegalArgumentException("La contraseña es obligatoria para un usuario nuevo.");
        }

        Set<Rol> roles = new HashSet<>();
        if (form.getRolesIds() != null) {
            for (Long rolId : form.getRolesIds()) {
                Rol rol = rolRepository.findById(rolId)
                        .orElseThrow(() -> new RecursoNoEncontradoException("Rol no encontrado con id: " + rolId));
                roles.add(rol);
            }
        }
        if (roles.isEmpty()) {
            throw new IllegalArgumentException("Selecciona al menos un rol para el usuario.");
        }
        usuario.setRoles(roles);

        return usuarioRepository.save(usuario).getId();
    }

    @Override
    @Transactional
    public void desactivar(Long id) {
        Usuario usuario = usuarioRepository.findById(id)
                .orElseThrow(() -> new RecursoNoEncontradoException("Usuario no encontrado con id: " + id));
        usuario.setActivo(false);
        usuarioRepository.save(usuario);
    }

    @Override
    @Transactional
    public void activar(Long id) {
        Usuario usuario = usuarioRepository.findById(id)
                .orElseThrow(() -> new RecursoNoEncontradoException("Usuario no encontrado con id: " + id));
        usuario.setActivo(true);
        usuarioRepository.save(usuario);
    }
}

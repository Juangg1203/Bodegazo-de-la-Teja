package com.bodegazo.ferreteria.controller;

import com.bodegazo.ferreteria.dto.UsuarioFormDTO;
import com.bodegazo.ferreteria.dto.UsuarioResumenDTO;
import com.bodegazo.ferreteria.repository.RolRepository;
import com.bodegazo.ferreteria.service.UsuarioService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

/**
 * Gestión de usuarios — Administrador únicamente (ver regla
 * "/usuarios/**" en SecurityConfig).
 */
@Controller
public class UsuarioAdminController {

    private static final int TAMANIO_PAGINA = 10;

    private final UsuarioService usuarioService;
    private final RolRepository rolRepository;

    public UsuarioAdminController(UsuarioService usuarioService, RolRepository rolRepository) {
        this.usuarioService = usuarioService;
        this.rolRepository = rolRepository;
    }

    @GetMapping("/usuarios")
    public String listar(@RequestParam(required = false) String buscar,
                          @RequestParam(defaultValue = "0") int pagina,
                          Model model) {
        Page<UsuarioResumenDTO> resultado = usuarioService.listar(buscar, PageRequest.of(pagina, TAMANIO_PAGINA));
        model.addAttribute("pageTitle", "Administrar Usuarios");
        model.addAttribute("usuarios", resultado);
        model.addAttribute("buscar", buscar);
        return "pages/admin/usuarios-lista";
    }

    @GetMapping("/usuarios/nuevo")
    public String formularioNuevo(Model model) {
        model.addAttribute("pageTitle", "Nuevo Usuario");
        model.addAttribute("form", new UsuarioFormDTO());
        model.addAttribute("roles", rolRepository.findAll());
        return "pages/admin/usuario-form";
    }

    @GetMapping("/usuarios/{id}/editar")
    public String formularioEditar(@PathVariable Long id, Model model) {
        model.addAttribute("pageTitle", "Editar Usuario");
        model.addAttribute("form", usuarioService.obtenerFormularioPorId(id));
        model.addAttribute("roles", rolRepository.findAll());
        return "pages/admin/usuario-form";
    }

    @PostMapping("/usuarios")
    public String guardar(@ModelAttribute("form") UsuarioFormDTO form, Model model,
                           RedirectAttributes redirectAttributes) {
        try {
            Long id = usuarioService.guardar(form);
            redirectAttributes.addFlashAttribute("mensaje",
                    (form.getId() != null ? "Usuario actualizado" : "Usuario creado") + " correctamente.");
            return "redirect:/usuarios/" + id + "/editar";
        } catch (IllegalArgumentException e) {
            model.addAttribute("pageTitle", form.getId() != null ? "Editar Usuario" : "Nuevo Usuario");
            model.addAttribute("error", e.getMessage());
            model.addAttribute("form", form);
            model.addAttribute("roles", rolRepository.findAll());
            return "pages/admin/usuario-form";
        }
    }

    @PostMapping("/usuarios/{id}/desactivar")
    public String desactivar(@PathVariable Long id, RedirectAttributes redirectAttributes) {
        usuarioService.desactivar(id);
        redirectAttributes.addFlashAttribute("mensaje", "Usuario desactivado.");
        return "redirect:/usuarios";
    }

    @PostMapping("/usuarios/{id}/activar")
    public String activar(@PathVariable Long id, RedirectAttributes redirectAttributes) {
        usuarioService.activar(id);
        redirectAttributes.addFlashAttribute("mensaje", "Usuario activado.");
        return "redirect:/usuarios";
    }
}

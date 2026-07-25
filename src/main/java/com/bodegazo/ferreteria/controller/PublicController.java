package com.bodegazo.ferreteria.controller;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

/**
 * Páginas públicas del sitio: inicio, nosotros y contacto.
 * No requieren autenticación (ver RECURSOS_PUBLICOS en SecurityConfig).
 */
@Controller
public class PublicController {

    @GetMapping({"/", "/inicio"})
    public String inicio(Model model) {
        model.addAttribute("pageTitle", "Inicio");
        return "pages/inicio";
    }

    @GetMapping("/nosotros")
    public String nosotros(Model model) {
        model.addAttribute("pageTitle", "Nosotros");
        return "pages/nosotros";
    }

    @GetMapping("/contacto")
    public String contacto(Model model) {
        model.addAttribute("pageTitle", "Contacto");
        return "pages/contacto";
    }

    /**
     * Procesamiento del formulario de contacto.
     * NOTA: por ahora solo valida y muestra confirmación; el envío real
     * de correo se conecta cuando se implemente el ServiceImpl de
     * notificaciones (usa spring-boot-starter-mail, ya en el pom.xml).
     */
    @PostMapping("/contacto")
    public String enviarContacto(
            @RequestParam String nombre,
            @RequestParam String correo,
            @RequestParam String mensaje,
            HttpServletRequest request,
            Model model) {

        model.addAttribute("pageTitle", "Contacto");
        model.addAttribute("enviado", true);
        model.addAttribute("nombreEnviado", nombre);
        return "pages/contacto";
    }
}

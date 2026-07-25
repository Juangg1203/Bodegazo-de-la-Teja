package com.bodegazo.ferreteria.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

/**
 * Páginas de error personalizadas (403, 404) y de mantenimiento.
 * /error/403 se referencia desde SecurityConfig (accessDeniedPage).
 * /error/404 se registra como página de error global en application
 * properties / WebMvcConfig si se desea interceptar el 404 estándar.
 */
@Controller
public class ErrorPagesController {

    @GetMapping("/error/403")
    public String forbidden(Model model) {
        model.addAttribute("pageTitle", "Acceso denegado");
        return "pages/error-403";
    }

    @GetMapping("/error/404")
    public String notFound(Model model) {
        model.addAttribute("pageTitle", "Página no encontrada");
        return "pages/error-404";
    }

    @GetMapping("/mantenimiento")
    public String mantenimiento(Model model) {
        model.addAttribute("pageTitle", "En mantenimiento");
        return "pages/mantenimiento";
    }
}

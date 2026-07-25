package com.bodegazo.ferreteria.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

/**
 * Placeholder temporal para secciones que aún no se han desarrollado
 * (calculadoras, registro, recuperación de contraseña). Evita enlaces
 * rotos (404) en la navegación mientras se completan las siguientes
 * entregas. Cada una de estas rutas se reemplazará por su controller
 * real cuando se implemente esa funcionalidad específica.
 */
@Controller
public class ComingSoonController {

    @GetMapping({"/registro", "/recuperar-password"})
    public String enConstruccion(Model model) {
        model.addAttribute("pageTitle", "Próximamente");
        return "pages/en-construccion";
    }
}

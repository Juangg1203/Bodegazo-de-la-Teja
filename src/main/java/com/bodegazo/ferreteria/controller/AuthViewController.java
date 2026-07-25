package com.bodegazo.ferreteria.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

/**
 * Vista de login. El procesamiento del formulario (POST /login) lo maneja
 * directamente Spring Security (ver formLogin en SecurityConfig) — este
 * controller solo sirve la página y sus mensajes de estado.
 */
@Controller
public class AuthViewController {

    @GetMapping("/login")
    public String login(
            @RequestParam(required = false) String error,
            @RequestParam(required = false) String logout,
            @RequestParam(required = false) String expired,
            Model model) {

        model.addAttribute("pageTitle", "Iniciar sesión");
        if (error != null) {
            model.addAttribute("error", "Correo o contraseña incorrectos.");
        }
        if (logout != null) {
            model.addAttribute("mensaje", "Sesión cerrada correctamente.");
        }
        if (expired != null) {
            model.addAttribute("error", "Tu sesión expiró porque iniciaste sesión en otro dispositivo.");
        }
        return "pages/login";
    }
}

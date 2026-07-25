package com.bodegazo.ferreteria.controller;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.boot.web.servlet.error.ErrorController;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

/**
 * Intercepta cualquier error no manejado explícitamente (404, 500, etc.)
 * y lo enruta a una vista JSP personalizada según el código de estado,
 * en vez de mostrar la página de error genérica ("Whitelabel") de
 * Spring Boot.
 */
@Controller
public class GlobalErrorController implements ErrorController {

    @RequestMapping("/error")
    public String handleError(HttpServletRequest request, Model model) {
        Object statusCode = request.getAttribute(RequestDispatcher.ERROR_STATUS_CODE);

        if (statusCode != null) {
            int status = Integer.parseInt(statusCode.toString());
            if (status == 403) {
                model.addAttribute("pageTitle", "Acceso denegado");
                return "pages/error-403";
            }
            if (status == 404) {
                model.addAttribute("pageTitle", "Página no encontrada");
                return "pages/error-404";
            }
        }
        model.addAttribute("pageTitle", "Error del sistema");
        return "pages/error-500";
    }
}

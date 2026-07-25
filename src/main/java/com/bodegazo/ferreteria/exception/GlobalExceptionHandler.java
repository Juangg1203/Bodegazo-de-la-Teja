package com.bodegazo.ferreteria.exception;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.servlet.ModelAndView;

/**
 * Manejo centralizado de excepciones de negocio, para no repetir
 * try/catch en cada Controller.
 */
@ControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(RecursoNoEncontradoException.class)
    public ModelAndView manejarRecursoNoEncontrado(RecursoNoEncontradoException ex, HttpServletRequest request) {
        ModelAndView mav = new ModelAndView("pages/error-404");
        mav.addObject("pageTitle", "Página no encontrada");
        mav.setStatus(HttpStatus.NOT_FOUND);
        return mav;
    }
}

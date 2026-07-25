package com.bodegazo.ferreteria.controller;

import com.bodegazo.ferreteria.dto.CalculoMantoResultDTO;
import com.bodegazo.ferreteria.dto.CalculoTejaResultDTO;
import com.bodegazo.ferreteria.service.CalculoService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.math.BigDecimal;

/**
 * Calculadoras públicas de mantos impermeabilizantes y tejas UPVC.
 * Ambas rutas manejan GET (mostrar el formulario) y POST (calcular
 * y mostrar el resultado en la misma página).
 */
@Controller
public class CalculadoraController {

    private final CalculoService calculoService;

    public CalculadoraController(CalculoService calculoService) {
        this.calculoService = calculoService;
    }

    @GetMapping("/calculadora-mantos")
    public String formularioMantos(Model model) {
        model.addAttribute("pageTitle", "Calculadora de Mantos");
        return "pages/calculadora-mantos";
    }

    @PostMapping("/calculadora-mantos")
    public String calcularMantos(
            @RequestParam BigDecimal largo,
            @RequestParam BigDecimal ancho,
            Model model) {

        model.addAttribute("pageTitle", "Calculadora de Mantos");

        if (!dimensionesValidas(largo, ancho, model)) {
            return "pages/calculadora-mantos";
        }

        CalculoMantoResultDTO resultado = calculoService.calcularMantos(largo, ancho);
        model.addAttribute("resultado", resultado);
        return "pages/calculadora-mantos";
    }

    @GetMapping("/calculadora-tejas")
    public String formularioTejas(Model model) {
        model.addAttribute("pageTitle", "Calculadora de Tejas");
        return "pages/calculadora-tejas";
    }

    @PostMapping("/calculadora-tejas")
    public String calcularTejas(
            @RequestParam BigDecimal largo,
            @RequestParam BigDecimal ancho,
            @RequestParam(defaultValue = "COLONIAL") String tipoTeja,
            Model model) {

        model.addAttribute("pageTitle", "Calculadora de Tejas");
        model.addAttribute("tipoTejaSeleccionado", tipoTeja);

        if (!dimensionesValidas(largo, ancho, model)) {
            return "pages/calculadora-tejas";
        }

        CalculoTejaResultDTO resultado = calculoService.calcularTejas(largo, ancho, tipoTeja);
        model.addAttribute("resultado", resultado);
        return "pages/calculadora-tejas";
    }

    private boolean dimensionesValidas(BigDecimal largo, BigDecimal ancho, Model model) {
        if (largo == null || ancho == null
                || largo.compareTo(BigDecimal.ZERO) <= 0
                || ancho.compareTo(BigDecimal.ZERO) <= 0) {
            model.addAttribute("error", "Ingresa un largo y un ancho mayores a cero.");
            return false;
        }
        return true;
    }
}

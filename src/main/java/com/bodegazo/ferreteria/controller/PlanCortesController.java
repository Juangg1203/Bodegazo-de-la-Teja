package com.bodegazo.ferreteria.controller;

import com.bodegazo.ferreteria.dto.PiezaRequeridaDTO;
import com.bodegazo.ferreteria.dto.PlanCortesResultDTO;
import com.bodegazo.ferreteria.service.PlanCortesService;
import com.bodegazo.ferreteria.utils.PdfGeneratorUtil;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

/**
 * Plan de optimización de cortes: para pedidos hechos a la medida (no
 * la cubierta completa, sino una lista de piezas puntuales que hacen
 * falta). Calcula cuántas láminas comprar y exactamente qué corte va
 * en cada una — pensado para dárselo al bodeguero. También genera una
 * versión simple, para el cliente, sin el detalle técnico.
 *
 * Solo para personal (mismo criterio que las calculadoras).
 */
@Controller
public class PlanCortesController {

    private final PlanCortesService planCortesService;
    private final PdfGeneratorUtil pdfGeneratorUtil;

    public PlanCortesController(PlanCortesService planCortesService, PdfGeneratorUtil pdfGeneratorUtil) {
        this.planCortesService = planCortesService;
        this.pdfGeneratorUtil = pdfGeneratorUtil;
    }

    @GetMapping("/plan-cortes")
    public String formulario(Model model) {
        model.addAttribute("pageTitle", "Plan de Cortes");
        return "pages/plan-cortes-form";
    }

    @PostMapping("/plan-cortes")
    public String calcular(
            @RequestParam BigDecimal laminaBase,
            @RequestParam(required = false) List<BigDecimal> largos,
            @RequestParam(required = false) List<Integer> cantidades,
            Model model) {

        model.addAttribute("pageTitle", "Plan de Cortes");
        model.addAttribute("laminaBaseSeleccionada", laminaBase);

        List<PiezaRequeridaDTO> piezas = construirPiezas(largos, cantidades);
        if (piezas.isEmpty()) {
            model.addAttribute("error", "Agrega al menos una medida con su cantidad.");
            return "pages/plan-cortes-form";
        }

        PlanCortesResultDTO resultado = planCortesService.calcularPlan(laminaBase, piezas);
        model.addAttribute("resultado", resultado);
        model.addAttribute("largosOriginal", largos);
        model.addAttribute("cantidadesOriginal", cantidades);
        return "pages/plan-cortes-resultado";
    }

    @PostMapping("/plan-cortes/pdf-bodeguero")
    @ResponseBody
    public ResponseEntity<byte[]> pdfBodeguero(
            @RequestParam BigDecimal laminaBase,
            @RequestParam(required = false) List<BigDecimal> largos,
            @RequestParam(required = false) List<Integer> cantidades) {

        PlanCortesResultDTO resultado = planCortesService.calcularPlan(laminaBase, construirPiezas(largos, cantidades));
        byte[] pdf = pdfGeneratorUtil.generarPlanCortesBodeguero(resultado);
        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_PDF)
                .header(HttpHeaders.CONTENT_DISPOSITION, "inline; filename=plan-cortes-bodega.pdf")
                .body(pdf);
    }

    private List<PiezaRequeridaDTO> construirPiezas(List<BigDecimal> largos, List<Integer> cantidades) {
        List<PiezaRequeridaDTO> piezas = new ArrayList<>();
        if (largos == null || cantidades == null) {
            return piezas;
        }
        int total = Math.min(largos.size(), cantidades.size());
        for (int i = 0; i < total; i++) {
            BigDecimal largo = largos.get(i);
            Integer cantidad = cantidades.get(i);
            if (largo != null && cantidad != null && largo.compareTo(BigDecimal.ZERO) > 0 && cantidad > 0) {
                piezas.add(new PiezaRequeridaDTO(largo, cantidad));
            }
        }
        return piezas;
    }
}

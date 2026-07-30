package com.bodegazo.ferreteria.controller;

import com.bodegazo.ferreteria.dto.VentaDetalleDTO;
import com.bodegazo.ferreteria.dto.VentaResumenDTO;
import com.bodegazo.ferreteria.service.VentaService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;

/**
 * Historial de ventas — personal interno únicamente (ver regla
 * "/ventas/**" en SecurityConfig). Las ventas se generan automáticamente
 * al aceptar una cotización, no se crean manualmente aquí.
 */
@Controller
public class VentaController {

    private static final int TAMANIO_PAGINA = 10;

    private final VentaService ventaService;

    public VentaController(VentaService ventaService) {
        this.ventaService = ventaService;
    }

    @GetMapping("/ventas")
    public String listar(@RequestParam(defaultValue = "0") int pagina, Model model) {
        Page<VentaResumenDTO> resultado = ventaService.listar(
                PageRequest.of(pagina, TAMANIO_PAGINA, Sort.by(Sort.Direction.DESC, "fecha")));
        model.addAttribute("pageTitle", "Ventas");
        model.addAttribute("ventas", resultado);
        return "pages/ventas-lista";
    }

    @GetMapping("/ventas/{id}")
    public String detalle(@PathVariable Long id, Model model) {
        VentaDetalleDTO detalle = ventaService.obtenerDetalle(id);
        model.addAttribute("pageTitle", "Venta #" + id);
        model.addAttribute("venta", detalle);
        return "pages/venta-detalle";
    }
}

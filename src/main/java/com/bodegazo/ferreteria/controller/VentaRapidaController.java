package com.bodegazo.ferreteria.controller;

import com.bodegazo.ferreteria.dto.VentaRapidaFormDTO;
import com.bodegazo.ferreteria.entity.Venta;
import com.bodegazo.ferreteria.repository.ClienteRepository;
import com.bodegazo.ferreteria.repository.ProductoRepository;
import com.bodegazo.ferreteria.security.CustomUserPrincipal;
import com.bodegazo.ferreteria.service.VentaRapidaService;
import org.springframework.data.domain.PageRequest;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

/**
 * Registro rápido de ventas de mostrador — reemplaza el cuaderno
 * manual. Solo para personal que vende (Empleado, Jefe de Bodega,
 * Administrador — misma regla que "/ventas/**").
 */
@Controller
public class VentaRapidaController {

    private final VentaRapidaService ventaRapidaService;
    private final ProductoRepository productoRepository;
    private final ClienteRepository clienteRepository;

    public VentaRapidaController(VentaRapidaService ventaRapidaService, ProductoRepository productoRepository,
                                  ClienteRepository clienteRepository) {
        this.ventaRapidaService = ventaRapidaService;
        this.productoRepository = productoRepository;
        this.clienteRepository = clienteRepository;
    }

    @GetMapping("/ventas/rapida")
    public String formulario(Model model) {
        model.addAttribute("pageTitle", "Venta Rápida");
        model.addAttribute("productos", productoRepository.findByActivoTrue(PageRequest.of(0, 1000)).getContent());
        model.addAttribute("clientes", clienteRepository.findAll());
        model.addAttribute("motivosPago", new String[]{Venta.PAGO_EFECTIVO, Venta.PAGO_CONTRAENTREGA, Venta.PAGO_TARJETA, Venta.PAGO_TRANSFERENCIA});
        return "pages/venta-rapida-form";
    }

    @PostMapping("/ventas/rapida")
    public String registrar(@ModelAttribute VentaRapidaFormDTO form,
                             @AuthenticationPrincipal CustomUserPrincipal usuario,
                             Model model, RedirectAttributes redirectAttributes) {
        try {
            Long ventaId = ventaRapidaService.registrar(form, usuario.getId());
            redirectAttributes.addFlashAttribute("mensaje", "Venta #" + ventaId + " registrada — inventario actualizado.");
            return "redirect:/ventas/" + ventaId;
        } catch (IllegalArgumentException | com.bodegazo.ferreteria.exception.RecursoNoEncontradoException e) {
            model.addAttribute("pageTitle", "Venta Rápida");
            model.addAttribute("error", e.getMessage());
            model.addAttribute("productos", productoRepository.findByActivoTrue(PageRequest.of(0, 1000)).getContent());
            model.addAttribute("clientes", clienteRepository.findAll());
            model.addAttribute("motivosPago", new String[]{Venta.PAGO_EFECTIVO, Venta.PAGO_CONTRAENTREGA, Venta.PAGO_TARJETA, Venta.PAGO_TRANSFERENCIA});
            return "pages/venta-rapida-form";
        }
    }
}

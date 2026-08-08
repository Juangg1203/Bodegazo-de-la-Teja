package com.bodegazo.ferreteria.controller;

import com.bodegazo.ferreteria.dto.EntradaFormDTO;
import com.bodegazo.ferreteria.dto.InventarioResumenDTO;
import com.bodegazo.ferreteria.dto.MovimientoResumenDTO;
import com.bodegazo.ferreteria.dto.SalidaFormDTO;
import com.bodegazo.ferreteria.entity.Salida;
import com.bodegazo.ferreteria.repository.ProductoRepository;
import com.bodegazo.ferreteria.repository.ProveedorRepository;
import com.bodegazo.ferreteria.security.CustomUserPrincipal;
import com.bodegazo.ferreteria.service.InventarioService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

/**
 * Control de inventario — Jefe de Bodega / Administrador (ver regla
 * "/inventario/**" en SecurityConfig).
 */
@Controller
public class InventarioController {

    private static final int TAMANIO_PAGINA = 15;

    private final InventarioService inventarioService;
    private final ProductoRepository productoRepository;
    private final ProveedorRepository proveedorRepository;

    public InventarioController(InventarioService inventarioService,
                                 ProductoRepository productoRepository,
                                 ProveedorRepository proveedorRepository) {
        this.inventarioService = inventarioService;
        this.productoRepository = productoRepository;
        this.proveedorRepository = proveedorRepository;
    }

    @GetMapping("/inventario")
    public String listar(@RequestParam(required = false) String buscar,
                          @RequestParam(defaultValue = "0") int pagina,
                          Model model) {
        Page<InventarioResumenDTO> resultado = inventarioService.listar(
                buscar, PageRequest.of(pagina, TAMANIO_PAGINA, Sort.by("nombre")));
        model.addAttribute("pageTitle", "Inventario");
        model.addAttribute("inventario", resultado);
        model.addAttribute("buscar", buscar);
        return "pages/inventario-lista";
    }

    @GetMapping("/inventario/{productoId}/movimientos")
    public String movimientos(@PathVariable Long productoId,
                               @RequestParam(defaultValue = "0") int pagina,
                               Model model) {
        Page<MovimientoResumenDTO> movimientos = inventarioService.listarMovimientos(
                productoId, PageRequest.of(pagina, TAMANIO_PAGINA));
        model.addAttribute("pageTitle", "Movimientos de inventario");
        model.addAttribute("movimientos", movimientos);
        model.addAttribute("productoId", productoId);
        productoRepository.findById(productoId).ifPresent(p -> model.addAttribute("productoNombre", p.getNombre()));
        return "pages/inventario-movimientos";
    }

    @GetMapping("/inventario/entradas/nueva")
    public String formularioEntrada(Model model) {
        model.addAttribute("pageTitle", "Registrar entrada");
        model.addAttribute("form", new EntradaFormDTO());
        model.addAttribute("productos", productoRepository.findByActivoTrue(PageRequest.of(0, 500)).getContent());
        model.addAttribute("proveedores", proveedorRepository.findByActivoTrue());
        return "pages/inventario-entrada-form";
    }

    @PostMapping("/inventario/entradas")
    public String guardarEntrada(@ModelAttribute("form") EntradaFormDTO form,
                                  @AuthenticationPrincipal CustomUserPrincipal usuario,
                                  RedirectAttributes redirectAttributes) {
        inventarioService.registrarEntrada(form, usuario.getId());
        redirectAttributes.addFlashAttribute("mensaje", "Entrada registrada correctamente. El stock ya quedó actualizado.");
        return "redirect:/inventario";
    }

    @GetMapping("/inventario/salidas/nueva")
    public String formularioSalida(Model model) {
        model.addAttribute("pageTitle", "Registrar salida");
        model.addAttribute("form", new SalidaFormDTO());
        model.addAttribute("productos", productoRepository.findByActivoTrue(PageRequest.of(0, 500)).getContent());
        model.addAttribute("motivos", new String[]{Salida.AJUSTE, Salida.DEVOLUCION, Salida.DANIO});
        return "pages/inventario-salida-form";
    }

    @PostMapping("/inventario/salidas")
    public String guardarSalida(@ModelAttribute("form") SalidaFormDTO form,
                                 @AuthenticationPrincipal CustomUserPrincipal usuario,
                                 Model model,
                                 RedirectAttributes redirectAttributes) {
        try {
            inventarioService.registrarSalida(form, usuario.getId());
            redirectAttributes.addFlashAttribute("mensaje", "Salida registrada correctamente. El stock ya quedó actualizado.");
            return "redirect:/inventario";
        } catch (IllegalArgumentException e) {
            model.addAttribute("pageTitle", "Registrar salida");
            model.addAttribute("error", e.getMessage());
            model.addAttribute("form", form);
            model.addAttribute("productos", productoRepository.findByActivoTrue(PageRequest.of(0, 500)).getContent());
            model.addAttribute("motivos", new String[]{Salida.AJUSTE, Salida.DEVOLUCION, Salida.DANIO});
            return "pages/inventario-salida-form";
        }
    }
}

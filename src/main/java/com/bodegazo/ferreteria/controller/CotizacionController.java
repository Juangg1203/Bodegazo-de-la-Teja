package com.bodegazo.ferreteria.controller;

import com.bodegazo.ferreteria.dto.CotizacionDetalleDTO;
import com.bodegazo.ferreteria.dto.CotizacionResumenDTO;
import com.bodegazo.ferreteria.dto.ItemCarritoDTO;
import com.bodegazo.ferreteria.entity.Cliente;
import com.bodegazo.ferreteria.repository.ClienteRepository;
import com.bodegazo.ferreteria.security.CustomUserPrincipal;
import com.bodegazo.ferreteria.service.CotizacionService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.Collections;
import java.util.List;

/**
 * Cotizaciones: cualquier usuario autenticado puede ver "las suyas";
 * el personal (Empleado/Jefe de Bodega/Administrador) ve todas y puede
 * aceptarlas (genera la venta y descuenta inventario) o rechazarlas.
 */
@Controller
public class CotizacionController {

    private static final int TAMANIO_PAGINA = 10;
    private static final String SESSION_KEY = "carritoCotizacion";

    private final CotizacionService cotizacionService;
    private final ClienteRepository clienteRepository;

    public CotizacionController(CotizacionService cotizacionService, ClienteRepository clienteRepository) {
        this.cotizacionService = cotizacionService;
        this.clienteRepository = clienteRepository;
    }

    private boolean esPersonal(CustomUserPrincipal usuario) {
        return usuario.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("ROLE_EMPLEADO")
                        || a.getAuthority().equals("ROLE_JEFE_BODEGA")
                        || a.getAuthority().equals("ROLE_ADMINISTRADOR"));
    }

    @GetMapping("/cotizaciones")
    public String listar(@AuthenticationPrincipal CustomUserPrincipal usuario,
                          @RequestParam(defaultValue = "0") int pagina,
                          Model model) {

        Sort orden = Sort.by(Sort.Direction.DESC, "fechaEmision");
        Page<CotizacionResumenDTO> resultado;

        if (esPersonal(usuario)) {
            resultado = cotizacionService.listarTodas(PageRequest.of(pagina, TAMANIO_PAGINA, orden));
        } else {
            Cliente cliente = clienteRepository.findByUsuarioId(usuario.getId()).orElse(null);
            resultado = (cliente != null)
                    ? cotizacionService.listarPorCliente(cliente.getId(), PageRequest.of(pagina, TAMANIO_PAGINA))
                    : Page.empty();
        }

        model.addAttribute("pageTitle", "Cotizaciones");
        model.addAttribute("cotizaciones", resultado);
        model.addAttribute("esPersonal", esPersonal(usuario));
        return "pages/cotizaciones-lista";
    }

    @GetMapping("/cotizaciones/{id}")
    public String detalle(@PathVariable Long id, @AuthenticationPrincipal CustomUserPrincipal usuario, Model model) {
        CotizacionDetalleDTO detalle = cotizacionService.obtenerDetalle(id);
        model.addAttribute("pageTitle", "Cotización #" + id);
        model.addAttribute("cotizacion", detalle);
        model.addAttribute("esPersonal", esPersonal(usuario));
        return "pages/cotizacion-detalle";
    }

    @PostMapping("/cotizaciones/confirmar")
    @SuppressWarnings("unchecked")
    public String confirmar(@RequestParam Long clienteId,
                             @AuthenticationPrincipal CustomUserPrincipal usuario,
                             HttpServletRequest request,
                             RedirectAttributes redirectAttributes) {

        HttpSession session = request.getSession();
        Object carritoObj = session.getAttribute(SESSION_KEY);
        List<ItemCarritoDTO> carrito = (carritoObj instanceof List) ? (List<ItemCarritoDTO>) carritoObj : Collections.emptyList();

        if (carrito.isEmpty()) {
            redirectAttributes.addFlashAttribute("error", "Tu carrito de cotización está vacío.");
            return "redirect:/cotizaciones/carrito";
        }

        Long id = cotizacionService.crear(clienteId, usuario.getId(), carrito);
        session.removeAttribute(SESSION_KEY);
        redirectAttributes.addFlashAttribute("mensaje", "Cotización #" + id + " creada correctamente.");
        return "redirect:/cotizaciones/" + id;
    }

    @PostMapping("/cotizaciones/{id}/aceptar")
    public String aceptar(@PathVariable Long id, @AuthenticationPrincipal CustomUserPrincipal usuario,
                           RedirectAttributes redirectAttributes) {
        Long ventaId = cotizacionService.aceptar(id, usuario.getId());
        redirectAttributes.addFlashAttribute("mensaje",
                "Cotización aceptada. Se generó la venta #" + ventaId + " y se descontó el inventario.");
        return "redirect:/cotizaciones/" + id;
    }

    @PostMapping("/cotizaciones/{id}/rechazar")
    public String rechazar(@PathVariable Long id, RedirectAttributes redirectAttributes) {
        cotizacionService.rechazar(id);
        redirectAttributes.addFlashAttribute("mensaje", "Cotización rechazada.");
        return "redirect:/cotizaciones/" + id;
    }
}

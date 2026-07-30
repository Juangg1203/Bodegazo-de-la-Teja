package com.bodegazo.ferreteria.controller;

import com.bodegazo.ferreteria.dto.ItemCarritoDTO;
import com.bodegazo.ferreteria.entity.Producto;
import com.bodegazo.ferreteria.exception.RecursoNoEncontradoException;
import com.bodegazo.ferreteria.repository.ClienteRepository;
import com.bodegazo.ferreteria.repository.ProductoRepository;
import com.bodegazo.ferreteria.security.CustomUserPrincipal;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

/**
 * Carrito de cotización: se guarda en la sesión HTTP (no en la base de
 * datos) mientras el usuario va agregando productos desde el catálogo.
 * Solo se convierte en una Cotizacion real al confirmar.
 */
@Controller
public class CarritoController {

    private static final String SESSION_KEY = "carritoCotizacion";

    private final ProductoRepository productoRepository;
    private final ClienteRepository clienteRepository;

    public CarritoController(ProductoRepository productoRepository, ClienteRepository clienteRepository) {
        this.productoRepository = productoRepository;
        this.clienteRepository = clienteRepository;
    }

    @SuppressWarnings("unchecked")
    private List<ItemCarritoDTO> obtenerCarrito(HttpSession session) {
        Object actual = session.getAttribute(SESSION_KEY);
        if (actual instanceof List) {
            return (List<ItemCarritoDTO>) actual;
        }
        List<ItemCarritoDTO> nuevo = new ArrayList<>();
        session.setAttribute(SESSION_KEY, nuevo);
        return nuevo;
    }

    @PostMapping("/cotizaciones/carrito/agregar")
    public String agregar(
            @RequestParam Long productoId,
            @RequestParam(defaultValue = "1") BigDecimal cantidad,
            HttpServletRequest request,
            RedirectAttributes redirectAttributes) {

        Producto producto = productoRepository.findById(productoId)
                .orElseThrow(() -> new RecursoNoEncontradoException("Producto no encontrado con id: " + productoId));

        List<ItemCarritoDTO> carrito = obtenerCarrito(request.getSession());
        ItemCarritoDTO existente = carrito.stream()
                .filter(i -> i.getProductoId().equals(productoId))
                .findFirst()
                .orElse(null);

        if (existente != null) {
            existente.setCantidad(existente.getCantidad().add(cantidad));
        } else {
            carrito.add(new ItemCarritoDTO(producto.getId(), producto.getNombre(), producto.getCodigo(),
                    producto.getPrecioVenta(), cantidad));
        }

        redirectAttributes.addFlashAttribute("mensaje", "Se agregó \"" + producto.getNombre() + "\" a tu cotización.");
        String referer = request.getHeader("Referer");
        return "redirect:" + (referer != null ? referer : "/productos");
    }

    @PostMapping("/cotizaciones/carrito/quitar/{productoId}")
    public String quitar(@PathVariable Long productoId, HttpServletRequest request) {
        List<ItemCarritoDTO> carrito = obtenerCarrito(request.getSession());
        carrito.removeIf(i -> i.getProductoId().equals(productoId));
        return "redirect:/cotizaciones/carrito";
    }

    @GetMapping("/cotizaciones/carrito")
    public String verCarrito(@AuthenticationPrincipal CustomUserPrincipal usuario, HttpServletRequest request, Model model) {
        List<ItemCarritoDTO> carrito = obtenerCarrito(request.getSession());
        BigDecimal total = carrito.stream().map(ItemCarritoDTO::getSubtotal).reduce(BigDecimal.ZERO, BigDecimal::add);

        boolean esPersonal = usuario.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("ROLE_EMPLEADO")
                        || a.getAuthority().equals("ROLE_JEFE_BODEGA")
                        || a.getAuthority().equals("ROLE_ADMINISTRADOR"));

        model.addAttribute("pageTitle", "Carrito de cotización");
        model.addAttribute("carrito", carrito);
        model.addAttribute("totalCarrito", total);
        model.addAttribute("esPersonal", esPersonal);
        if (esPersonal) {
            model.addAttribute("clientes", clienteRepository.findAll());
        } else {
            model.addAttribute("miCliente", clienteRepository.findByUsuarioId(usuario.getId()).orElse(null));
        }
        return "pages/carrito";
    }
}

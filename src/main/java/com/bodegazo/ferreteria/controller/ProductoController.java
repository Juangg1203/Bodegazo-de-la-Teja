package com.bodegazo.ferreteria.controller;

import com.bodegazo.ferreteria.dto.ProductoDetalleDTO;
import com.bodegazo.ferreteria.dto.ProductoResumenDTO;
import com.bodegazo.ferreteria.entity.Producto;
import com.bodegazo.ferreteria.service.ProductoService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;

/**
 * Catálogo público de productos: listado con filtros/paginación y
 * ficha de detalle. Las rutas de categoría (/impermeabilizantes,
 * /tejas-upvc) son atajos sobre el mismo listado, filtrando por
 * tipo_producto.
 */
@Controller
public class ProductoController {

    private static final int TAMANIO_PAGINA = 12;

    private final ProductoService productoService;

    public ProductoController(ProductoService productoService) {
        this.productoService = productoService;
    }

    @GetMapping("/productos")
    public String listar(
            @RequestParam(required = false) Long categoria,
            @RequestParam(required = false) String buscar,
            @RequestParam(defaultValue = "0") int pagina,
            Model model) {

        Page<ProductoResumenDTO> resultado = productoService.listar(
                null, categoria, buscar, PageRequest.of(pagina, TAMANIO_PAGINA));

        model.addAttribute("pageTitle", "Catálogo de productos");
        model.addAttribute("tituloSeccion", "Catálogo de productos");
        model.addAttribute("productos", resultado);
        model.addAttribute("buscar", buscar);
        return "pages/productos-lista";
    }

    @GetMapping("/impermeabilizantes")
    public String impermeabilizantes(
            @RequestParam(required = false) String buscar,
            @RequestParam(defaultValue = "0") int pagina,
            Model model) {

        Page<ProductoResumenDTO> resultado = productoService.listar(
                Producto.IMPERMEABILIZANTE, null, buscar, PageRequest.of(pagina, TAMANIO_PAGINA));

        model.addAttribute("pageTitle", "Impermeabilizantes");
        model.addAttribute("tituloSeccion", "Impermeabilizantes");
        model.addAttribute("subtituloSeccion", "Línea El Bodegón del Manto");
        model.addAttribute("logoSeccion", "/images/logo-bodegon-manto.png");
        model.addAttribute("productos", resultado);
        model.addAttribute("buscar", buscar);
        return "pages/productos-lista";
    }

    @GetMapping("/tejas-upvc")
    public String tejasUpvc(
            @RequestParam(required = false) String buscar,
            @RequestParam(defaultValue = "0") int pagina,
            Model model) {

        Page<ProductoResumenDTO> resultado = productoService.listar(
                Producto.TEJA_UPVC, null, buscar, PageRequest.of(pagina, TAMANIO_PAGINA));

        model.addAttribute("pageTitle", "Tejas UPVC");
        model.addAttribute("tituloSeccion", "Tejas UPVC");
        model.addAttribute("subtituloSeccion", "Línea Bodegazo de la Teja");
        model.addAttribute("logoSeccion", "/images/logo-bodegazo.png");
        model.addAttribute("productos", resultado);
        model.addAttribute("buscar", buscar);
        return "pages/productos-lista";
    }

    @GetMapping("/productos/{id}")
    public String detalle(@PathVariable Long id, Model model) {
        ProductoDetalleDTO producto = productoService.obtenerPorId(id);
        model.addAttribute("pageTitle", producto.getNombre());
        model.addAttribute("producto", producto);
        return "pages/producto-detalle";
    }
}

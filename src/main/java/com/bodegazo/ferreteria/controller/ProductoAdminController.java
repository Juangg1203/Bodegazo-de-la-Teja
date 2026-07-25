package com.bodegazo.ferreteria.controller;

import com.bodegazo.ferreteria.dto.ProductoFormDTO;
import com.bodegazo.ferreteria.dto.ProductoResumenDTO;
import com.bodegazo.ferreteria.entity.Producto;
import com.bodegazo.ferreteria.repository.CategoriaRepository;
import com.bodegazo.ferreteria.repository.MarcaRepository;
import com.bodegazo.ferreteria.repository.ProveedorRepository;
import com.bodegazo.ferreteria.service.ProductoService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

/**
 * Panel de administración de productos: alta, edición, activar/desactivar
 * (borrado lógico). Restringido a Administrador y Jefe de Bodega — ver
 * la regla "/administracion/**" en SecurityConfig.
 */
@Controller
public class ProductoAdminController {

    private static final int TAMANIO_PAGINA = 10;

    private final ProductoService productoService;
    private final CategoriaRepository categoriaRepository;
    private final MarcaRepository marcaRepository;
    private final ProveedorRepository proveedorRepository;

    public ProductoAdminController(ProductoService productoService,
                                    CategoriaRepository categoriaRepository,
                                    MarcaRepository marcaRepository,
                                    ProveedorRepository proveedorRepository) {
        this.productoService = productoService;
        this.categoriaRepository = categoriaRepository;
        this.marcaRepository = marcaRepository;
        this.proveedorRepository = proveedorRepository;
    }

    @GetMapping("/administracion/productos")
    public String listar(
            @RequestParam(required = false) String buscar,
            @RequestParam(defaultValue = "0") int pagina,
            @RequestParam(defaultValue = "BODEGAZO") String empresa,
            Model model) {

        java.util.List<String> tipos = "MANTO".equalsIgnoreCase(empresa)
                ? java.util.List.of(Producto.IMPERMEABILIZANTE)
                : java.util.List.of(Producto.TEJA_UPVC, Producto.ACCESORIO);

        Page<ProductoResumenDTO> resultado = productoService.listarParaAdmin(
                buscar, tipos, PageRequest.of(pagina, TAMANIO_PAGINA));

        model.addAttribute("pageTitle", "Administrar Productos");
        model.addAttribute("productos", resultado);
        model.addAttribute("buscar", buscar);
        model.addAttribute("empresaActiva", "MANTO".equalsIgnoreCase(empresa) ? "MANTO" : "BODEGAZO");
        return "pages/admin/productos-lista";
    }

    @GetMapping("/administracion/productos/nuevo")
    public String formularioNuevo(@RequestParam(defaultValue = "BODEGAZO") String empresa, Model model) {
        model.addAttribute("pageTitle", "Nuevo Producto");
        model.addAttribute("form", new ProductoFormDTO());
        model.addAttribute("empresaActiva", "MANTO".equalsIgnoreCase(empresa) ? "MANTO" : "BODEGAZO");
        cargarListasDeApoyo(model);
        return "pages/admin/producto-form";
    }

    @GetMapping("/administracion/productos/{id}/editar")
    public String formularioEditar(@PathVariable Long id, Model model) {
        ProductoFormDTO form = productoService.obtenerFormularioPorId(id);
        model.addAttribute("pageTitle", "Editar Producto");
        model.addAttribute("form", form);
        model.addAttribute("empresaActiva",
                Producto.IMPERMEABILIZANTE.equals(form.getTipoProducto()) ? "MANTO" : "BODEGAZO");
        cargarListasDeApoyo(model);
        return "pages/admin/producto-form";
    }

    @PostMapping("/administracion/productos")
    public String guardar(@ModelAttribute("form") ProductoFormDTO form, Model model,
                           RedirectAttributes redirectAttributes) {

        if (!formularioValido(form, model)) {
            model.addAttribute("pageTitle", form.getId() != null ? "Editar Producto" : "Nuevo Producto");
            cargarListasDeApoyo(model);
            return "pages/admin/producto-form";
        }

        Long id = productoService.guardar(form);
        redirectAttributes.addFlashAttribute("mensaje",
                (form.getId() != null ? "Producto actualizado" : "Producto creado") + " correctamente.");
        return "redirect:/administracion/productos/" + id + "/editar";
    }

    @PostMapping("/administracion/productos/{id}/desactivar")
    public String desactivar(@PathVariable Long id, RedirectAttributes redirectAttributes) {
        productoService.desactivar(id);
        redirectAttributes.addFlashAttribute("mensaje", "Producto desactivado.");
        return "redirect:/administracion/productos";
    }

    @PostMapping("/administracion/productos/{id}/activar")
    public String activar(@PathVariable Long id, RedirectAttributes redirectAttributes) {
        productoService.activar(id);
        redirectAttributes.addFlashAttribute("mensaje", "Producto activado.");
        return "redirect:/administracion/productos";
    }

    private boolean formularioValido(ProductoFormDTO form, Model model) {
        if (form.getCodigo() == null || form.getCodigo().isBlank()
                || form.getNombre() == null || form.getNombre().isBlank()
                || form.getTipoProducto() == null || form.getTipoProducto().isBlank()
                || form.getCategoriaId() == null
                || form.getPrecioVenta() == null || form.getCosto() == null) {
            model.addAttribute("error", "Completa código, nombre, tipo, categoría, precio y costo.");
            return false;
        }
        return true;
    }

    private void cargarListasDeApoyo(Model model) {
        model.addAttribute("categorias", categoriaRepository.findByActivoTrue());
        model.addAttribute("marcas", marcaRepository.findByActivoTrue());
        model.addAttribute("proveedores", proveedorRepository.findByActivoTrue());
        model.addAttribute("tiposProducto", new String[]{
                Producto.IMPERMEABILIZANTE, Producto.TEJA_UPVC, Producto.ACCESORIO
        });
    }
}

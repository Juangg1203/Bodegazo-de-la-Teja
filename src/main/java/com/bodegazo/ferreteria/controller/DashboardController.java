package com.bodegazo.ferreteria.controller;

import com.bodegazo.ferreteria.entity.Inventario;
import com.bodegazo.ferreteria.repository.CategoriaRepository;
import com.bodegazo.ferreteria.repository.ClienteRepository;
import com.bodegazo.ferreteria.repository.InventarioRepository;
import com.bodegazo.ferreteria.repository.ProductoRepository;
import com.bodegazo.ferreteria.repository.UsuarioRepository;
import com.bodegazo.ferreteria.security.CustomUserPrincipal;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * Punto de entrada tras el login (defaultSuccessUrl en SecurityConfig).
 * El contenido que se muestra depende del rol del usuario autenticado,
 * dividiendo el trabajo de cada quien:
 *  - ADMINISTRADOR: reportes generales del sistema (conteos, stock bajo).
 *  - JEFE_BODEGA: alerta de inventario con stock bajo, accesos a
 *    calculadoras e inventario.
 *  - EMPLEADO: accesos rápidos a calculadoras y catálogo, para atender
 *    clientes.
 *  - CLIENTE: bienvenida simple con accesos al catálogo y contacto.
 */
@Controller
public class DashboardController {

    private final ProductoRepository productoRepository;
    private final UsuarioRepository usuarioRepository;
    private final CategoriaRepository categoriaRepository;
    private final ClienteRepository clienteRepository;
    private final InventarioRepository inventarioRepository;

    public DashboardController(ProductoRepository productoRepository,
                                UsuarioRepository usuarioRepository,
                                CategoriaRepository categoriaRepository,
                                ClienteRepository clienteRepository,
                                InventarioRepository inventarioRepository) {
        this.productoRepository = productoRepository;
        this.usuarioRepository = usuarioRepository;
        this.categoriaRepository = categoriaRepository;
        this.clienteRepository = clienteRepository;
        this.inventarioRepository = inventarioRepository;
    }

    @GetMapping("/dashboard")
    public String dashboard(@AuthenticationPrincipal CustomUserPrincipal usuario, Model model) {
        model.addAttribute("pageTitle", "Dashboard");
        model.addAttribute("usuario", usuario);

        Set<String> roles = usuario.getAuthorities().stream()
                .map(GrantedAuthority::getAuthority)
                .collect(Collectors.toSet());

        boolean esAdmin = roles.contains("ROLE_ADMINISTRADOR");
        boolean esJefeBodega = roles.contains("ROLE_JEFE_BODEGA");
        boolean esEmpleado = roles.contains("ROLE_EMPLEADO");
        boolean esCliente = roles.contains("ROLE_CLIENTE");

        model.addAttribute("esAdmin", esAdmin);
        model.addAttribute("esJefeBodega", esJefeBodega);
        model.addAttribute("esEmpleado", esEmpleado);
        model.addAttribute("esCliente", esCliente);

        // Reportes generales: solo se calculan para quien los va a ver
        // (Administrador y Jefe de Bodega), para no consultar la base de
        // datos de más en cada visita al dashboard.
        if (esAdmin || esJefeBodega) {
            List<Inventario> stockBajo = inventarioRepository.findConStockBajo();
            model.addAttribute("stockBajo", stockBajo);
            model.addAttribute("cantidadStockBajo", stockBajo.size());
        }

        if (esAdmin) {
            model.addAttribute("totalProductos", productoRepository.count());
            model.addAttribute("totalUsuarios", usuarioRepository.count());
            model.addAttribute("totalCategorias", categoriaRepository.count());
            model.addAttribute("totalClientes", clienteRepository.count());
        }

        return "pages/dashboard";
    }
}

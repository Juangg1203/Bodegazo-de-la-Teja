package com.bodegazo.ferreteria.controller;

import com.bodegazo.ferreteria.entity.Inventario;
import com.bodegazo.ferreteria.entity.Venta;
import com.bodegazo.ferreteria.repository.CategoriaRepository;
import com.bodegazo.ferreteria.repository.ClienteRepository;
import com.bodegazo.ferreteria.repository.DetalleVentaRepository;
import com.bodegazo.ferreteria.repository.InventarioRepository;
import com.bodegazo.ferreteria.repository.ProductoRepository;
import com.bodegazo.ferreteria.repository.UsuarioRepository;
import com.bodegazo.ferreteria.repository.VentaRepository;
import com.bodegazo.ferreteria.security.CustomUserPrincipal;
import org.springframework.data.domain.PageRequest;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * Punto de entrada tras el login (defaultSuccessUrl en SecurityConfig).
 * El contenido que se muestra depende del rol del usuario autenticado,
 * dividiendo el trabajo de cada quien:
 *  - ADMINISTRADOR: reportes generales del sistema (conteos, stock bajo,
 *    gráficos de ventas de los últimos 7 días, productos por categoría
 *    y los más vendidos).
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
    private final VentaRepository ventaRepository;
    private final DetalleVentaRepository detalleVentaRepository;

    public DashboardController(ProductoRepository productoRepository,
                                UsuarioRepository usuarioRepository,
                                CategoriaRepository categoriaRepository,
                                ClienteRepository clienteRepository,
                                InventarioRepository inventarioRepository,
                                VentaRepository ventaRepository,
                                DetalleVentaRepository detalleVentaRepository) {
        this.productoRepository = productoRepository;
        this.usuarioRepository = usuarioRepository;
        this.categoriaRepository = categoriaRepository;
        this.clienteRepository = clienteRepository;
        this.inventarioRepository = inventarioRepository;
        this.ventaRepository = ventaRepository;
        this.detalleVentaRepository = detalleVentaRepository;
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

            cargarGraficos(model);
        }

        return "pages/dashboard";
    }

    private void cargarGraficos(Model model) {
        // --- Gráfico 1: ventas de los últimos 7 días ---
        LocalDate hoy = LocalDate.now();
        LocalDate hace7Dias = hoy.minusDays(6);
        OffsetDateTime desde = hace7Dias.atStartOfDay().atOffset(ZoneOffset.UTC);
        OffsetDateTime hasta = hoy.plusDays(1).atStartOfDay().atOffset(ZoneOffset.UTC);

        List<Venta> ventasRecientes = ventaRepository.findByFechaBetween(desde, hasta);

        Map<LocalDate, BigDecimal> totalesPorDia = new LinkedHashMap<>();
        DateTimeFormatter formatoEtiqueta = DateTimeFormatter.ofPattern("dd/MM");
        for (int i = 0; i < 7; i++) {
            totalesPorDia.put(hace7Dias.plusDays(i), BigDecimal.ZERO);
        }
        for (Venta v : ventasRecientes) {
            LocalDate dia = v.getFecha().toLocalDate();
            totalesPorDia.merge(dia, v.getTotal(), BigDecimal::add);
        }

        List<String> etiquetasVentas = new ArrayList<>();
        List<BigDecimal> valoresVentas = new ArrayList<>();
        for (Map.Entry<LocalDate, BigDecimal> entry : totalesPorDia.entrySet()) {
            etiquetasVentas.add(entry.getKey().format(formatoEtiqueta));
            valoresVentas.add(entry.getValue());
        }
        model.addAttribute("etiquetasVentas", etiquetasVentas);
        model.addAttribute("valoresVentas", valoresVentas);

        // --- Gráfico 2: productos activos por categoría ---
        List<Object[]> categoriasCrudo = productoRepository.contarPorCategoria();
        List<String> etiquetasCategorias = new ArrayList<>();
        List<Long> valoresCategorias = new ArrayList<>();
        for (Object[] fila : categoriasCrudo) {
            etiquetasCategorias.add((String) fila[0]);
            valoresCategorias.add((Long) fila[1]);
        }
        model.addAttribute("etiquetasCategorias", etiquetasCategorias);
        model.addAttribute("valoresCategorias", valoresCategorias);

        // --- Gráfico 3: top 5 productos más vendidos (histórico) ---
        List<Object[]> topCrudo = detalleVentaRepository.topProductosVendidos(PageRequest.of(0, 5));
        List<String> etiquetasTop = new ArrayList<>();
        List<BigDecimal> valoresTop = new ArrayList<>();
        for (Object[] fila : topCrudo) {
            etiquetasTop.add((String) fila[0]);
            valoresTop.add((BigDecimal) fila[1]);
        }
        model.addAttribute("etiquetasTop", etiquetasTop);
        model.addAttribute("valoresTop", valoresTop);
    }
}

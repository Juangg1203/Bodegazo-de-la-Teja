package com.bodegazo.ferreteria.serviceImpl;

import com.bodegazo.ferreteria.dto.ProductoDetalleDTO;
import com.bodegazo.ferreteria.dto.ProductoFormDTO;
import com.bodegazo.ferreteria.dto.ProductoResumenDTO;
import com.bodegazo.ferreteria.entity.Categoria;
import com.bodegazo.ferreteria.entity.Inventario;
import com.bodegazo.ferreteria.entity.Marca;
import com.bodegazo.ferreteria.entity.Producto;
import com.bodegazo.ferreteria.entity.ProductoImagen;
import com.bodegazo.ferreteria.entity.Proveedor;
import com.bodegazo.ferreteria.exception.RecursoNoEncontradoException;
import com.bodegazo.ferreteria.repository.CategoriaRepository;
import com.bodegazo.ferreteria.repository.InventarioRepository;
import com.bodegazo.ferreteria.repository.MarcaRepository;
import com.bodegazo.ferreteria.repository.ProductoRepository;
import com.bodegazo.ferreteria.repository.ProveedorRepository;
import com.bodegazo.ferreteria.service.ProductoService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.io.UncheckedIOException;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.util.List;
import java.util.UUID;

@Service
@Transactional(readOnly = true)
public class ProductoServiceImpl implements ProductoService {

    private final ProductoRepository productoRepository;
    private final CategoriaRepository categoriaRepository;
    private final MarcaRepository marcaRepository;
    private final ProveedorRepository proveedorRepository;
    private final InventarioRepository inventarioRepository;

    @Value("${app.uploads.dir}")
    private String uploadsDir;

    public ProductoServiceImpl(ProductoRepository productoRepository,
                                CategoriaRepository categoriaRepository,
                                MarcaRepository marcaRepository,
                                ProveedorRepository proveedorRepository,
                                InventarioRepository inventarioRepository) {
        this.productoRepository = productoRepository;
        this.categoriaRepository = categoriaRepository;
        this.marcaRepository = marcaRepository;
        this.proveedorRepository = proveedorRepository;
        this.inventarioRepository = inventarioRepository;
    }

    @Override
    public Page<ProductoResumenDTO> listar(String tipoProducto, Long categoriaId, String busqueda, Pageable pageable) {
        Page<Producto> pagina;

        if (busqueda != null && !busqueda.isBlank()) {
            pagina = productoRepository.findByNombreContainingIgnoreCaseAndActivoTrue(busqueda, pageable);
        } else if (categoriaId != null) {
            pagina = productoRepository.findByCategoriaIdAndActivoTrue(categoriaId, pageable);
        } else if (tipoProducto != null && !tipoProducto.isBlank()) {
            pagina = productoRepository.findByTipoProductoAndActivoTrue(tipoProducto, pageable);
        } else {
            pagina = productoRepository.findByActivoTrue(pageable);
        }

        return pagina.map(this::aResumenDTO);
    }

    @Override
    public ProductoDetalleDTO obtenerPorId(Long id) {
        Producto producto = productoRepository.findById(id)
                .orElseThrow(() -> new RecursoNoEncontradoException("Producto no encontrado con id: " + id));
        return aDetalleDTO(producto);
    }

    @Override
    public Page<ProductoResumenDTO> listarParaAdmin(String busqueda, List<String> tiposProducto, Pageable pageable) {
        Page<Producto> pagina = (busqueda != null && !busqueda.isBlank())
                ? productoRepository.findByTipoProductoInAndNombreContainingIgnoreCase(tiposProducto, busqueda, pageable)
                : productoRepository.findByTipoProductoIn(tiposProducto, pageable);
        return pagina.map(this::aResumenDTO);
    }

    @Override
    public ProductoFormDTO obtenerFormularioPorId(Long id) {
        Producto p = productoRepository.findById(id)
                .orElseThrow(() -> new RecursoNoEncontradoException("Producto no encontrado con id: " + id));

        ProductoFormDTO form = new ProductoFormDTO();
        form.setId(p.getId());
        form.setCodigo(p.getCodigo());
        form.setNombre(p.getNombre());
        form.setDescripcion(p.getDescripcion());
        form.setTipoProducto(p.getTipoProducto());
        form.setCategoriaId(p.getCategoria() != null ? p.getCategoria().getId() : null);
        form.setMarcaId(p.getMarca() != null ? p.getMarca().getId() : null);
        form.setProveedorId(p.getProveedor() != null ? p.getProveedor().getId() : null);
        form.setPrecioVenta(p.getPrecioVenta());
        form.setCosto(p.getCosto());
        form.setUnidadMedida(p.getUnidadMedida());
        form.setLargoM(p.getLargoM());
        form.setAnchoM(p.getAnchoM());
        form.setTieneFoilAluminio(p.getTieneFoilAluminio());
        form.setGrosorMm(p.getGrosorMm());
        form.setTieneAdhesivo(p.getTieneAdhesivo());
        form.setImagenActual(p.getImagenPrincipal());
        if (p.getInventario() != null) {
            form.setStockActual(p.getInventario().getStockActual());
            form.setStockMinimo(p.getInventario().getStockMinimo());
            form.setUbicacion(p.getInventario().getUbicacion());
        }
        return form;
    }

    @Override
    @Transactional
    public Long guardar(ProductoFormDTO form) {
        Producto producto = (form.getId() != null)
                ? productoRepository.findById(form.getId())
                    .orElseThrow(() -> new RecursoNoEncontradoException("Producto no encontrado con id: " + form.getId()))
                : new Producto();

        producto.setCodigo(form.getCodigo());
        producto.setNombre(form.getNombre());
        producto.setDescripcion(form.getDescripcion());
        producto.setTipoProducto(form.getTipoProducto());
        producto.setPrecioVenta(form.getPrecioVenta());
        producto.setCosto(form.getCosto());
        producto.setUnidadMedida(form.getUnidadMedida() != null ? form.getUnidadMedida() : "unidad");
        producto.setLargoM(form.getLargoM());
        producto.setAnchoM(form.getAnchoM());
        producto.setTieneFoilAluminio(form.getTieneFoilAluminio());
        producto.setGrosorMm(form.getGrosorMm());
        producto.setTieneAdhesivo(form.getTieneAdhesivo());

        Categoria categoria = categoriaRepository.findById(form.getCategoriaId())
                .orElseThrow(() -> new RecursoNoEncontradoException("Categoría no encontrada con id: " + form.getCategoriaId()));
        producto.setCategoria(categoria);

        if (form.getMarcaId() != null) {
            Marca marca = marcaRepository.findById(form.getMarcaId())
                    .orElseThrow(() -> new RecursoNoEncontradoException("Marca no encontrada con id: " + form.getMarcaId()));
            producto.setMarca(marca);
        } else {
            producto.setMarca(null);
        }

        if (form.getProveedorId() != null) {
            Proveedor proveedor = proveedorRepository.findById(form.getProveedorId())
                    .orElseThrow(() -> new RecursoNoEncontradoException("Proveedor no encontrado con id: " + form.getProveedorId()));
            producto.setProveedor(proveedor);
        } else {
            producto.setProveedor(null);
        }

        if (producto.getId() == null) {
            producto.setActivo(true);
        }

        if (form.getImagen() != null && !form.getImagen().isEmpty()) {
            producto.setImagenPrincipal(guardarImagen(form.getImagen()));
        }

        Producto guardado = productoRepository.save(producto);

        // Inventario: se crea si no existe, o se actualiza si el formulario trajo valores.
        if (form.getStockActual() != null || form.getStockMinimo() != null) {
            Inventario inventario = inventarioRepository.findByProductoId(guardado.getId())
                    .orElseGet(() -> {
                        Inventario nuevo = new Inventario();
                        nuevo.setProducto(guardado);
                        nuevo.setStockActual(BigDecimal.ZERO);
                        nuevo.setStockMinimo(BigDecimal.ZERO);
                        return nuevo;
                    });
            if (form.getStockActual() != null) {
                inventario.setStockActual(form.getStockActual());
            }
            if (form.getStockMinimo() != null) {
                inventario.setStockMinimo(form.getStockMinimo());
            }
            inventario.setUbicacion(form.getUbicacion());
            inventarioRepository.save(inventario);
        }

        return guardado.getId();
    }

    @Override
    @Transactional
    public void desactivar(Long id) {
        Producto producto = productoRepository.findById(id)
                .orElseThrow(() -> new RecursoNoEncontradoException("Producto no encontrado con id: " + id));
        producto.setActivo(false);
        productoRepository.save(producto);
    }

    @Override
    @Transactional
    public void activar(Long id) {
        Producto producto = productoRepository.findById(id)
                .orElseThrow(() -> new RecursoNoEncontradoException("Producto no encontrado con id: " + id));
        producto.setActivo(true);
        productoRepository.save(producto);
    }

    /** Guarda la imagen subida en el directorio de uploads y retorna la URL pública ("/uploads/archivo.ext"). */
    private String guardarImagen(MultipartFile archivo) {
        try {
            Path directorio = Path.of(uploadsDir);
            Files.createDirectories(directorio);

            String extension = "";
            String nombreOriginal = archivo.getOriginalFilename();
            if (nombreOriginal != null && nombreOriginal.contains(".")) {
                extension = nombreOriginal.substring(nombreOriginal.lastIndexOf('.'));
            }
            String nombreArchivo = UUID.randomUUID() + extension;

            Path destino = directorio.resolve(nombreArchivo);
            Files.copy(archivo.getInputStream(), destino, StandardCopyOption.REPLACE_EXISTING);

            return "/uploads/" + nombreArchivo;
        } catch (IOException e) {
            throw new UncheckedIOException("No se pudo guardar la imagen del producto", e);
        }
    }

    private ProductoResumenDTO aResumenDTO(Producto p) {
        BigDecimal stock = p.getInventario() != null ? p.getInventario().getStockActual() : BigDecimal.ZERO;
        return ProductoResumenDTO.builder()
                .id(p.getId())
                .codigo(p.getCodigo())
                .nombre(p.getNombre())
                .tipoProducto(p.getTipoProducto())
                .categoriaNombre(p.getCategoria() != null ? p.getCategoria().getNombre() : null)
                .marcaNombre(p.getMarca() != null ? p.getMarca().getNombre() : null)
                .precioVenta(p.getPrecioVenta())
                .imagenPrincipal(p.getImagenPrincipal())
                .disponible(stock.compareTo(BigDecimal.ZERO) > 0)
                .activo(Boolean.TRUE.equals(p.getActivo()))
                .build();
    }

    private ProductoDetalleDTO aDetalleDTO(Producto p) {
        BigDecimal stock = p.getInventario() != null ? p.getInventario().getStockActual() : BigDecimal.ZERO;
        List<String> galeria = p.getImagenes().stream()
                .map(ProductoImagen::getUrlImagen)
                .toList();

        return ProductoDetalleDTO.builder()
                .id(p.getId())
                .codigo(p.getCodigo())
                .nombre(p.getNombre())
                .descripcion(p.getDescripcion())
                .tipoProducto(p.getTipoProducto())
                .categoriaNombre(p.getCategoria() != null ? p.getCategoria().getNombre() : null)
                .marcaNombre(p.getMarca() != null ? p.getMarca().getNombre() : null)
                .precioVenta(p.getPrecioVenta())
                .unidadMedida(p.getUnidadMedida())
                .largoM(p.getLargoM())
                .anchoM(p.getAnchoM())
                .imagenPrincipal(p.getImagenPrincipal())
                .galeria(galeria)
                .fichaTecnicaPdf(p.getFichaTecnicaPdf())
                .codigoQr(p.getCodigoQr())
                .disponible(stock.compareTo(BigDecimal.ZERO) > 0)
                .stockActual(stock)
                .build();
    }
}

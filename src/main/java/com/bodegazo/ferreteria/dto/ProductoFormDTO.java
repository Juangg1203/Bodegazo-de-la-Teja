package com.bodegazo.ferreteria.dto;

import org.springframework.web.multipart.MultipartFile;

import java.math.BigDecimal;

/**
 * Datos que llegan del formulario de crear/editar producto en el panel
 * de administración. Separado de la entidad JPA para no atar el
 * formulario web directamente al modelo de persistencia.
 */
public class ProductoFormDTO {
    private Long id;
    private String codigo;
    private String nombre;
    private String descripcion;
    private String tipoProducto;
    private Long categoriaId;
    private Long marcaId;
    private Long proveedorId;
    private BigDecimal precioVenta;
    private BigDecimal costo;
    private String unidadMedida;
    private BigDecimal largoM;
    private BigDecimal anchoM;
    private Boolean tieneFoilAluminio;
    private BigDecimal grosorMm;
    private Boolean tieneAdhesivo;
    private MultipartFile imagen;
    private String imagenActual;
    private BigDecimal stockActual;
    private BigDecimal stockMinimo;
    private String ubicacion;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getCodigo() { return codigo; }
    public void setCodigo(String codigo) { this.codigo = codigo; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }

    public String getTipoProducto() { return tipoProducto; }
    public void setTipoProducto(String tipoProducto) { this.tipoProducto = tipoProducto; }

    public Long getCategoriaId() { return categoriaId; }
    public void setCategoriaId(Long categoriaId) { this.categoriaId = categoriaId; }

    public Long getMarcaId() { return marcaId; }
    public void setMarcaId(Long marcaId) { this.marcaId = marcaId; }

    public Long getProveedorId() { return proveedorId; }
    public void setProveedorId(Long proveedorId) { this.proveedorId = proveedorId; }

    public BigDecimal getPrecioVenta() { return precioVenta; }
    public void setPrecioVenta(BigDecimal precioVenta) { this.precioVenta = precioVenta; }

    public BigDecimal getCosto() { return costo; }
    public void setCosto(BigDecimal costo) { this.costo = costo; }

    public String getUnidadMedida() { return unidadMedida; }
    public void setUnidadMedida(String unidadMedida) { this.unidadMedida = unidadMedida; }

    public BigDecimal getLargoM() { return largoM; }
    public void setLargoM(BigDecimal largoM) { this.largoM = largoM; }

    public BigDecimal getAnchoM() { return anchoM; }
    public void setAnchoM(BigDecimal anchoM) { this.anchoM = anchoM; }

    public Boolean getTieneFoilAluminio() { return tieneFoilAluminio; }
    public void setTieneFoilAluminio(Boolean tieneFoilAluminio) { this.tieneFoilAluminio = tieneFoilAluminio; }

    public BigDecimal getGrosorMm() { return grosorMm; }
    public void setGrosorMm(BigDecimal grosorMm) { this.grosorMm = grosorMm; }

    public Boolean getTieneAdhesivo() { return tieneAdhesivo; }
    public void setTieneAdhesivo(Boolean tieneAdhesivo) { this.tieneAdhesivo = tieneAdhesivo; }

    public MultipartFile getImagen() { return imagen; }
    public void setImagen(MultipartFile imagen) { this.imagen = imagen; }

    public String getImagenActual() { return imagenActual; }
    public void setImagenActual(String imagenActual) { this.imagenActual = imagenActual; }

    public BigDecimal getStockActual() { return stockActual; }
    public void setStockActual(BigDecimal stockActual) { this.stockActual = stockActual; }

    public BigDecimal getStockMinimo() { return stockMinimo; }
    public void setStockMinimo(BigDecimal stockMinimo) { this.stockMinimo = stockMinimo; }

    public String getUbicacion() { return ubicacion; }
    public void setUbicacion(String ubicacion) { this.ubicacion = ubicacion; }
}

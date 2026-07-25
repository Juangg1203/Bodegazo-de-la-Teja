package com.bodegazo.ferreteria.entity;

import jakarta.persistence.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "productos")
public class Producto {

    public static final String IMPERMEABILIZANTE = "IMPERMEABILIZANTE";
    public static final String TEJA_UPVC = "TEJA_UPVC";
    public static final String ACCESORIO = "ACCESORIO";

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 30)
    private String codigo;

    @Column(nullable = false, length = 150)
    private String nombre;

    @Column(columnDefinition = "TEXT")
    private String descripcion;

    @Column(name = "tipo_producto", nullable = false, length = 30)
    private String tipoProducto;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "categoria_id", nullable = false)
    private Categoria categoria;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "marca_id")
    private Marca marca;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "proveedor_id")
    private Proveedor proveedor;

    @Column(name = "precio_venta", nullable = false, precision = 12, scale = 2)
    private BigDecimal precioVenta;

    @Column(nullable = false, precision = 12, scale = 2)
    private BigDecimal costo;

    @Column(name = "unidad_medida", nullable = false, length = 20)
    private String unidadMedida = "unidad";

    @Column(name = "largo_m", precision = 6, scale = 2)
    private BigDecimal largoM;

    @Column(name = "ancho_m", precision = 6, scale = 2)
    private BigDecimal anchoM;

    @Column(name = "tiene_foil_aluminio")
    private Boolean tieneFoilAluminio;

    @Column(name = "grosor_mm", precision = 6, scale = 2)
    private BigDecimal grosorMm;

    @Column(name = "tiene_adhesivo")
    private Boolean tieneAdhesivo;

    @Column(name = "imagen_principal", length = 255)
    private String imagenPrincipal;

    @Column(name = "ficha_tecnica_pdf", length = 255)
    private String fichaTecnicaPdf;

    @Column(name = "codigo_qr", length = 255)
    private String codigoQr;

    @Column(nullable = false)
    private Boolean activo = true;

    @CreationTimestamp
    @Column(name = "fecha_creacion", updatable = false)
    private OffsetDateTime fechaCreacion;

    @UpdateTimestamp
    @Column(name = "fecha_actualizacion")
    private OffsetDateTime fechaActualizacion;

    @OneToMany(mappedBy = "producto", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<ProductoImagen> imagenes = new ArrayList<>();

    @OneToOne(mappedBy = "producto", cascade = CascadeType.ALL)
    private Inventario inventario;

    public Producto() {
    }

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

    public Categoria getCategoria() { return categoria; }
    public void setCategoria(Categoria categoria) { this.categoria = categoria; }

    public Marca getMarca() { return marca; }
    public void setMarca(Marca marca) { this.marca = marca; }

    public Proveedor getProveedor() { return proveedor; }
    public void setProveedor(Proveedor proveedor) { this.proveedor = proveedor; }

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

    public String getImagenPrincipal() { return imagenPrincipal; }
    public void setImagenPrincipal(String imagenPrincipal) { this.imagenPrincipal = imagenPrincipal; }

    public String getFichaTecnicaPdf() { return fichaTecnicaPdf; }
    public void setFichaTecnicaPdf(String fichaTecnicaPdf) { this.fichaTecnicaPdf = fichaTecnicaPdf; }

    public String getCodigoQr() { return codigoQr; }
    public void setCodigoQr(String codigoQr) { this.codigoQr = codigoQr; }

    public Boolean getActivo() { return activo; }
    public void setActivo(Boolean activo) { this.activo = activo; }

    public OffsetDateTime getFechaCreacion() { return fechaCreacion; }
    public void setFechaCreacion(OffsetDateTime fechaCreacion) { this.fechaCreacion = fechaCreacion; }

    public OffsetDateTime getFechaActualizacion() { return fechaActualizacion; }
    public void setFechaActualizacion(OffsetDateTime fechaActualizacion) { this.fechaActualizacion = fechaActualizacion; }

    public List<ProductoImagen> getImagenes() { return imagenes; }
    public void setImagenes(List<ProductoImagen> imagenes) { this.imagenes = imagenes; }

    public Inventario getInventario() { return inventario; }
    public void setInventario(Inventario inventario) { this.inventario = inventario; }
}

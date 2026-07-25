package com.bodegazo.ferreteria.dto;

import java.math.BigDecimal;
import java.util.List;

/**
 * Representación completa de un producto para la página de ficha
 * técnica (galería, descripción completa, disponibilidad).
 */
public class ProductoDetalleDTO {
    private Long id;
    private String codigo;
    private String nombre;
    private String descripcion;
    private String tipoProducto;
    private String categoriaNombre;
    private String marcaNombre;
    private BigDecimal precioVenta;
    private String unidadMedida;
    private BigDecimal largoM;
    private BigDecimal anchoM;
    private String imagenPrincipal;
    private List<String> galeria;
    private String fichaTecnicaPdf;
    private String codigoQr;
    private boolean disponible;
    private BigDecimal stockActual;

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

    public String getCategoriaNombre() { return categoriaNombre; }
    public void setCategoriaNombre(String categoriaNombre) { this.categoriaNombre = categoriaNombre; }

    public String getMarcaNombre() { return marcaNombre; }
    public void setMarcaNombre(String marcaNombre) { this.marcaNombre = marcaNombre; }

    public BigDecimal getPrecioVenta() { return precioVenta; }
    public void setPrecioVenta(BigDecimal precioVenta) { this.precioVenta = precioVenta; }

    public String getUnidadMedida() { return unidadMedida; }
    public void setUnidadMedida(String unidadMedida) { this.unidadMedida = unidadMedida; }

    public BigDecimal getLargoM() { return largoM; }
    public void setLargoM(BigDecimal largoM) { this.largoM = largoM; }

    public BigDecimal getAnchoM() { return anchoM; }
    public void setAnchoM(BigDecimal anchoM) { this.anchoM = anchoM; }

    public String getImagenPrincipal() { return imagenPrincipal; }
    public void setImagenPrincipal(String imagenPrincipal) { this.imagenPrincipal = imagenPrincipal; }

    public List<String> getGaleria() { return galeria; }
    public void setGaleria(List<String> galeria) { this.galeria = galeria; }

    public String getFichaTecnicaPdf() { return fichaTecnicaPdf; }
    public void setFichaTecnicaPdf(String fichaTecnicaPdf) { this.fichaTecnicaPdf = fichaTecnicaPdf; }

    public String getCodigoQr() { return codigoQr; }
    public void setCodigoQr(String codigoQr) { this.codigoQr = codigoQr; }

    public boolean isDisponible() { return disponible; }
    public void setDisponible(boolean disponible) { this.disponible = disponible; }

    public BigDecimal getStockActual() { return stockActual; }
    public void setStockActual(BigDecimal stockActual) { this.stockActual = stockActual; }

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private final ProductoDetalleDTO dto = new ProductoDetalleDTO();
        public Builder id(Long v) { dto.id = v; return this; }
        public Builder codigo(String v) { dto.codigo = v; return this; }
        public Builder nombre(String v) { dto.nombre = v; return this; }
        public Builder descripcion(String v) { dto.descripcion = v; return this; }
        public Builder tipoProducto(String v) { dto.tipoProducto = v; return this; }
        public Builder categoriaNombre(String v) { dto.categoriaNombre = v; return this; }
        public Builder marcaNombre(String v) { dto.marcaNombre = v; return this; }
        public Builder precioVenta(BigDecimal v) { dto.precioVenta = v; return this; }
        public Builder unidadMedida(String v) { dto.unidadMedida = v; return this; }
        public Builder largoM(BigDecimal v) { dto.largoM = v; return this; }
        public Builder anchoM(BigDecimal v) { dto.anchoM = v; return this; }
        public Builder imagenPrincipal(String v) { dto.imagenPrincipal = v; return this; }
        public Builder galeria(List<String> v) { dto.galeria = v; return this; }
        public Builder fichaTecnicaPdf(String v) { dto.fichaTecnicaPdf = v; return this; }
        public Builder codigoQr(String v) { dto.codigoQr = v; return this; }
        public Builder disponible(boolean v) { dto.disponible = v; return this; }
        public Builder stockActual(BigDecimal v) { dto.stockActual = v; return this; }
        public ProductoDetalleDTO build() { return dto; }
    }
}

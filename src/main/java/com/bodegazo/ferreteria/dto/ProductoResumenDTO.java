package com.bodegazo.ferreteria.dto;

import java.math.BigDecimal;

/**
 * Representación ligera de un producto para tarjetas de listado
 * (catálogo, resultados de búsqueda). No expone la entidad JPA
 * directamente a la vista.
 */
public class ProductoResumenDTO {
    private Long id;
    private String codigo;
    private String nombre;
    private String tipoProducto;
    private String categoriaNombre;
    private String marcaNombre;
    private BigDecimal precioVenta;
    private String imagenPrincipal;
    private boolean disponible;
    private boolean activo;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getCodigo() { return codigo; }
    public void setCodigo(String codigo) { this.codigo = codigo; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getTipoProducto() { return tipoProducto; }
    public void setTipoProducto(String tipoProducto) { this.tipoProducto = tipoProducto; }

    public String getCategoriaNombre() { return categoriaNombre; }
    public void setCategoriaNombre(String categoriaNombre) { this.categoriaNombre = categoriaNombre; }

    public String getMarcaNombre() { return marcaNombre; }
    public void setMarcaNombre(String marcaNombre) { this.marcaNombre = marcaNombre; }

    public BigDecimal getPrecioVenta() { return precioVenta; }
    public void setPrecioVenta(BigDecimal precioVenta) { this.precioVenta = precioVenta; }

    public String getImagenPrincipal() { return imagenPrincipal; }
    public void setImagenPrincipal(String imagenPrincipal) { this.imagenPrincipal = imagenPrincipal; }

    public boolean isDisponible() { return disponible; }
    public void setDisponible(boolean disponible) { this.disponible = disponible; }

    public boolean isActivo() { return activo; }
    public void setActivo(boolean activo) { this.activo = activo; }

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private final ProductoResumenDTO dto = new ProductoResumenDTO();
        public Builder id(Long v) { dto.id = v; return this; }
        public Builder codigo(String v) { dto.codigo = v; return this; }
        public Builder nombre(String v) { dto.nombre = v; return this; }
        public Builder tipoProducto(String v) { dto.tipoProducto = v; return this; }
        public Builder categoriaNombre(String v) { dto.categoriaNombre = v; return this; }
        public Builder marcaNombre(String v) { dto.marcaNombre = v; return this; }
        public Builder precioVenta(BigDecimal v) { dto.precioVenta = v; return this; }
        public Builder imagenPrincipal(String v) { dto.imagenPrincipal = v; return this; }
        public Builder disponible(boolean v) { dto.disponible = v; return this; }
        public Builder activo(boolean v) { dto.activo = v; return this; }
        public ProductoResumenDTO build() { return dto; }
    }
}

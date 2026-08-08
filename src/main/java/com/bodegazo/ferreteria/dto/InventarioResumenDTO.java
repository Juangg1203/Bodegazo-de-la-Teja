package com.bodegazo.ferreteria.dto;

import java.math.BigDecimal;

public class InventarioResumenDTO {
    private Long productoId;
    private String productoNombre;
    private String productoCodigo;
    private BigDecimal stockActual;
    private BigDecimal stockMinimo;
    private String ubicacion;
    private boolean stockBajo;

    public Long getProductoId() { return productoId; }
    public void setProductoId(Long productoId) { this.productoId = productoId; }

    public String getProductoNombre() { return productoNombre; }
    public void setProductoNombre(String productoNombre) { this.productoNombre = productoNombre; }

    public String getProductoCodigo() { return productoCodigo; }
    public void setProductoCodigo(String productoCodigo) { this.productoCodigo = productoCodigo; }

    public BigDecimal getStockActual() { return stockActual; }
    public void setStockActual(BigDecimal stockActual) { this.stockActual = stockActual; }

    public BigDecimal getStockMinimo() { return stockMinimo; }
    public void setStockMinimo(BigDecimal stockMinimo) { this.stockMinimo = stockMinimo; }

    public String getUbicacion() { return ubicacion; }
    public void setUbicacion(String ubicacion) { this.ubicacion = ubicacion; }

    public boolean isStockBajo() { return stockBajo; }
    public void setStockBajo(boolean stockBajo) { this.stockBajo = stockBajo; }

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private final InventarioResumenDTO dto = new InventarioResumenDTO();
        public Builder productoId(Long v) { dto.productoId = v; return this; }
        public Builder productoNombre(String v) { dto.productoNombre = v; return this; }
        public Builder productoCodigo(String v) { dto.productoCodigo = v; return this; }
        public Builder stockActual(BigDecimal v) { dto.stockActual = v; return this; }
        public Builder stockMinimo(BigDecimal v) { dto.stockMinimo = v; return this; }
        public Builder ubicacion(String v) { dto.ubicacion = v; return this; }
        public Builder stockBajo(boolean v) { dto.stockBajo = v; return this; }
        public InventarioResumenDTO build() { return dto; }
    }
}

package com.bodegazo.ferreteria.dto;

import java.math.BigDecimal;
import java.time.OffsetDateTime;

public class MovimientoResumenDTO {
    private Long id;
    private String productoNombre;
    private String tipoMovimiento;
    private BigDecimal cantidad;
    private BigDecimal stockAnterior;
    private BigDecimal stockNuevo;
    private String usuarioNombre;
    private OffsetDateTime fecha;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getProductoNombre() { return productoNombre; }
    public void setProductoNombre(String productoNombre) { this.productoNombre = productoNombre; }

    public String getTipoMovimiento() { return tipoMovimiento; }
    public void setTipoMovimiento(String tipoMovimiento) { this.tipoMovimiento = tipoMovimiento; }

    public BigDecimal getCantidad() { return cantidad; }
    public void setCantidad(BigDecimal cantidad) { this.cantidad = cantidad; }

    public BigDecimal getStockAnterior() { return stockAnterior; }
    public void setStockAnterior(BigDecimal stockAnterior) { this.stockAnterior = stockAnterior; }

    public BigDecimal getStockNuevo() { return stockNuevo; }
    public void setStockNuevo(BigDecimal stockNuevo) { this.stockNuevo = stockNuevo; }

    public String getUsuarioNombre() { return usuarioNombre; }
    public void setUsuarioNombre(String usuarioNombre) { this.usuarioNombre = usuarioNombre; }

    public OffsetDateTime getFecha() { return fecha; }
    public void setFecha(OffsetDateTime fecha) { this.fecha = fecha; }

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private final MovimientoResumenDTO dto = new MovimientoResumenDTO();
        public Builder id(Long v) { dto.id = v; return this; }
        public Builder productoNombre(String v) { dto.productoNombre = v; return this; }
        public Builder tipoMovimiento(String v) { dto.tipoMovimiento = v; return this; }
        public Builder cantidad(BigDecimal v) { dto.cantidad = v; return this; }
        public Builder stockAnterior(BigDecimal v) { dto.stockAnterior = v; return this; }
        public Builder stockNuevo(BigDecimal v) { dto.stockNuevo = v; return this; }
        public Builder usuarioNombre(String v) { dto.usuarioNombre = v; return this; }
        public Builder fecha(OffsetDateTime v) { dto.fecha = v; return this; }
        public MovimientoResumenDTO build() { return dto; }
    }
}

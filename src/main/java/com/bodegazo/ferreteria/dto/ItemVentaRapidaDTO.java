package com.bodegazo.ferreteria.dto;

import java.math.BigDecimal;

/** Una línea de la venta rápida — el precio es editable por el vendedor (rebajas, negociación en el mostrador). */
public class ItemVentaRapidaDTO {
    private Long productoId;
    private BigDecimal cantidad;
    private BigDecimal precioUnitario;

    public Long getProductoId() { return productoId; }
    public void setProductoId(Long productoId) { this.productoId = productoId; }

    public BigDecimal getCantidad() { return cantidad; }
    public void setCantidad(BigDecimal cantidad) { this.cantidad = cantidad; }

    public BigDecimal getPrecioUnitario() { return precioUnitario; }
    public void setPrecioUnitario(BigDecimal precioUnitario) { this.precioUnitario = precioUnitario; }
}

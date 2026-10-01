package com.bodegazo.ferreteria.dto;

import java.math.BigDecimal;

/** Una pieza que el cliente necesita, con cuántas unidades de esa medida. */
public class PiezaRequeridaDTO {
    private BigDecimal largo;
    private Integer cantidad;

    public PiezaRequeridaDTO() { }

    public PiezaRequeridaDTO(BigDecimal largo, Integer cantidad) {
        this.largo = largo;
        this.cantidad = cantidad;
    }

    public BigDecimal getLargo() { return largo; }
    public void setLargo(BigDecimal largo) { this.largo = largo; }

    public Integer getCantidad() { return cantidad; }
    public void setCantidad(Integer cantidad) { this.cantidad = cantidad; }
}

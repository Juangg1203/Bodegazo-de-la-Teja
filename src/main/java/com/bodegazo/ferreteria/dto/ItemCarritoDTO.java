package com.bodegazo.ferreteria.dto;

import java.io.Serializable;
import java.math.BigDecimal;

/**
 * Un renglón del "carrito" de cotización. Se guarda en la sesión HTTP
 * (no en la base de datos) mientras el cliente arma su cotización desde
 * el catálogo — solo se persiste como Cotizacion/DetalleCotizacion al
 * confirmar.
 */
public class ItemCarritoDTO implements Serializable {
    private Long productoId;
    private String nombre;
    private String codigo;
    private BigDecimal precioUnitario;
    private BigDecimal cantidad;

    public ItemCarritoDTO() {
    }

    public ItemCarritoDTO(Long productoId, String nombre, String codigo, BigDecimal precioUnitario, BigDecimal cantidad) {
        this.productoId = productoId;
        this.nombre = nombre;
        this.codigo = codigo;
        this.precioUnitario = precioUnitario;
        this.cantidad = cantidad;
    }

    public Long getProductoId() { return productoId; }
    public void setProductoId(Long productoId) { this.productoId = productoId; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getCodigo() { return codigo; }
    public void setCodigo(String codigo) { this.codigo = codigo; }

    public BigDecimal getPrecioUnitario() { return precioUnitario; }
    public void setPrecioUnitario(BigDecimal precioUnitario) { this.precioUnitario = precioUnitario; }

    public BigDecimal getCantidad() { return cantidad; }
    public void setCantidad(BigDecimal cantidad) { this.cantidad = cantidad; }

    public BigDecimal getSubtotal() { return precioUnitario.multiply(cantidad); }
}

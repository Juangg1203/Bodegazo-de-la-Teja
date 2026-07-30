package com.bodegazo.ferreteria.dto;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.List;

public class VentaDetalleDTO {
    private Long id;
    private String clienteNombre;
    private String usuarioNombre;
    private OffsetDateTime fecha;
    private BigDecimal subtotal;
    private BigDecimal impuesto;
    private BigDecimal total;
    private String estado;
    private String metodoPago;
    private List<ItemDetalleDTO> items;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getClienteNombre() { return clienteNombre; }
    public void setClienteNombre(String clienteNombre) { this.clienteNombre = clienteNombre; }

    public String getUsuarioNombre() { return usuarioNombre; }
    public void setUsuarioNombre(String usuarioNombre) { this.usuarioNombre = usuarioNombre; }

    public OffsetDateTime getFecha() { return fecha; }
    public void setFecha(OffsetDateTime fecha) { this.fecha = fecha; }

    public BigDecimal getSubtotal() { return subtotal; }
    public void setSubtotal(BigDecimal subtotal) { this.subtotal = subtotal; }

    public BigDecimal getImpuesto() { return impuesto; }
    public void setImpuesto(BigDecimal impuesto) { this.impuesto = impuesto; }

    public BigDecimal getTotal() { return total; }
    public void setTotal(BigDecimal total) { this.total = total; }

    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }

    public String getMetodoPago() { return metodoPago; }
    public void setMetodoPago(String metodoPago) { this.metodoPago = metodoPago; }

    public List<ItemDetalleDTO> getItems() { return items; }
    public void setItems(List<ItemDetalleDTO> items) { this.items = items; }

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private final VentaDetalleDTO dto = new VentaDetalleDTO();
        public Builder id(Long v) { dto.id = v; return this; }
        public Builder clienteNombre(String v) { dto.clienteNombre = v; return this; }
        public Builder usuarioNombre(String v) { dto.usuarioNombre = v; return this; }
        public Builder fecha(OffsetDateTime v) { dto.fecha = v; return this; }
        public Builder subtotal(BigDecimal v) { dto.subtotal = v; return this; }
        public Builder impuesto(BigDecimal v) { dto.impuesto = v; return this; }
        public Builder total(BigDecimal v) { dto.total = v; return this; }
        public Builder estado(String v) { dto.estado = v; return this; }
        public Builder metodoPago(String v) { dto.metodoPago = v; return this; }
        public Builder items(List<ItemDetalleDTO> v) { dto.items = v; return this; }
        public VentaDetalleDTO build() { return dto; }
    }
}

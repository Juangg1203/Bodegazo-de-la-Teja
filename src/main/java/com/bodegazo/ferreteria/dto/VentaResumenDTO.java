package com.bodegazo.ferreteria.dto;

import java.math.BigDecimal;
import java.time.OffsetDateTime;

public class VentaResumenDTO {
    private Long id;
    private String clienteNombre;
    private OffsetDateTime fecha;
    private BigDecimal total;
    private String estado;
    private String metodoPago;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getClienteNombre() { return clienteNombre; }
    public void setClienteNombre(String clienteNombre) { this.clienteNombre = clienteNombre; }

    public OffsetDateTime getFecha() { return fecha; }
    public void setFecha(OffsetDateTime fecha) { this.fecha = fecha; }

    public BigDecimal getTotal() { return total; }
    public void setTotal(BigDecimal total) { this.total = total; }

    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }

    public String getMetodoPago() { return metodoPago; }
    public void setMetodoPago(String metodoPago) { this.metodoPago = metodoPago; }

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private final VentaResumenDTO dto = new VentaResumenDTO();
        public Builder id(Long v) { dto.id = v; return this; }
        public Builder clienteNombre(String v) { dto.clienteNombre = v; return this; }
        public Builder fecha(OffsetDateTime v) { dto.fecha = v; return this; }
        public Builder total(BigDecimal v) { dto.total = v; return this; }
        public Builder estado(String v) { dto.estado = v; return this; }
        public Builder metodoPago(String v) { dto.metodoPago = v; return this; }
        public VentaResumenDTO build() { return dto; }
    }
}

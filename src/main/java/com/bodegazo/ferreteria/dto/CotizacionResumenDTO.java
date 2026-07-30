package com.bodegazo.ferreteria.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.OffsetDateTime;

public class CotizacionResumenDTO {
    private Long id;
    private String clienteNombre;
    private OffsetDateTime fechaEmision;
    private LocalDate fechaValidez;
    private BigDecimal total;
    private String estado;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getClienteNombre() { return clienteNombre; }
    public void setClienteNombre(String clienteNombre) { this.clienteNombre = clienteNombre; }

    public OffsetDateTime getFechaEmision() { return fechaEmision; }
    public void setFechaEmision(OffsetDateTime fechaEmision) { this.fechaEmision = fechaEmision; }

    public LocalDate getFechaValidez() { return fechaValidez; }
    public void setFechaValidez(LocalDate fechaValidez) { this.fechaValidez = fechaValidez; }

    public BigDecimal getTotal() { return total; }
    public void setTotal(BigDecimal total) { this.total = total; }

    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private final CotizacionResumenDTO dto = new CotizacionResumenDTO();
        public Builder id(Long v) { dto.id = v; return this; }
        public Builder clienteNombre(String v) { dto.clienteNombre = v; return this; }
        public Builder fechaEmision(OffsetDateTime v) { dto.fechaEmision = v; return this; }
        public Builder fechaValidez(LocalDate v) { dto.fechaValidez = v; return this; }
        public Builder total(BigDecimal v) { dto.total = v; return this; }
        public Builder estado(String v) { dto.estado = v; return this; }
        public CotizacionResumenDTO build() { return dto; }
    }
}

package com.bodegazo.ferreteria.dto;

import java.util.List;

public class VentaRapidaFormDTO {
    private Long clienteId;              // si se elige un cliente existente
    private String clienteNuevoNombre;   // si es cliente nuevo, se llenan estos en vez de clienteId
    private String clienteNuevoApellido;
    private String clienteNuevoDocumento;
    private String clienteNuevoTelefono;
    private String metodoPago;
    private List<ItemVentaRapidaDTO> items;

    public Long getClienteId() { return clienteId; }
    public void setClienteId(Long clienteId) { this.clienteId = clienteId; }

    public String getClienteNuevoNombre() { return clienteNuevoNombre; }
    public void setClienteNuevoNombre(String clienteNuevoNombre) { this.clienteNuevoNombre = clienteNuevoNombre; }

    public String getClienteNuevoApellido() { return clienteNuevoApellido; }
    public void setClienteNuevoApellido(String clienteNuevoApellido) { this.clienteNuevoApellido = clienteNuevoApellido; }

    public String getClienteNuevoDocumento() { return clienteNuevoDocumento; }
    public void setClienteNuevoDocumento(String clienteNuevoDocumento) { this.clienteNuevoDocumento = clienteNuevoDocumento; }

    public String getClienteNuevoTelefono() { return clienteNuevoTelefono; }
    public void setClienteNuevoTelefono(String clienteNuevoTelefono) { this.clienteNuevoTelefono = clienteNuevoTelefono; }

    public String getMetodoPago() { return metodoPago; }
    public void setMetodoPago(String metodoPago) { this.metodoPago = metodoPago; }

    public List<ItemVentaRapidaDTO> getItems() { return items; }
    public void setItems(List<ItemVentaRapidaDTO> items) { this.items = items; }
}

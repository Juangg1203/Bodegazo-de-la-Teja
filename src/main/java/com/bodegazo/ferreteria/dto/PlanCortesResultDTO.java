package com.bodegazo.ferreteria.dto;

import java.math.BigDecimal;
import java.util.List;

public class PlanCortesResultDTO {

    public static class LaminaCorteDTO {
        private int numero;
        private List<BigDecimal> cortes;
        private BigDecimal totalUsado;
        private BigDecimal sobrante;

        public int getNumero() { return numero; }
        public void setNumero(int numero) { this.numero = numero; }
        public List<BigDecimal> getCortes() { return cortes; }
        public void setCortes(List<BigDecimal> cortes) { this.cortes = cortes; }
        public BigDecimal getTotalUsado() { return totalUsado; }
        public void setTotalUsado(BigDecimal totalUsado) { this.totalUsado = totalUsado; }
        public BigDecimal getSobrante() { return sobrante; }
        public void setSobrante(BigDecimal sobrante) { this.sobrante = sobrante; }
    }

    public static class PiezaResumenDTO {
        private BigDecimal largo;
        private int cantidad;

        public BigDecimal getLargo() { return largo; }
        public void setLargo(BigDecimal largo) { this.largo = largo; }
        public int getCantidad() { return cantidad; }
        public void setCantidad(int cantidad) { this.cantidad = cantidad; }
    }

    public static class PiezaPendienteDTO {
        private BigDecimal largo;
        private int cantidad;
        private String motivo;

        public BigDecimal getLargo() { return largo; }
        public void setLargo(BigDecimal largo) { this.largo = largo; }
        public int getCantidad() { return cantidad; }
        public void setCantidad(int cantidad) { this.cantidad = cantidad; }
        public String getMotivo() { return motivo; }
        public void setMotivo(String motivo) { this.motivo = motivo; }
    }

    private BigDecimal laminaBaseM;
    private int laminasUsadas;
    private BigDecimal materialDisponibleM;
    private BigDecimal materialUsadoM;
    private BigDecimal desperdicioTotalM;
    private List<LaminaCorteDTO> laminas;
    private List<PiezaResumenDTO> resumenCantidades;
    private List<PiezaPendienteDTO> pendientes;

    public BigDecimal getLaminaBaseM() { return laminaBaseM; }
    public void setLaminaBaseM(BigDecimal laminaBaseM) { this.laminaBaseM = laminaBaseM; }
    public int getLaminasUsadas() { return laminasUsadas; }
    public void setLaminasUsadas(int laminasUsadas) { this.laminasUsadas = laminasUsadas; }
    public BigDecimal getMaterialDisponibleM() { return materialDisponibleM; }
    public void setMaterialDisponibleM(BigDecimal materialDisponibleM) { this.materialDisponibleM = materialDisponibleM; }
    public BigDecimal getMaterialUsadoM() { return materialUsadoM; }
    public void setMaterialUsadoM(BigDecimal materialUsadoM) { this.materialUsadoM = materialUsadoM; }
    public BigDecimal getDesperdicioTotalM() { return desperdicioTotalM; }
    public void setDesperdicioTotalM(BigDecimal desperdicioTotalM) { this.desperdicioTotalM = desperdicioTotalM; }
    public List<LaminaCorteDTO> getLaminas() { return laminas; }
    public void setLaminas(List<LaminaCorteDTO> laminas) { this.laminas = laminas; }
    public List<PiezaResumenDTO> getResumenCantidades() { return resumenCantidades; }
    public void setResumenCantidades(List<PiezaResumenDTO> resumenCantidades) { this.resumenCantidades = resumenCantidades; }
    public List<PiezaPendienteDTO> getPendientes() { return pendientes; }
    public void setPendientes(List<PiezaPendienteDTO> pendientes) { this.pendientes = pendientes; }
}

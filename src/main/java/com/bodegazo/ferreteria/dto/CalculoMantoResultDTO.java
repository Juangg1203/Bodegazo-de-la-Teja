package com.bodegazo.ferreteria.dto;

import java.math.BigDecimal;

/**
 * Resultado de la calculadora de mantos impermeabilizantes.
 *
 * Método: se calcula el área efectiva de un rollo (ancho x (largo - traslapo))
 * y se divide el área total a cubrir entre esa área efectiva. La parte
 * entera son los rollos completos necesarios; la parte decimal se convierte
 * a metros lineales sueltos (redondeando siempre hacia arriba), ya que el
 * manto se puede pedir cortado a medida.
 */
public class CalculoMantoResultDTO {
    private BigDecimal largo;
    private BigDecimal ancho;
    private BigDecimal areaUtil;
    private BigDecimal traslapoM;
    private BigDecimal areaEfectivaPorRolloM2;
    private BigDecimal cantidadRollosDecimal;      // ej. 62.6087, el cálculo exacto sin redondear
    private int rollosCompletosNecesarios;
    private BigDecimal metrosSueltosNecesarios;    // 0 si no hace falta ningún corte suelto
    private BigDecimal cantidadRollosEquivalente;  // rollosCompletos + metrosSueltos/largoRollo
    private int cantidadRollos;                    // si solo se compraran rollos completos (referencia)
    private BigDecimal areaComprada;
    private BigDecimal porcentajeDesperdicio;
    private String recomendacionLargo;             // sugerencia de ajuste, si el sobrante es pequeño
    private BigDecimal costoEstimado;

    public BigDecimal getLargo() { return largo; }
    public void setLargo(BigDecimal largo) { this.largo = largo; }

    public BigDecimal getAncho() { return ancho; }
    public void setAncho(BigDecimal ancho) { this.ancho = ancho; }

    public BigDecimal getAreaUtil() { return areaUtil; }
    public void setAreaUtil(BigDecimal areaUtil) { this.areaUtil = areaUtil; }

    public BigDecimal getTraslapoM() { return traslapoM; }
    public void setTraslapoM(BigDecimal traslapoM) { this.traslapoM = traslapoM; }

    public BigDecimal getAreaEfectivaPorRolloM2() { return areaEfectivaPorRolloM2; }
    public void setAreaEfectivaPorRolloM2(BigDecimal areaEfectivaPorRolloM2) { this.areaEfectivaPorRolloM2 = areaEfectivaPorRolloM2; }

    public BigDecimal getCantidadRollosDecimal() { return cantidadRollosDecimal; }
    public void setCantidadRollosDecimal(BigDecimal cantidadRollosDecimal) { this.cantidadRollosDecimal = cantidadRollosDecimal; }

    public int getRollosCompletosNecesarios() { return rollosCompletosNecesarios; }
    public void setRollosCompletosNecesarios(int rollosCompletosNecesarios) { this.rollosCompletosNecesarios = rollosCompletosNecesarios; }

    public BigDecimal getMetrosSueltosNecesarios() { return metrosSueltosNecesarios; }
    public void setMetrosSueltosNecesarios(BigDecimal metrosSueltosNecesarios) { this.metrosSueltosNecesarios = metrosSueltosNecesarios; }

    public BigDecimal getCantidadRollosEquivalente() { return cantidadRollosEquivalente; }
    public void setCantidadRollosEquivalente(BigDecimal cantidadRollosEquivalente) { this.cantidadRollosEquivalente = cantidadRollosEquivalente; }

    public int getCantidadRollos() { return cantidadRollos; }
    public void setCantidadRollos(int cantidadRollos) { this.cantidadRollos = cantidadRollos; }

    public BigDecimal getAreaComprada() { return areaComprada; }
    public void setAreaComprada(BigDecimal areaComprada) { this.areaComprada = areaComprada; }

    public BigDecimal getPorcentajeDesperdicio() { return porcentajeDesperdicio; }
    public void setPorcentajeDesperdicio(BigDecimal porcentajeDesperdicio) { this.porcentajeDesperdicio = porcentajeDesperdicio; }

    public String getRecomendacionLargo() { return recomendacionLargo; }
    public void setRecomendacionLargo(String recomendacionLargo) { this.recomendacionLargo = recomendacionLargo; }

    public BigDecimal getCostoEstimado() { return costoEstimado; }
    public void setCostoEstimado(BigDecimal costoEstimado) { this.costoEstimado = costoEstimado; }

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private final CalculoMantoResultDTO dto = new CalculoMantoResultDTO();
        public Builder largo(BigDecimal v) { dto.largo = v; return this; }
        public Builder ancho(BigDecimal v) { dto.ancho = v; return this; }
        public Builder areaUtil(BigDecimal v) { dto.areaUtil = v; return this; }
        public Builder traslapoM(BigDecimal v) { dto.traslapoM = v; return this; }
        public Builder areaEfectivaPorRolloM2(BigDecimal v) { dto.areaEfectivaPorRolloM2 = v; return this; }
        public Builder cantidadRollosDecimal(BigDecimal v) { dto.cantidadRollosDecimal = v; return this; }
        public Builder rollosCompletosNecesarios(int v) { dto.rollosCompletosNecesarios = v; return this; }
        public Builder metrosSueltosNecesarios(BigDecimal v) { dto.metrosSueltosNecesarios = v; return this; }
        public Builder cantidadRollosEquivalente(BigDecimal v) { dto.cantidadRollosEquivalente = v; return this; }
        public Builder cantidadRollos(int v) { dto.cantidadRollos = v; return this; }
        public Builder areaComprada(BigDecimal v) { dto.areaComprada = v; return this; }
        public Builder porcentajeDesperdicio(BigDecimal v) { dto.porcentajeDesperdicio = v; return this; }
        public Builder recomendacionLargo(String v) { dto.recomendacionLargo = v; return this; }
        public Builder costoEstimado(BigDecimal v) { dto.costoEstimado = v; return this; }
        public CalculoMantoResultDTO build() { return dto; }
    }
}

package com.bodegazo.ferreteria.dto;

import java.math.BigDecimal;

/**
 * Resultado de la calculadora de tejas UPVC.
 */
public class CalculoTejaResultDTO {
    private String tipoTeja;             // "COLONIAL" o "TRAPEZOIDAL"
    private BigDecimal largo;
    private BigDecimal ancho;
    private BigDecimal areaUtil;
    private BigDecimal traslapoLateralM;
    private BigDecimal traslapoLongitudinalM;
    private int hileras;
    private int tejasPorHilera;
    private int cantidadTejas;               // Sección 1: tejas completas, sin optimizar
    private BigDecimal areaCubierta;
    private BigDecimal sobranteAnchoM;   // metros de ancho comprados de más
    private BigDecimal metrosAdicionalesUltimoTramoM; // metros extra realmente necesarios de la última teja (no la teja completa)
    private String recomendacionLargo;   // sugerencia de ajuste de correas, si aplica
    private Integer cantidadTejasOptimizado;    // Sección 2: aprovechando sobrantes entre hileras (null si no aplica)
    private Integer tejasAhorradasOptimizando;  // cuántas tejas se ahorran con la optimización
    private String explicacionOptimizacion;     // cómo se logra el ahorro
    private BigDecimal porcentajeDesperdicio;
    private BigDecimal costoEstimado;

    public String getTipoTeja() { return tipoTeja; }
    public void setTipoTeja(String tipoTeja) { this.tipoTeja = tipoTeja; }

    public BigDecimal getLargo() { return largo; }
    public void setLargo(BigDecimal largo) { this.largo = largo; }

    public BigDecimal getAncho() { return ancho; }
    public void setAncho(BigDecimal ancho) { this.ancho = ancho; }

    public BigDecimal getAreaUtil() { return areaUtil; }
    public void setAreaUtil(BigDecimal areaUtil) { this.areaUtil = areaUtil; }

    public BigDecimal getTraslapoLateralM() { return traslapoLateralM; }
    public void setTraslapoLateralM(BigDecimal traslapoLateralM) { this.traslapoLateralM = traslapoLateralM; }

    public BigDecimal getTraslapoLongitudinalM() { return traslapoLongitudinalM; }
    public void setTraslapoLongitudinalM(BigDecimal traslapoLongitudinalM) { this.traslapoLongitudinalM = traslapoLongitudinalM; }

    public int getHileras() { return hileras; }
    public void setHileras(int hileras) { this.hileras = hileras; }

    public int getTejasPorHilera() { return tejasPorHilera; }
    public void setTejasPorHilera(int tejasPorHilera) { this.tejasPorHilera = tejasPorHilera; }

    public int getCantidadTejas() { return cantidadTejas; }
    public void setCantidadTejas(int cantidadTejas) { this.cantidadTejas = cantidadTejas; }

    public BigDecimal getAreaCubierta() { return areaCubierta; }
    public void setAreaCubierta(BigDecimal areaCubierta) { this.areaCubierta = areaCubierta; }

    public BigDecimal getSobranteAnchoM() { return sobranteAnchoM; }
    public void setSobranteAnchoM(BigDecimal sobranteAnchoM) { this.sobranteAnchoM = sobranteAnchoM; }

    public BigDecimal getMetrosAdicionalesUltimoTramoM() { return metrosAdicionalesUltimoTramoM; }
    public void setMetrosAdicionalesUltimoTramoM(BigDecimal metrosAdicionalesUltimoTramoM) { this.metrosAdicionalesUltimoTramoM = metrosAdicionalesUltimoTramoM; }

    public String getRecomendacionLargo() { return recomendacionLargo; }
    public void setRecomendacionLargo(String recomendacionLargo) { this.recomendacionLargo = recomendacionLargo; }

    public Integer getCantidadTejasOptimizado() { return cantidadTejasOptimizado; }
    public void setCantidadTejasOptimizado(Integer cantidadTejasOptimizado) { this.cantidadTejasOptimizado = cantidadTejasOptimizado; }

    public Integer getTejasAhorradasOptimizando() { return tejasAhorradasOptimizando; }
    public void setTejasAhorradasOptimizando(Integer tejasAhorradasOptimizando) { this.tejasAhorradasOptimizando = tejasAhorradasOptimizando; }

    public String getExplicacionOptimizacion() { return explicacionOptimizacion; }
    public void setExplicacionOptimizacion(String explicacionOptimizacion) { this.explicacionOptimizacion = explicacionOptimizacion; }

    public BigDecimal getPorcentajeDesperdicio() { return porcentajeDesperdicio; }
    public void setPorcentajeDesperdicio(BigDecimal porcentajeDesperdicio) { this.porcentajeDesperdicio = porcentajeDesperdicio; }

    public BigDecimal getCostoEstimado() { return costoEstimado; }
    public void setCostoEstimado(BigDecimal costoEstimado) { this.costoEstimado = costoEstimado; }

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private final CalculoTejaResultDTO dto = new CalculoTejaResultDTO();
        public Builder tipoTeja(String v) { dto.tipoTeja = v; return this; }
        public Builder largo(BigDecimal v) { dto.largo = v; return this; }
        public Builder ancho(BigDecimal v) { dto.ancho = v; return this; }
        public Builder areaUtil(BigDecimal v) { dto.areaUtil = v; return this; }
        public Builder traslapoLateralM(BigDecimal v) { dto.traslapoLateralM = v; return this; }
        public Builder traslapoLongitudinalM(BigDecimal v) { dto.traslapoLongitudinalM = v; return this; }
        public Builder hileras(int v) { dto.hileras = v; return this; }
        public Builder tejasPorHilera(int v) { dto.tejasPorHilera = v; return this; }
        public Builder cantidadTejas(int v) { dto.cantidadTejas = v; return this; }
        public Builder areaCubierta(BigDecimal v) { dto.areaCubierta = v; return this; }
        public Builder sobranteAnchoM(BigDecimal v) { dto.sobranteAnchoM = v; return this; }
        public Builder metrosAdicionalesUltimoTramoM(BigDecimal v) { dto.metrosAdicionalesUltimoTramoM = v; return this; }
        public Builder recomendacionLargo(String v) { dto.recomendacionLargo = v; return this; }
        public Builder cantidadTejasOptimizado(Integer v) { dto.cantidadTejasOptimizado = v; return this; }
        public Builder tejasAhorradasOptimizando(Integer v) { dto.tejasAhorradasOptimizando = v; return this; }
        public Builder explicacionOptimizacion(String v) { dto.explicacionOptimizacion = v; return this; }
        public Builder porcentajeDesperdicio(BigDecimal v) { dto.porcentajeDesperdicio = v; return this; }
        public Builder costoEstimado(BigDecimal v) { dto.costoEstimado = v; return this; }
        public CalculoTejaResultDTO build() { return dto; }
    }
}

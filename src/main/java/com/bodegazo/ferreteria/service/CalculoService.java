package com.bodegazo.ferreteria.service;

import com.bodegazo.ferreteria.dto.CalculoMantoResultDTO;
import com.bodegazo.ferreteria.dto.CalculoTejaResultDTO;

import java.math.BigDecimal;

public interface CalculoService {

    /**
     * Calcula la cantidad de rollos de manto impermeabilizante
     * necesarios para cubrir un área de largo x ancho, respetando el
     * traslapo obligatorio configurado (por defecto 0.80 m).
     */
    CalculoMantoResultDTO calcularMantos(BigDecimal largo, BigDecimal ancho);

    /**
     * Calcula la cantidad de tejas UPVC necesarias para cubrir un área
     * de largo x ancho, respetando los traslapos lateral y
     * longitudinal configurados para el tipo de teja indicado
     * ("COLONIAL" o "TRAPEZOIDAL" — cada una tiene sus propias medidas
     * y traslapos configurados en la tabla "configuraciones").
     */
    CalculoTejaResultDTO calcularTejas(BigDecimal largo, BigDecimal ancho, String tipoTeja);
}

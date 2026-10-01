package com.bodegazo.ferreteria.service;

import com.bodegazo.ferreteria.dto.PiezaRequeridaDTO;
import com.bodegazo.ferreteria.dto.PlanCortesResultDTO;

import java.math.BigDecimal;
import java.util.List;

public interface PlanCortesService {

    /**
     * Calcula el plan óptimo de cortes: en qué lámina va cada pieza, para
     * gastar el menor número de láminas posible y minimizar el desperdicio.
     */
    PlanCortesResultDTO calcularPlan(BigDecimal laminaBaseM, List<PiezaRequeridaDTO> piezas);
}

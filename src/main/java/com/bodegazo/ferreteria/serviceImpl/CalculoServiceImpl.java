package com.bodegazo.ferreteria.serviceImpl;

import com.bodegazo.ferreteria.dto.CalculoMantoResultDTO;
import com.bodegazo.ferreteria.dto.CalculoTejaResultDTO;
import com.bodegazo.ferreteria.repository.ConfiguracionRepository;
import com.bodegazo.ferreteria.service.CalculoService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;

/**
 * Lógica de negocio de las calculadoras de mantos y tejas.
 *
 * Los parámetros de módulo (tamaño de rollo/teja), traslapos y
 * precios de referencia se leen de la tabla "configuraciones", con
 * valores de respaldo por si algún registro no existiera.
 *
 * MÉTODO DE CÁLCULO:
 * - Tejas: cada hilera/fila adicional (lateral y longitudinal) solo aporta
 *   cobertura útil de (tamaño_módulo - traslapo), porque el traslapo se
 *   solapa con la teja anterior en ambas direcciones.
 * - Mantos: las franjas lado a lado (a lo ancho) cubren el ancho completo
 *   del rollo sin pérdida de cobertura entre ellas. El traslapo de 0.80 m
 *   se aplica únicamente a lo largo, cuando un rollo se empalma con el
 *   siguiente para continuar una franja más allá del largo de un solo
 *   rollo (10 m de rollo - 0.80 m de traslapo = 9.2 m de largo útil por
 *   cada rollo adicional).
 *
 * "Metros adicionales del último tramo": en vez de reportar el sobrante que
 * quedaría si se compra el último módulo completo, se reporta cuántos
 * metros REALMENTE hacen falta más allá de lo que ya cubren los módulos
 * anteriores — por ejemplo, con un rollo de 10 m y una franja de 11 m,
 * el primer rollo ya cubre 10 m, así que solo faltan 1 m (no un rollo
 * completo). Útil cuando el material se puede pedir cortado a medida.
 */
@Service
@Transactional(readOnly = true)
public class CalculoServiceImpl implements CalculoService {

    private final ConfiguracionRepository configuracionRepository;

    public CalculoServiceImpl(ConfiguracionRepository configuracionRepository) {
        this.configuracionRepository = configuracionRepository;
    }

    @Override
    public CalculoMantoResultDTO calcularMantos(BigDecimal largo, BigDecimal ancho) {
        BigDecimal anchoRollo = obtenerConfig("MANTO_ANCHO_ROLLO_M", "1.00");
        BigDecimal largoRollo = obtenerConfig("MANTO_LARGO_ROLLO_M", "10.00");
        BigDecimal traslapo = obtenerConfig("MANTO_TRASLAPO_M", "0.80");
        BigDecimal precioReferencia = obtenerConfig("MANTO_PRECIO_REFERENCIA", "85000");

        BigDecimal areaUtil = largo.multiply(ancho);

        // Área efectiva de un rollo: el ancho completo, por el largo útil
        // después de descontar el traslapo (1.00 m x 9.20 m = 9.2 m² por
        // defecto). El área total a cubrir se divide entre esa área
        // efectiva para saber cuántos rollos hacen falta.
        BigDecimal areaEfectivaPorRollo = anchoRollo.multiply(largoRollo.subtract(traslapo));
        BigDecimal cantidadRollosDecimal = areaUtil.divide(areaEfectivaPorRollo, 6, RoundingMode.HALF_UP);

        int rollosCompletosNecesarios = cantidadRollosDecimal.setScale(0, RoundingMode.DOWN).intValue();
        BigDecimal fraccionRollo = cantidadRollosDecimal.subtract(BigDecimal.valueOf(rollosCompletosNecesarios));

        // La parte decimal del rollo se convierte a metros lineales sueltos,
        // redondeando al metro más cercano (ej. 62.6087 rollos -> 62 rollos
        // completos + 6 m sueltos; 62.67 rollos -> 62 rollos + 7 m sueltos).
        BigDecimal metrosSueltosNecesarios = fraccionRollo.multiply(largoRollo).setScale(0, RoundingMode.HALF_UP);
        if (metrosSueltosNecesarios.compareTo(largoRollo) >= 0) {
            // Si el redondeo empuja los metros sueltos a un rollo completo,
            // se cuenta como un rollo más en vez de un corte de 10 m.
            rollosCompletosNecesarios += 1;
            metrosSueltosNecesarios = BigDecimal.ZERO;
        }

        int cantidadRollos = rollosCompletosNecesarios
                + (metrosSueltosNecesarios.compareTo(BigDecimal.ZERO) > 0 ? 1 : 0);
        BigDecimal cantidadRollosEquivalente = redondear(
                BigDecimal.valueOf(rollosCompletosNecesarios)
                        .add(metrosSueltosNecesarios.divide(largoRollo, 4, RoundingMode.HALF_UP)));

        BigDecimal areaComprada = anchoRollo.multiply(largoRollo).multiply(BigDecimal.valueOf(cantidadRollos));
        BigDecimal desperdicio = calcularPorcentajeDesperdicio(areaUtil, areaComprada);

        // El costo refleja lo que realmente se compra: si se puede cortar a
        // medida, se cobra proporcional a los rollos equivalentes, no a
        // rollos completos redondeados hacia arriba.
        BigDecimal costoEstimado = precioReferencia.multiply(cantidadRollosEquivalente);

        String recomendacionLargo = null;
        if (metrosSueltosNecesarios.compareTo(BigDecimal.ZERO) > 0
                && metrosSueltosNecesarios.compareTo(largoRollo.multiply(new BigDecimal("0.30"))) < 0) {
            recomendacionLargo = "Con " + rollosCompletosNecesarios + " rollo(s) completo(s) cubres la mayor parte del área. "
                    + "Solo te faltan " + metrosSueltosNecesarios + " m sueltos ("
                    + metrosSueltosNecesarios.multiply(BigDecimal.valueOf(100)).divide(largoRollo, 0, RoundingMode.HALF_UP)
                    + "% de un rollo completo) — pide ese corte a medida en vez de cargar un rollo entero de más.";
        }

        return CalculoMantoResultDTO.builder()
                .largo(largo)
                .ancho(ancho)
                .areaUtil(redondear(areaUtil))
                .traslapoM(traslapo)
                .areaEfectivaPorRolloM2(redondear(areaEfectivaPorRollo))
                .cantidadRollosDecimal(cantidadRollosDecimal.setScale(2, RoundingMode.HALF_UP))
                .rollosCompletosNecesarios(rollosCompletosNecesarios)
                .metrosSueltosNecesarios(metrosSueltosNecesarios)
                .cantidadRollosEquivalente(cantidadRollosEquivalente)
                .cantidadRollos(cantidadRollos)
                .areaComprada(redondear(areaComprada))
                .porcentajeDesperdicio(desperdicio)
                .recomendacionLargo(recomendacionLargo)
                .costoEstimado(costoEstimado)
                .build();
    }

    @Override
    public CalculoTejaResultDTO calcularTejas(BigDecimal largo, BigDecimal ancho, String tipoTeja) {
        String tipoNormalizado = "TRAPEZOIDAL".equalsIgnoreCase(tipoTeja) ? "TRAPEZOIDAL" : "COLONIAL";
        String prefijo = "TEJA_" + tipoNormalizado + "_";
        boolean esColonial = "COLONIAL".equals(tipoNormalizado);

        // Valores de respaldo por tipo: la teja colonial pierde más largo
        // en el traslapo longitudinal (22 cm) que la trapezoidal (20 cm),
        // y es más angosta (1.05 m vs 1.10 m).
        String traslapoLongitudinalPorDefecto = esColonial ? "22" : "20";
        String anchoModuloPorDefecto = esColonial ? "1.05" : "1.10";

        BigDecimal largoModulo = obtenerConfig(prefijo + "LARGO_MODULO_M", "5.90");
        BigDecimal anchoModulo = obtenerConfig(prefijo + "ANCHO_MODULO_M", anchoModuloPorDefecto);
        BigDecimal traslapoLateral = obtenerConfig(prefijo + "TRASLAPO_LATERAL_CM", "10")
                .divide(BigDecimal.valueOf(100), 4, RoundingMode.HALF_UP); // cm -> m
        BigDecimal traslapoLongitudinal = obtenerConfig(prefijo + "TRASLAPO_LONGITUDINAL_CM", traslapoLongitudinalPorDefecto)
                .divide(BigDecimal.valueOf(100), 4, RoundingMode.HALF_UP); // cm -> m
        BigDecimal precioReferencia = obtenerConfig(prefijo + "PRECIO_REFERENCIA", "99000");

        // La teja Colonial tiene un patrón de "barrigas" (ondas) que se
        // repite cada cierta distancia fija — cualquier corte longitudinal
        // debe caer exactamente en un borde de barriga, si no la onda no
        // encaja al traslaparse con la siguiente pieza. La Trapezoidal no
        // tiene esta restricción: se puede cortar donde haga falta.
        BigDecimal anchoBarriga = esColonial
                ? obtenerConfig("TEJA_COLONIAL_ANCHO_BARRIGA_CM", "22")
                        .divide(BigDecimal.valueOf(100), 4, RoundingMode.HALF_UP)
                : null;

        int hileras = calcularModulosEnDimension(ancho, anchoModulo, traslapoLateral);
        int tejasPorHilera = calcularModulosEnDimension(largo, largoModulo, traslapoLongitudinal);
        int cantidadTejas = hileras * tejasPorHilera;

        BigDecimal areaUtil = largo.multiply(ancho);
        BigDecimal areaCubierta = largoModulo.multiply(anchoModulo).multiply(BigDecimal.valueOf(cantidadTejas));
        BigDecimal desperdicio = calcularPorcentajeDesperdicio(areaUtil, areaCubierta);
        BigDecimal costoEstimado = precioReferencia.multiply(BigDecimal.valueOf(cantidadTejas));

        BigDecimal sobranteAnchoM = redondear(
                coberturaLograda(hileras, anchoModulo, traslapoLateral).subtract(ancho));
        BigDecimal metrosAdicionales = metrosAdicionalesUltimoTramo(largo, largoModulo, traslapoLongitudinal, tejasPorHilera);

        // Sección 2: optimización aprovechando sobrantes. Cuando cada hilera
        // necesita solo un remate pequeño al final, en vez de comprar una
        // teja completa por hilera SOLO para ese remate, se corta una sola
        // teja en varias piezas y se reparten entre las hileras.
        //
        // Cada pieza cortada también se traslapa con la teja anterior para
        // fijarse — así que su largo real no es solo lo que falta cubrir,
        // sino lo que falta + el traslapo longitudinal de esa unión. Para
        // la Colonial, ese largo además se redondea hacia arriba al
        // siguiente borde de barriga (no se puede cortar a mitad de onda).
        Integer cantidadTejasOptimizado = null;
        Integer tejasAhorradas = null;
        String explicacionOptimizacion = null;
        BigDecimal largoPiezaCorte = null;
        if (tejasPorHilera > 1 && hileras > 1
                && metrosAdicionales != null && metrosAdicionales.compareTo(BigDecimal.ZERO) > 0) {
            BigDecimal largoPiezaReal = metrosAdicionales.add(traslapoLongitudinal);
            String notaBarriga = "";
            if (esColonial) {
                BigDecimal ondasNecesarias = largoPiezaReal.divide(anchoBarriga, 0, RoundingMode.CEILING);
                BigDecimal largoPiezaAjustado = ondasNecesarias.multiply(anchoBarriga);
                notaBarriga = " (redondeado a " + ondasNecesarias + " barriga(s) de " + anchoBarriga
                        + " m cada una, porque la teja Colonial solo se puede cortar exactamente en el borde de una barriga)";
                largoPiezaReal = largoPiezaAjustado;
            }
            largoPiezaCorte = largoPiezaReal;

            int piezasPorTeja = largoModulo.divide(largoPiezaReal, 0, RoundingMode.FLOOR)
                    .max(BigDecimal.ONE).intValue();
            int tejasExtraOptimizado = (int) Math.ceil(hileras / (double) piezasPorTeja);
            int cantidadOptimizadaCalc = hileras * (tejasPorHilera - 1) + tejasExtraOptimizado;
            int ahorro = cantidadTejas - cantidadOptimizadaCalc;
            if (ahorro > 0) {
                cantidadTejasOptimizado = cantidadOptimizadaCalc;
                tejasAhorradas = ahorro;
                explicacionOptimizacion = "Cada teja de " + largoModulo + " m rinde " + piezasPorTeja
                        + " pieza(s) de " + largoPiezaReal + " m" + notaBarriga + ". "
                        + "Con eso alcanza para el remate de " + piezasPorTeja + " hileras. "
                        + "En vez de " + hileras + " tejas completas solo para los remates, necesitas " + tejasExtraOptimizado
                        + " — ahorras " + ahorro + " teja(s).";
            }
        }

        return CalculoTejaResultDTO.builder()
                .tipoTeja(tipoNormalizado)
                .largoModuloM(largoModulo)
                .anchoModuloM(anchoModulo)
                .largo(largo)
                .ancho(ancho)
                .areaUtil(redondear(areaUtil))
                .traslapoLateralM(traslapoLateral)
                .traslapoLongitudinalM(traslapoLongitudinal)
                .hileras(hileras)
                .tejasPorHilera(tejasPorHilera)
                .cantidadTejas(cantidadTejas)
                .areaCubierta(redondear(areaCubierta))
                .sobranteAnchoM(sobranteAnchoM)
                .metrosAdicionalesUltimoTramoM(metrosAdicionales)
                .largoPiezaCorteM(largoPiezaCorte)
                .cantidadTejasOptimizado(cantidadTejasOptimizado)
                .tejasAhorradasOptimizando(tejasAhorradas)
                .explicacionOptimizacion(explicacionOptimizacion)
                .porcentajeDesperdicio(desperdicio)
                .costoEstimado(costoEstimado)
                .build();
    }

    /**
     * Cuántos metros hacen falta REALMENTE más allá de lo que ya cubren los
     * módulos anteriores al último (no el módulo completo). Null si un solo
     * módulo ya es suficiente (no hay "último tramo" parcial que reportar).
     */
    private BigDecimal metrosAdicionalesUltimoTramo(BigDecimal dimensionNecesaria, BigDecimal tamanioModulo,
                                                       BigDecimal traslapoMinimo, int cantidadModulos) {
        if (cantidadModulos <= 1) {
            return null;
        }
        BigDecimal coberturaSinUltimoModulo = coberturaLograda(cantidadModulos - 1, tamanioModulo, traslapoMinimo);
        BigDecimal excedente = dimensionNecesaria.subtract(coberturaSinUltimoModulo);
        return redondear(excedente);
    }

    /**
     * Calcula la cobertura total real lograda por una cantidad de módulos en
     * una dimensión con traslapo (cada módulo adicional solo suma
     * tamañoModulo - traslapo, por el solape con el módulo anterior).
     */
    private BigDecimal coberturaLograda(int cantidadModulos, BigDecimal tamanioModulo, BigDecimal traslapo) {
        if (cantidadModulos <= 1) {
            return tamanioModulo;
        }
        BigDecimal coberturaUtilAdicional = tamanioModulo.subtract(traslapo);
        return tamanioModulo.add(coberturaUtilAdicional.multiply(BigDecimal.valueOf(cantidadModulos - 1)));
    }

    /**
     * Calcula cuántos módulos se necesitan para cubrir una dimensión,
     * considerando que cada módulo adicional después del primero solo
     * aporta (tamañoModulo - traslapo) de cobertura útil nueva.
     */
    private int calcularModulosEnDimension(BigDecimal dimension, BigDecimal tamanioModulo, BigDecimal traslapo) {
        if (dimension.compareTo(tamanioModulo) <= 0) {
            return 1;
        }
        BigDecimal coberturaUtilAdicional = tamanioModulo.subtract(traslapo);
        BigDecimal restante = dimension.subtract(tamanioModulo);
        int modulosAdicionales = restante
                .divide(coberturaUtilAdicional, 10, RoundingMode.CEILING)
                .setScale(0, RoundingMode.CEILING)
                .intValue();
        return 1 + modulosAdicionales;
    }

    private BigDecimal calcularPorcentajeDesperdicio(BigDecimal areaUtil, BigDecimal areaComprada) {
        if (areaComprada.compareTo(BigDecimal.ZERO) == 0) {
            return BigDecimal.ZERO;
        }
        return areaComprada.subtract(areaUtil)
                .divide(areaComprada, 4, RoundingMode.HALF_UP)
                .multiply(BigDecimal.valueOf(100))
                .setScale(2, RoundingMode.HALF_UP);
    }

    private BigDecimal redondear(BigDecimal valor) {
        return valor.setScale(2, RoundingMode.HALF_UP);
    }

    private BigDecimal obtenerConfig(String clave, String valorPorDefecto) {
        return configuracionRepository.findByClave(clave)
                .map(c -> new BigDecimal(c.getValor()))
                .orElse(new BigDecimal(valorPorDefecto));
    }
}

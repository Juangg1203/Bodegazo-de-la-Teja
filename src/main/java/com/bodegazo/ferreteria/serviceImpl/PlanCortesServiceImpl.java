package com.bodegazo.ferreteria.serviceImpl;

import com.bodegazo.ferreteria.dto.PiezaRequeridaDTO;
import com.bodegazo.ferreteria.dto.PlanCortesResultDTO;
import com.bodegazo.ferreteria.service.PlanCortesService;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Resuelve el "problema de corte de material" (cutting stock, 1D bin
 * packing): dada una lista de piezas que hacen falta y el largo de la
 * lámina/teja base, calcula en qué lámina va cada corte, gastando el
 * menor número de láminas posible y dejando el menor sobrante posible.
 *
 * ALGORITMO — combinación óptima por lámina (subset-sum):
 * En vez de ir colocando pieza por pieza en la primera lámina que "más
 * o menos" le quede bien (lo que puede dejar huecos como 3.60+3.60+3.60
 * = 1.00 m de sobrante, en vez de mezclar con piezas más chicas), cada
 * lámina se arma así:
 *   1. Se toma la pieza más grande que quede disponible como "semilla".
 *   2. Con el espacio que le sobra a esa lámina, se busca por
 *      programación dinámica (subset-sum) la MEJOR combinación posible
 *      entre TODAS las piezas restantes — no la primera que quepa, sino
 *      la que más llena la lámina, mezclando tamaños si hace falta
 *      (ej. 3.60+3.60+2.10+2.10 en vez de dejar el hueco de 1.00 m).
 *   3. Esa lámina se cierra, se descuentan las piezas usadas, y se
 *      repite con las que quedan.
 * Al final se aplica un paso adicional de CONSOLIDACIÓN: si los cortes
 * de la lámina con más desperdicio caben repartidos en las demás ya
 * abiertas, se elimina esa lámina por completo.
 *
 * Las medidas se trabajan en centímetros enteros (redondeando) para que
 * la búsqueda de combinaciones sea exacta y rápida.
 */
@Service
public class PlanCortesServiceImpl implements PlanCortesService {

    /**
     * Margen que se reserva por cada corte, en centímetros, para el
     * ancho del disco de la pulidora — con muchos cortes por lámina,
     * ignorar esto puede dejar el plan calculado más ajustado de lo que
     * en realidad se puede cortar. Mejor dejar un poco de sobrante de
     * más que quedar corto en obra.
     */
    /** Ninguna lámina debe quedar con más sobrante que esto. */
    private static final BigDecimal UMBRAL_SOBRANTE_MAXIMO_M = new BigDecimal("1.00");

    private static class LaminaAbierta {
        List<BigDecimal> cortes = new ArrayList<>();
        BigDecimal usado = BigDecimal.ZERO;
    }

    @Override
    public PlanCortesResultDTO calcularPlan(BigDecimal laminaBaseM, List<PiezaRequeridaDTO> piezas) {
        // 1) Aplanar la lista (largo, cantidad) en piezas individuales,
        //    separando las que son más largas que la lámina misma (esas
        //    nunca van a caber, sin importar el algoritmo).
        List<BigDecimal> itemsAEmpacar = new ArrayList<>();
        List<PlanCortesResultDTO.PiezaPendienteDTO> pendientes = new ArrayList<>();
        Map<BigDecimal, Integer> resumenMap = new LinkedHashMap<>();

        for (PiezaRequeridaDTO pieza : piezas) {
            if (pieza.getLargo() == null || pieza.getCantidad() == null || pieza.getCantidad() <= 0) {
                continue;
            }
            resumenMap.merge(pieza.getLargo(), pieza.getCantidad(), Integer::sum);

            if (pieza.getLargo().compareTo(laminaBaseM) > 0) {
                PlanCortesResultDTO.PiezaPendienteDTO pendiente = new PlanCortesResultDTO.PiezaPendienteDTO();
                pendiente.setLargo(pieza.getLargo());
                pendiente.setCantidad(pieza.getCantidad());
                pendiente.setMotivo("Más larga que la lámina base (" + laminaBaseM + " m) — se necesita una lámina más larga.");
                pendientes.add(pendiente);
                continue;
            }
            for (int i = 0; i < pieza.getCantidad(); i++) {
                itemsAEmpacar.add(pieza.getLargo());
            }
        }

        // 2) Ordenar el pool para elegir semillas: se prioriza el tamaño
        //    que PEOR encaja por sí solo (el que más sobrante deja si se
        //    llenara una lámina solo con ese tamaño) — así se combina con
        //    otros tamaños desde el principio, en vez de dejarlo varado
        //    al final sin nada más grande con qué mezclarse. Ejemplo: si
        //    hay 51 piezas de 1.68 m, 51 no es múltiplo exacto de las 7
        //    que caben por lámina — mejor resolver ese sobrante ya, con
        //    todo el resto de piezas todavía disponibles para rellenar.
        int capacidadCmParaOrden = laminaBaseM.multiply(BigDecimal.valueOf(100)).setScale(0, RoundingMode.HALF_UP).intValue();
        Map<BigDecimal, Integer> remanentePorTamanio = new java.util.HashMap<>();
        for (BigDecimal valor : itemsAEmpacar) {
            remanentePorTamanio.computeIfAbsent(valor, v -> {
                int valorCm = v.multiply(BigDecimal.valueOf(100)).setScale(0, RoundingMode.HALF_UP).intValue();
                int porLamina = valorCm > 0 ? capacidadCmParaOrden / valorCm : 0;
                return capacidadCmParaOrden - porLamina * valorCm;
            });
        }
        itemsAEmpacar.sort((a, b) -> {
            int cmp = remanentePorTamanio.get(b).compareTo(remanentePorTamanio.get(a)); // peor remanente primero
            return cmp != 0 ? cmp : b.compareTo(a); // empate: el más grande primero
        });

        // 3) Armar cada lámina buscando la MEJOR combinación posible entre
        //    las piezas que queden disponibles (subset-sum en centímetros
        //    enteros), no solo la primera que quepa.
        int capacidadCm = capacidadCmParaOrden;
        List<BigDecimal> pool = new ArrayList<>(itemsAEmpacar);
        List<LaminaAbierta> laminas = new ArrayList<>();

        while (!pool.isEmpty()) {
            BigDecimal semilla = pool.remove(0); // según la prioridad calculada arriba
            int semillaCm = semilla.multiply(BigDecimal.valueOf(100)).setScale(0, RoundingMode.HALF_UP).intValue();
            int capacidadRestanteCm = capacidadCm - semillaCm;

            LaminaAbierta lamina = new LaminaAbierta();
            lamina.cortes.add(semilla);
            lamina.usado = semilla;

            if (capacidadRestanteCm > 0 && !pool.isEmpty()) {
                List<Integer> pesosCm = new ArrayList<>();
                for (BigDecimal item : pool) {
                    int valorCm = item.multiply(BigDecimal.valueOf(100)).setScale(0, RoundingMode.HALF_UP).intValue();
                    pesosCm.add(valorCm);
                }
                List<Integer> indicesElegidos = mejorCombinacion(pesosCm, capacidadRestanteCm);
                // Se quitan del pool de mayor índice a menor, para no
                // desordenar los índices todavía pendientes de remover.
                indicesElegidos.sort(Comparator.reverseOrder());
                for (int idx : indicesElegidos) {
                    BigDecimal pieza = pool.remove(idx);
                    lamina.cortes.add(pieza);
                    lamina.usado = lamina.usado.add(pieza);
                }
            }

            laminas.add(lamina);
        }

        // 3.5) Consolidación: si los cortes de la lámina peor aprovechada
        //      caben repartidos en las demás láminas ya abiertas, se
        //      elimina esa lámina por completo — menos láminas usadas es
        //      lo que de verdad reduce el desperdicio total (no solo
        //      repartirlo mejor dentro de las que ya se van a comprar).
        laminas = consolidarLaminas(laminas, laminaBaseM);

        // 3.6) Reparación de sobrantes altos: ninguna lámina debe quedar
        //      con más de UMBRAL_SOBRANTE_MAXIMO_M de sobrante. Si alguna
        //      lo supera, se le "presta" una pieza de otra lámina que sí
        //      tenga espacio de sobra — sin que esa otra lámina termine
        //      pasándose también del límite. No hace falta que los cortes
        //      queden simétricos entre láminas; solo que ninguna quede
        //      con demasiado desperdicio.
        repararSobrantesAltos(laminas, laminaBaseM);

        // 4) Armar el resultado
        List<PlanCortesResultDTO.LaminaCorteDTO> laminasDTO = new ArrayList<>();
        BigDecimal materialUsadoTotal = BigDecimal.ZERO;
        int numero = 1;
        for (LaminaAbierta lamina : laminas) {
            // Los cortes se muestran de mayor a menor dentro de cada lámina (mismo orden en que se armó el plan)
            lamina.cortes.sort(Comparator.reverseOrder());

            PlanCortesResultDTO.LaminaCorteDTO dto = new PlanCortesResultDTO.LaminaCorteDTO();
            dto.setNumero(numero++);
            dto.setCortes(lamina.cortes);
            dto.setTotalUsado(redondear(lamina.usado));
            dto.setSobrante(redondear(laminaBaseM.subtract(lamina.usado)));
            laminasDTO.add(dto);
            materialUsadoTotal = materialUsadoTotal.add(lamina.usado);
        }

        BigDecimal materialDisponible = laminaBaseM.multiply(BigDecimal.valueOf(laminas.size()));
        BigDecimal desperdicioTotal = materialDisponible.subtract(materialUsadoTotal);

        List<PlanCortesResultDTO.PiezaResumenDTO> resumenDTO = new ArrayList<>();
        for (Map.Entry<BigDecimal, Integer> entry : resumenMap.entrySet()) {
            PlanCortesResultDTO.PiezaResumenDTO r = new PlanCortesResultDTO.PiezaResumenDTO();
            r.setLargo(entry.getKey());
            r.setCantidad(entry.getValue());
            resumenDTO.add(r);
        }
        resumenDTO.sort((a, b) -> b.getLargo().compareTo(a.getLargo()));

        PlanCortesResultDTO resultado = new PlanCortesResultDTO();
        resultado.setLaminaBaseM(laminaBaseM);
        resultado.setLaminasUsadas(laminas.size());
        resultado.setMaterialDisponibleM(redondear(materialDisponible));
        resultado.setMaterialUsadoM(redondear(materialUsadoTotal));
        resultado.setDesperdicioTotalM(redondear(desperdicioTotal));
        resultado.setLaminas(laminasDTO);
        resultado.setResumenCantidades(resumenDTO);
        resultado.setPendientes(pendientes);
        return resultado;
    }

    private BigDecimal redondear(BigDecimal valor) {
        return valor.setScale(2, RoundingMode.HALF_UP);
    }

    /**
     * Recorre las láminas y, mientras alguna quede con más de
     * UMBRAL_SOBRANTE_MAXIMO_M de sobrante, le "presta" una pieza de la
     * lámina que más ayude — permitiendo que el donante quede temporalmente
     * mal (hasta el mismo peor sobrante que ya había en el plan), porque
     * en este problema TODAS las piezas suelen ser más grandes que el
     * propio límite de 1 m, así que exigirle al donante quedar siempre
     * perfecto haría que ningún préstamo fuera posible nunca. Como el
     * donante se sigue recorriendo en las siguientes vueltas, cualquier
     * lámina que quede mal por prestar también tiene su oportunidad de
     * arreglarse después.
     *
     * Nota honesta: con piezas donde ninguna es más chica que el propio
     * límite (ej. pedir ≤1.00 m de sobrante cuando la pieza más chica ya
     * mide 1.30 m), puede que technicamente no exista ninguna combinación
     * que cumpla el límite sin agregar una lámina extra — en ese caso
     * esto deja el resultado lo más cerca posible del límite, no
     * garantiza cumplirlo al 100%.
     */
    private void repararSobrantesAltos(List<LaminaAbierta> laminas, BigDecimal laminaBaseM) {
        for (int vuelta = 0; vuelta < 2000; vuelta++) {
            BigDecimal maximoActual = laminas.stream()
                    .map(l -> sobranteReal(laminaBaseM, l))
                    .max(Comparator.naturalOrder())
                    .orElse(BigDecimal.ZERO);
            if (maximoActual.compareTo(UMBRAL_SOBRANTE_MAXIMO_M) <= 0) {
                break; // todas las láminas ya cumplen el límite
            }

            LaminaAbierta mejorDonante = null;
            BigDecimal mejorPieza = null;
            LaminaAbierta mejorReceptor = null;
            BigDecimal mejorPeorResultante = null;

            for (LaminaAbierta receptor : laminas) {
                BigDecimal sobranteReceptor = sobranteReal(laminaBaseM, receptor);
                if (sobranteReceptor.compareTo(UMBRAL_SOBRANTE_MAXIMO_M) <= 0) {
                    continue;
                }
                for (LaminaAbierta donante : laminas) {
                    if (donante == receptor) {
                        continue;
                    }
                    for (BigDecimal pieza : donante.cortes) {
                        BigDecimal sobranteReceptorNuevo = sobranteReceptor.subtract(pieza);
                        if (sobranteReceptorNuevo.compareTo(BigDecimal.ZERO) < 0) {
                            continue;
                        }
                        BigDecimal sobranteDonanteActual = sobranteReal(laminaBaseM, donante);
                        BigDecimal sobranteDonanteNuevo = sobranteDonanteActual.add(pieza);

                        // Criterio MINIMAX: en vez de preferir el préstamo
                        // que más mejora al receptor de un solo golpe (lo
                        // que suele acabar tomando una pieza grande de una
                        // lámina perfecta y solo TRASLADAR el mismo
                        // problema a otro lado sin resolver nada), se
                        // prefiere el que deje MENOR el peor de los dos
                        // sobrantes resultantes — así, repartir el
                        // faltante entre varias piezas chicas de distintas
                        // láminas gana sobre mover una sola pieza grande.
                        BigDecimal peorResultante = sobranteReceptorNuevo.max(sobranteDonanteNuevo);
                        if (peorResultante.compareTo(maximoActual) >= 0) {
                            continue; // no mejora el peor caso global, se descarta
                        }
                        if (mejorPieza == null || peorResultante.compareTo(mejorPeorResultante) < 0) {
                            mejorDonante = donante;
                            mejorPieza = pieza;
                            mejorReceptor = receptor;
                            mejorPeorResultante = peorResultante;
                        }
                    }
                }
            }

            if (mejorPieza == null) {
                break; // no hay ningún préstamo más que ayude
            }
            mejorDonante.cortes.remove(mejorPieza);
            mejorDonante.usado = mejorDonante.usado.subtract(mejorPieza);
            mejorReceptor.cortes.add(mejorPieza);
            mejorReceptor.usado = mejorReceptor.usado.add(mejorPieza);
        }
    }

    /** Sobrante real de una lámina. */
    private BigDecimal sobranteReal(BigDecimal laminaBaseM, LaminaAbierta lamina) {
        return laminaBaseM.subtract(lamina.usado);
    }

    /**
     * Busca, entre una lista de pesos disponibles (en centímetros
     * enteros), el subconjunto cuya suma sea la MÁS CERCANA posible a la
     * capacidad dada sin pasarse — es decir, la combinación que mejor
     * llena ese espacio. Devuelve los índices (sobre la lista recibida)
     * de las piezas elegidas.
     *
     * Es un subset-sum clásico resuelto por programación dinámica:
     * dp[i][c] = ¿se puede lograr la suma exacta c usando solo las
     * primeras i piezas? Con pocas decenas o centenas de piezas y una
     * capacidad de unos pocos miles de centímetros, esto es prácticamente
     * instantáneo.
     */
    private List<Integer> mejorCombinacion(List<Integer> pesos, int capacidad) {
        int n = pesos.size();
        boolean[][] dp = new boolean[n + 1][capacidad + 1];
        dp[0][0] = true;

        for (int i = 1; i <= n; i++) {
            int peso = pesos.get(i - 1);
            for (int c = 0; c <= capacidad; c++) {
                dp[i][c] = dp[i - 1][c];
                if (!dp[i][c] && c >= peso && dp[i - 1][c - peso]) {
                    dp[i][c] = true;
                }
            }
        }

        int mejorSuma = 0;
        for (int c = capacidad; c >= 0; c--) {
            if (dp[n][c]) {
                mejorSuma = c;
                break;
            }
        }

        List<Integer> indicesUsados = new ArrayList<>();
        int c = mejorSuma;
        for (int i = n; i >= 1 && c >= 0; i--) {
            if (!dp[i - 1][c]) {
                indicesUsados.add(i - 1);
                c -= pesos.get(i - 1);
            }
        }
        return indicesUsados;
    }

    /**
     * Intenta reducir el número de láminas: mientras la lámina con MÁS
     * desperdicio pueda "desarmarse" (todos sus cortes reubicados en las
     * demás láminas abiertas, con el mismo criterio de mejor ajuste),
     * se elimina esa lámina. Se repite hasta que ya no se pueda eliminar
     * ninguna más.
     */
    private List<LaminaAbierta> consolidarLaminas(List<LaminaAbierta> laminas, BigDecimal laminaBaseM) {
        boolean seEliminoAlguna = true;

        while (seEliminoAlguna && laminas.size() > 1) {
            seEliminoAlguna = false;

            // Se prueba primero con la lámina que tiene más desperdicio —
            // es la que más conviene "desarmar" si se puede.
            LaminaAbierta candidata = laminas.stream()
                    .max(Comparator.comparing(l -> laminaBaseM.subtract(l.usado)))
                    .orElse(null);
            if (candidata == null) {
                break;
            }

            List<LaminaAbierta> restantes = new ArrayList<>(laminas);
            restantes.remove(candidata);

            // Simula la reubicación de cada corte de la candidata en las
            // demás láminas (de mayor a menor, mismo criterio de mejor
            // ajuste) sobre una COPIA de los usados — si algún corte no
            // cabe en ninguna, se descarta el intento completo.
            Map<LaminaAbierta, BigDecimal> usadoSimulado = new java.util.HashMap<>();
            for (LaminaAbierta l : restantes) {
                usadoSimulado.put(l, l.usado);
            }

            List<BigDecimal> cortesAReubicar = new ArrayList<>(candidata.cortes);
            cortesAReubicar.sort(Comparator.reverseOrder());

            // Lista de pares (corte, lámina destino) en vez de un mapa por
            // valor — varias piezas de la MISMA medida son entradas
            // distintas y cada una necesita su propio destino individual.
            List<BigDecimal> cortesConfirmados = new ArrayList<>();
            List<LaminaAbierta> destinosConfirmados = new ArrayList<>();
            boolean cabeTodo = true;

            for (BigDecimal corte : cortesAReubicar) {
                LaminaAbierta mejorDestino = null;
                BigDecimal mejorSobrante = null;
                for (LaminaAbierta l : restantes) {
                    BigDecimal disponible = laminaBaseM.subtract(usadoSimulado.get(l));
                    if (disponible.compareTo(corte) >= 0) {
                        BigDecimal sobranteSiEntra = disponible.subtract(corte);
                        if (mejorSobrante == null || sobranteSiEntra.compareTo(mejorSobrante) < 0) {
                            mejorDestino = l;
                            mejorSobrante = sobranteSiEntra;
                        }
                    }
                }
                if (mejorDestino == null) {
                    cabeTodo = false;
                    break;
                }
                usadoSimulado.put(mejorDestino, usadoSimulado.get(mejorDestino).add(corte));
                cortesConfirmados.add(corte);
                destinosConfirmados.add(mejorDestino);
            }

            if (cabeTodo) {
                // Se confirma la reubicación de verdad y se elimina la lámina candidata.
                for (int i = 0; i < cortesConfirmados.size(); i++) {
                    LaminaAbierta destino = destinosConfirmados.get(i);
                    BigDecimal corte = cortesConfirmados.get(i);
                    destino.cortes.add(corte);
                    destino.usado = destino.usado.add(corte);
                }
                laminas.remove(candidata);
                seEliminoAlguna = true;
            }
        }

        return laminas;
    }
}

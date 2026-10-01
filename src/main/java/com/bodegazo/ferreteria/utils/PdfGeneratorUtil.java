package com.bodegazo.ferreteria.utils;

import com.bodegazo.ferreteria.dto.CalculoTejaResultDTO;
import com.bodegazo.ferreteria.dto.CotizacionDetalleDTO;
import com.bodegazo.ferreteria.dto.ItemDetalleDTO;
import com.bodegazo.ferreteria.dto.PlanCortesResultDTO;
import com.itextpdf.io.image.ImageDataFactory;
import com.itextpdf.kernel.colors.ColorConstants;
import com.itextpdf.kernel.colors.DeviceRgb;
import com.itextpdf.kernel.geom.PageSize;
import com.itextpdf.kernel.pdf.PdfDocument;
import com.itextpdf.kernel.pdf.PdfWriter;
import com.itextpdf.layout.Document;
import com.itextpdf.layout.element.Cell;
import com.itextpdf.layout.element.Image;
import com.itextpdf.layout.element.Paragraph;
import com.itextpdf.layout.element.Table;
import com.itextpdf.layout.properties.HorizontalAlignment;
import com.itextpdf.layout.properties.TextAlignment;
import com.itextpdf.layout.properties.UnitValue;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Component;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.List;
import java.math.BigDecimal;
import java.text.DecimalFormat;
import java.time.format.DateTimeFormatter;

/**
 * Genera los documentos PDF del sistema: la cotización formal para el
 * cliente, y el formato de corte de tejas (guía de instalación) que
 * sale de la calculadora. Usa iText7 (capa "layout", de alto nivel).
 */
@Component
public class PdfGeneratorUtil {

    private static final DeviceRgb COLOR_AZUL = new DeviceRgb(28, 28, 28);
    private static final DeviceRgb COLOR_NARANJA = new DeviceRgb(154, 43, 31);
    private static final DeviceRgb COLOR_GRIS_CLARO = new DeviceRgb(245, 246, 250);
    private static final DecimalFormat MONEDA = new DecimalFormat("$#,##0");

    // ==================== COTIZACIÓN ====================

    public byte[] generarCotizacionPdf(CotizacionDetalleDTO cotizacion) {
        try (ByteArrayOutputStream salida = new ByteArrayOutputStream()) {
            PdfDocument pdfDoc = new PdfDocument(new PdfWriter(salida));
            Document doc = new Document(pdfDoc, PageSize.A4);
            doc.setMargins(30, 36, 30, 36);

            agregarEncabezado(doc, "COTIZACIÓN #" + cotizacion.getId());

            Table datosCliente = new Table(UnitValue.createPercentArray(new float[]{1, 1}))
                    .useAllAvailableWidth().setMarginTop(10).setMarginBottom(10);
            datosCliente.addCell(celdaSinBorde("Cliente: " + cotizacion.getClienteNombre(), false));
            datosCliente.addCell(celdaSinBorde("Documento: " + valorOVacio(cotizacion.getClienteDocumento()), false));
            datosCliente.addCell(celdaSinBorde("Emitida por: " + cotizacion.getUsuarioNombre(), false));
            datosCliente.addCell(celdaSinBorde("Estado: " + cotizacion.getEstado(), false));
            datosCliente.addCell(celdaSinBorde("Fecha de emisión: " +
                    cotizacion.getFechaEmision().format(DateTimeFormatter.ofPattern("dd/MM/yyyy")), false));
            datosCliente.addCell(celdaSinBorde("Válida hasta: " + cotizacion.getFechaValidez(), false));
            doc.add(datosCliente);

            Table tabla = new Table(UnitValue.createPercentArray(new float[]{4, 1, 1.3f, 1.3f}))
                    .useAllAvailableWidth().setMarginTop(10);
            agregarEncabezadoTabla(tabla, "Producto", "Cant.", "Precio unit.", "Subtotal");
            int filaCot = 0;
            for (ItemDetalleDTO item : cotizacion.getItems()) {
                boolean par = filaCot++ % 2 == 0;
                tabla.addCell(celdaCuerpoFila(item.getNombreProducto() + " (" + item.getCodigoProducto() + ")", TextAlignment.LEFT, par));
                tabla.addCell(celdaCuerpoFila(item.getCantidad().toString(), TextAlignment.CENTER, par));
                tabla.addCell(celdaCuerpoFila(MONEDA.format(item.getPrecioUnitario()), TextAlignment.RIGHT, par));
                tabla.addCell(celdaCuerpoFila(MONEDA.format(item.getSubtotal()), TextAlignment.RIGHT, par));
            }
            doc.add(tabla);

            agregarTotales(doc, cotizacion.getSubtotal(), cotizacion.getImpuesto(), cotizacion.getTotal());
            agregarPie(doc, "Esta cotización tiene una validez limitada — consulta la fecha indicada arriba. Precios sujetos a disponibilidad de inventario.");

            doc.close();
            return salida.toByteArray();
        } catch (IOException e) {
            throw new RuntimeException("No se pudo generar el PDF de la cotización", e);
        }
    }

    // ==================== FORMATO DE CORTE DE TEJAS ====================

    public byte[] generarFormatoTejasPdf(CalculoTejaResultDTO resultado) {
        try (ByteArrayOutputStream salida = new ByteArrayOutputStream()) {
            PdfDocument pdfDoc = new PdfDocument(new PdfWriter(salida));
            Document doc = new Document(pdfDoc, PageSize.A4);
            doc.setMargins(30, 36, 30, 36);

            String tipoLabel = "TRAPEZOIDAL".equals(resultado.getTipoTeja()) ? "Trapezoidal" : "Colonial";
            agregarEncabezado(doc, "FORMATO DE CORTE — TEJA " + tipoLabel.toUpperCase());

            doc.add(new Paragraph("Medidas del área a cubrir").setBold().setFontSize(12).setMarginTop(10));
            Table medidas = new Table(UnitValue.createPercentArray(new float[]{1, 1}))
                    .useAllAvailableWidth().setMarginBottom(10);
            medidas.addCell(celdaSinBorde("Largo: " + resultado.getLargo() + " m", false));
            medidas.addCell(celdaSinBorde("Ancho: " + resultado.getAncho() + " m", false));
            medidas.addCell(celdaSinBorde("Traslapo lateral: " + resultado.getTraslapoLateralM() + " m", false));
            medidas.addCell(celdaSinBorde("Traslapo longitudinal: " + resultado.getTraslapoLongitudinalM() + " m", false));
            doc.add(medidas);

            doc.add(new Paragraph("Distribución de tejas (vista en planta)").setBold().setFontSize(12).setMarginTop(6));
            doc.add(new Paragraph("Cada casilla es una teja, con su medida real (largo x ancho). Las filas son las hileras (a lo ancho); las columnas son las tejas en serie de cada hilera (a lo largo, en el sentido de instalación).")
                    .setFontSize(9).setFontColor(ColorConstants.GRAY).setMarginBottom(8));

            int hileras = resultado.getHileras();
            int tejasPorHilera = resultado.getTejasPorHilera();
            BigDecimal largoModulo = resultado.getLargoModuloM();
            BigDecimal anchoModulo = resultado.getAnchoModuloM();
            Table cuadricula = new Table(UnitValue.createPercentArray(repetir(tejasPorHilera, 1f)))
                    .useAllAvailableWidth().setMarginBottom(6);
            for (int h = 1; h <= hileras; h++) {
                for (int t = 1; t <= tejasPorHilera; t++) {
                    Cell celda = new Cell()
                            .add(new Paragraph("H" + h + "-T" + t).setFontSize(8).setBold().setTextAlignment(TextAlignment.CENTER).setMarginBottom(2))
                            .add(new Paragraph(largoModulo + " x " + anchoModulo + " m").setFontSize(7).setFontColor(ColorConstants.GRAY).setTextAlignment(TextAlignment.CENTER))
                            .setBackgroundColor(COLOR_GRIS_CLARO)
                            .setBorder(new com.itextpdf.layout.borders.SolidBorder(COLOR_AZUL, 0.75f))
                            .setPadding(8);
                    cuadricula.addCell(celda);
                }
            }
            doc.add(cuadricula);
            doc.add(new Paragraph("* Medida física de cada teja comprada. La cobertura real de las tejas 2, 3... de cada hilera es menor porque una parte se traslapa con la anterior (ver traslapo longitudinal arriba).")
                    .setFontSize(8).setFontColor(ColorConstants.GRAY).setMarginBottom(12));

            // ---------- Posiciones obligatorias de correas ----------
            doc.add(new Paragraph("Posiciones obligatorias de correas (a lo largo)").setBold().setFontSize(12).setMarginTop(4));
            doc.add(new Paragraph("Como mínimo, debe haber una correa exactamente en cada uno de estos puntos — son donde las tejas se apoyan y se traslapan entre sí, midiendo desde el borde inicial (alero):")
                    .setFontSize(9).setFontColor(ColorConstants.GRAY).setMarginBottom(6));

            Table correas = new Table(UnitValue.createPercentArray(new float[]{1, 2}))
                    .useAllAvailableWidth().setMarginBottom(6);
            agregarEncabezadoTabla(correas, "Correa #", "Distancia desde el alero");
            List<BigDecimal> posiciones = calcularPosicionesCorreas(largoModulo, resultado.getTraslapoLongitudinalM(), tejasPorHilera, resultado.getLargo());
            for (int i = 0; i < posiciones.size(); i++) {
                String etiqueta = (i == 0) ? "1 (alero)" : (i == posiciones.size() - 1 ? i + 1 + " (cumbrera)" : String.valueOf(i + 1));
                correas.addCell(celdaCuerpo(etiqueta, TextAlignment.CENTER));
                correas.addCell(celdaCuerpo(posiciones.get(i) + " m", TextAlignment.CENTER));
            }
            doc.add(correas);

            doc.add(new Paragraph(
                    "Nota: estas son las posiciones mínimas obligatorias (bordes y empalmes entre tejas). En tramos largos entre estas posiciones, es práctica común de la industria agregar correas intermedias cada 0.80–1.00 m aproximadamente, según el grosor de la teja y las cargas de viento de la zona. Este dato es orientativo — confírmalo con la ficha técnica del fabricante de la teja o con un ingeniero estructural antes de construir la estructura, ya que depende de normativa local y condiciones del sitio."
            ).setFontSize(8).setFontColor(ColorConstants.GRAY).setMarginBottom(10));


            Table resumen = new Table(UnitValue.createPercentArray(new float[]{1, 1, 1}))
                    .useAllAvailableWidth().setMarginBottom(10);
            resumen.addCell(tarjetaResumen("Cantidad total", resultado.getCantidadTejas() + " teja(s)"));
            resumen.addCell(tarjetaResumen("Área cubierta", resultado.getAreaCubierta() + " m²"));
            resumen.addCell(tarjetaResumen("Desperdicio", resultado.getPorcentajeDesperdicio() + "%"));
            doc.add(resumen);

            if (resultado.getCantidadTejasOptimizado() != null) {
                doc.add(new Paragraph("Optimización aprovechando sobrantes").setBold().setFontSize(12).setMarginTop(8));
                doc.add(new Paragraph("Cantidad optimizada: " + resultado.getCantidadTejasOptimizado() +
                        " teja(s) — ahorras " + resultado.getTejasAhorradasOptimizando() + " teja(s) respecto al cálculo sin optimizar.")
                        .setFontSize(10));
                if (resultado.getExplicacionOptimizacion() != null) {
                    doc.add(new Paragraph(resultado.getExplicacionOptimizacion()).setFontSize(9).setFontColor(ColorConstants.GRAY).setMarginBottom(8));
                }

                agregarDibujoDeCortes(doc, resultado);
                agregarGridOptimizado(doc, resultado);
            }

            doc.add(new Paragraph("Instrucciones de instalación").setBold().setFontSize(12).setMarginTop(10));
            doc.add(new Paragraph(
                    "1. Inicia la instalación desde una esquina, avanzando hilera por hilera.\n" +
                    "2. Cada teja debe traslaparse " + resultado.getTraslapoLateralM() + " m con la hilera vecina (traslapo lateral).\n" +
                    "3. Dentro de cada hilera, las tejas en serie deben traslaparse " + resultado.getTraslapoLongitudinalM() + " m entre sí (traslapo longitudinal).\n" +
                    "4. Verifica que el traslapo quede orientado en el sentido de caída del agua (la teja de arriba monta sobre la de abajo)."
            ).setFontSize(10));

            agregarPie(doc, "Este formato es una guía de referencia. Confirma las medidas finales y la distribución con tu instalador según las condiciones reales de la cubierta.");

            doc.close();
            return salida.toByteArray();
        } catch (IOException e) {
            throw new RuntimeException("No se pudo generar el PDF del formato de tejas", e);
        }
    }

    /**
     * Calcula las posiciones (distancia desde el borde inicial) donde
     * obligatoriamente debe haber una correa: el borde inicial, cada punto
     * donde una teja se traslapa con la siguiente, y el borde final.
     */
    private List<BigDecimal> calcularPosicionesCorreas(BigDecimal largoModulo, BigDecimal traslapo,
                                                          int cantidadModulos, BigDecimal largoTotal) {
        List<BigDecimal> posiciones = new java.util.ArrayList<>();
        posiciones.add(BigDecimal.ZERO.setScale(2, java.math.RoundingMode.HALF_UP));
        for (int i = 1; i < cantidadModulos; i++) {
            BigDecimal coberturaUtilAdicional = largoModulo.subtract(traslapo);
            BigDecimal cobertura = largoModulo.add(coberturaUtilAdicional.multiply(BigDecimal.valueOf(i - 1)));
            posiciones.add(cobertura.setScale(2, java.math.RoundingMode.HALF_UP));
        }
        posiciones.add(largoTotal.setScale(2, java.math.RoundingMode.HALF_UP));
        return posiciones;
    }

    /**
     * Dibuja las tejas "donantes" (las que se cortan en piezas pequeñas
     * para cubrir el remate final de varias hileras) — una barra por cada
     * teja donante, dividida a escala en sus piezas de corte, indicando a
     * qué hilera va cada pieza y si sobra material sin usar.
     */
    private void agregarDibujoDeCortes(Document doc, CalculoTejaResultDTO resultado) {
        BigDecimal metrosAdicionales = resultado.getMetrosAdicionalesUltimoTramoM();
        BigDecimal largoModulo = resultado.getLargoModuloM();
        BigDecimal largoPiezaReal = resultado.getLargoPiezaCorteM();
        int hileras = resultado.getHileras();

        if (metrosAdicionales == null || largoModulo == null || largoPiezaReal == null) {
            return;
        }

        int piezasPorTeja = Math.max(1, largoModulo.divide(largoPiezaReal, 0, java.math.RoundingMode.FLOOR).intValue());
        int tejasDonantes = (int) Math.ceil(hileras / (double) piezasPorTeja);

        doc.add(new Paragraph("Cómo cortar las tejas donantes").setBold().setFontSize(12).setMarginTop(10));
        doc.add(new Paragraph("Cada pieza mide " + largoPiezaReal + " m de largo (" + metrosAdicionales +
                " m que hacen falta + " + resultado.getTraslapoLongitudinalM() + " m de traslapo para pegarla a la teja anterior de su hilera"
                + ("COLONIAL".equals(resultado.getTipoTeja()) ? ", ya redondeado al borde de barriga más cercano" : "") + ") x " +
                resultado.getAnchoModuloM() + " m de ancho.")
                .setFontSize(9).setFontColor(ColorConstants.GRAY).setMarginBottom(8));

        int hileraActual = 1;
        for (int d = 1; d <= tejasDonantes; d++) {
            int piezasEnEstaTeja = Math.min(piezasPorTeja, hileras - (d - 1) * piezasPorTeja);
            BigDecimal usado = largoPiezaReal.multiply(BigDecimal.valueOf(piezasEnEstaTeja));
            BigDecimal descarte = largoModulo.subtract(usado);
            boolean hayDescarte = descarte.compareTo(new BigDecimal("0.01")) > 0;

            doc.add(new Paragraph("Teja donante #" + d).setBold().setFontSize(10).setMarginTop(8));

            // ---- Acotación de largo (arriba del dibujo) ----
            doc.add(new Paragraph("◄─────────────────  Largo total: " + largoModulo + " m  ─────────────────►")
                    .setFontSize(8).setFontColor(COLOR_NARANJA).setTextAlignment(TextAlignment.CENTER).setMarginBottom(2));

            // ---- Barra de piezas (con el descarte pegado al final, como queda físicamente) ----
            List<Float> anchos = new java.util.ArrayList<>();
            for (int p = 0; p < piezasEnEstaTeja; p++) {
                anchos.add(largoPiezaReal.floatValue());
            }
            if (hayDescarte) {
                anchos.add(descarte.floatValue());
            }
            float[] anchosArr = new float[anchos.size()];
            for (int i = 0; i < anchos.size(); i++) {
                anchosArr[i] = anchos.get(i);
            }

            Table barra = new Table(UnitValue.createPercentArray(anchosArr)).useAllAvailableWidth();
            for (int p = 0; p < piezasEnEstaTeja; p++) {
                Cell celda = new Cell()
                        .add(new Paragraph("Hilera " + hileraActual).setFontSize(8).setBold().setTextAlignment(TextAlignment.CENTER).setFontColor(ColorConstants.WHITE))
                        .add(new Paragraph(largoPiezaReal + " m").setFontSize(7).setTextAlignment(TextAlignment.CENTER).setFontColor(ColorConstants.WHITE))
                        .setBackgroundColor(COLOR_NARANJA)
                        .setBorder(new com.itextpdf.layout.borders.SolidBorder(COLOR_AZUL, 0.75f))
                        .setPadding(6);
                barra.addCell(celda);
                hileraActual++;
            }
            if (hayDescarte) {
                Cell celdaDescarte = new Cell()
                        .add(new Paragraph("Sobra sin usar").setFontSize(7).setBold().setTextAlignment(TextAlignment.CENTER).setFontColor(ColorConstants.DARK_GRAY))
                        .add(new Paragraph(descarte.setScale(2, java.math.RoundingMode.HALF_UP) + " m").setFontSize(7).setTextAlignment(TextAlignment.CENTER).setFontColor(ColorConstants.DARK_GRAY))
                        .setBackgroundColor(ColorConstants.LIGHT_GRAY)
                        .setBorder(new com.itextpdf.layout.borders.DashedBorder(COLOR_AZUL, 0.75f))
                        .setPadding(6);
                barra.addCell(celdaDescarte);
            }

            // ---- Acotación de ancho (al lado del dibujo, en una columna aparte) ----
            Cell celdaBarra = new Cell().setBorder(com.itextpdf.layout.borders.Border.NO_BORDER).add(barra);
            Cell celdaAncho = new Cell().setBorder(com.itextpdf.layout.borders.Border.NO_BORDER)
                    .setVerticalAlignment(com.itextpdf.layout.properties.VerticalAlignment.MIDDLE)
                    .setPaddingLeft(6)
                    .add(new Paragraph("▲").setFontSize(8).setFontColor(COLOR_NARANJA).setTextAlignment(TextAlignment.CENTER).setMarginBottom(0))
                    .add(new Paragraph("Ancho: " + resultado.getAnchoModuloM() + " m").setFontSize(8).setFontColor(COLOR_NARANJA).setTextAlignment(TextAlignment.CENTER).setBold())
                    .add(new Paragraph("▼").setFontSize(8).setFontColor(COLOR_NARANJA).setTextAlignment(TextAlignment.CENTER).setMarginTop(0));

            Table contenedor = new Table(UnitValue.createPercentArray(new float[]{9, 1.3f})).useAllAvailableWidth().setMarginBottom(4);
            contenedor.addCell(celdaBarra);
            contenedor.addCell(celdaAncho);
            doc.add(contenedor);
        }
    }

    /**
     * Dibuja la misma "vista en planta" de la cuadrícula de tejas, pero
     * reflejando la distribución REAL cuando aplica la optimización: la
     * última teja de cada hilera ya no se muestra como una teja completa,
     * sino como la pieza cortada que realmente se instala ahí (más chica,
     * resaltada en naranja).
     */
    private void agregarGridOptimizado(Document doc, CalculoTejaResultDTO resultado) {
        BigDecimal largoModulo = resultado.getLargoModuloM();
        BigDecimal anchoModulo = resultado.getAnchoModuloM();
        BigDecimal largoPiezaReal = resultado.getLargoPiezaCorteM();
        int hileras = resultado.getHileras();
        int tejasPorHilera = resultado.getTejasPorHilera();

        if (largoModulo == null || largoPiezaReal == null || tejasPorHilera <= 1) {
            return;
        }

        doc.add(new Paragraph("Distribución final optimizada (vista en planta)").setBold().setFontSize(12).setMarginTop(10));
        doc.add(new Paragraph("Igual que la primera cuadrícula, pero mostrando lo que realmente se instala en cada hilera: la última posición ya no lleva una teja completa, sino la pieza cortada (en naranja) de la sección anterior.")
                .setFontSize(9).setFontColor(ColorConstants.GRAY).setMarginBottom(8));

        float[] anchosColumnas = new float[tejasPorHilera];
        for (int t = 0; t < tejasPorHilera - 1; t++) {
            anchosColumnas[t] = largoModulo.floatValue();
        }
        anchosColumnas[tejasPorHilera - 1] = largoPiezaReal.floatValue();

        Table cuadricula = new Table(UnitValue.createPercentArray(anchosColumnas)).useAllAvailableWidth().setMarginBottom(6);
        for (int h = 1; h <= hileras; h++) {
            for (int t = 1; t <= tejasPorHilera; t++) {
                boolean esPiezaCortada = (t == tejasPorHilera);
                Cell celda;
                if (esPiezaCortada) {
                    celda = new Cell()
                            .add(new Paragraph("H" + h + "-T" + t + " (corte)").setFontSize(7).setBold().setTextAlignment(TextAlignment.CENTER).setFontColor(ColorConstants.WHITE))
                            .add(new Paragraph(largoPiezaReal + " x " + anchoModulo + " m").setFontSize(7).setTextAlignment(TextAlignment.CENTER).setFontColor(ColorConstants.WHITE))
                            .setBackgroundColor(COLOR_NARANJA)
                            .setBorder(new com.itextpdf.layout.borders.SolidBorder(COLOR_AZUL, 0.75f))
                            .setPadding(6);
                } else {
                    celda = new Cell()
                            .add(new Paragraph("H" + h + "-T" + t).setFontSize(8).setBold().setTextAlignment(TextAlignment.CENTER))
                            .add(new Paragraph(largoModulo + " x " + anchoModulo + " m").setFontSize(7).setFontColor(ColorConstants.GRAY).setTextAlignment(TextAlignment.CENTER))
                            .setBackgroundColor(COLOR_GRIS_CLARO)
                            .setBorder(new com.itextpdf.layout.borders.SolidBorder(COLOR_AZUL, 0.75f))
                            .setPadding(8);
                }
                cuadricula.addCell(celda);
            }
        }
        doc.add(cuadricula);
        doc.add(new Paragraph("Gris = teja completa. Naranja = pieza cortada de una teja donante (ver sección anterior).")
                .setFontSize(8).setFontColor(ColorConstants.GRAY).setMarginBottom(10));
    }

    // ==================== PLAN DE CORTES (bodega y cliente) ====================

    /** Versión completa, con el detalle de cada corte por lámina — para el bodeguero. */
    public byte[] generarPlanCortesBodeguero(PlanCortesResultDTO plan) {
        try (ByteArrayOutputStream salida = new ByteArrayOutputStream()) {
            PdfDocument pdfDoc = new PdfDocument(new PdfWriter(salida));
            Document doc = new Document(pdfDoc, PageSize.A4);
            doc.setMargins(30, 36, 30, 36);

            agregarEncabezado(doc, "PLAN DE OPTIMIZACIÓN DE CORTES");

            doc.add(new Paragraph("Plan de Cortes — " + plan.getLaminasUsadas() + " lámina(s) — base: " + plan.getLaminaBaseM() + " m")
                    .setBold().setFontSize(13).setMarginTop(6).setMarginBottom(10));

            Table resumen = new Table(UnitValue.createPercentArray(new float[]{1, 1, 1, 1}))
                    .useAllAvailableWidth().setMarginBottom(14);
            resumen.addCell(tarjetaResumen("Láminas usadas", String.valueOf(plan.getLaminasUsadas())));
            resumen.addCell(tarjetaResumen("Material disponible", plan.getMaterialDisponibleM() + " m"));
            resumen.addCell(tarjetaResumen("Material usado", plan.getMaterialUsadoM() + " m"));
            resumen.addCell(tarjetaResumen("Desperdicio total", plan.getDesperdicioTotalM() + " m"));
            doc.add(resumen);

            Table tabla = new Table(UnitValue.createPercentArray(new float[]{0.6f, 3.2f, 1, 1}))
                    .useAllAvailableWidth().setMarginBottom(10);
            agregarEncabezadoTabla(tabla, "Lámina", "Cortes (m)", "Total usado", "Sobrante");
            int filaLamina = 0;
            for (PlanCortesResultDTO.LaminaCorteDTO lamina : plan.getLaminas()) {
                boolean par = filaLamina++ % 2 == 0;
                String cortesTexto = lamina.getCortes().stream().map(String::valueOf).reduce((a, b) -> a + " + " + b).orElse("");
                tabla.addCell(celdaCuerpoFila(String.valueOf(lamina.getNumero()), TextAlignment.CENTER, par));
                tabla.addCell(celdaCuerpoFila(cortesTexto, TextAlignment.LEFT, par));
                tabla.addCell(celdaCuerpoFila(lamina.getTotalUsado() + " m", TextAlignment.RIGHT, par));
                boolean sinSobrante = lamina.getSobrante().compareTo(BigDecimal.ZERO) == 0;
                Cell celdaSobrante = celdaCuerpoFila(lamina.getSobrante() + " m", TextAlignment.RIGHT, par);
                if (sinSobrante) {
                    celdaSobrante.setFontColor(new DeviceRgb(30, 130, 76));
                }
                tabla.addCell(celdaSobrante);
            }
            doc.add(tabla);

            if (plan.getPendientes() != null && !plan.getPendientes().isEmpty()) {
                Table pendienteBox = new Table(1).useAllAvailableWidth().setMarginBottom(10);
                Cell celda = new Cell()
                        .setBackgroundColor(new DeviceRgb(255, 243, 224))
                        .setBorder(new com.itextpdf.layout.borders.SolidBorder(new DeviceRgb(230, 160, 40), 0.75f))
                        .setPadding(10);
                celda.add(new Paragraph("Pendiente por conseguir aparte").setBold().setFontSize(11).setFontColor(new DeviceRgb(150, 100, 10)));
                for (PlanCortesResultDTO.PiezaPendienteDTO p : plan.getPendientes()) {
                    celda.add(new Paragraph("• " + p.getCantidad() + " pieza(s) de " + p.getLargo() + " m — " + p.getMotivo()).setFontSize(9));
                }
                pendienteBox.addCell(celda);
                doc.add(pendienteBox);
            }

            doc.add(new Paragraph("Verificación de cantidades cortadas").setBold().setFontSize(11).setMarginTop(6).setMarginBottom(6));
            Table verificacion = new Table(UnitValue.createPercentArray(repetir(Math.min(plan.getResumenCantidades().size(), 6), 1f)))
                    .useAllAvailableWidth();
            for (PlanCortesResultDTO.PiezaResumenDTO r : plan.getResumenCantidades()) {
                Cell celda = new Cell()
                        .add(new Paragraph(r.getLargo() + " x " + r.getCantidad()).setFontSize(9).setBold().setTextAlignment(TextAlignment.CENTER))
                        .setBackgroundColor(COLOR_GRIS_CLARO)
                        .setBorder(com.itextpdf.layout.borders.Border.NO_BORDER)
                        .setPadding(6);
                verificacion.addCell(celda);
            }
            doc.add(verificacion);

            agregarPie(doc, "Este plan busca aprovechar al máximo cada lámina. Verifica las medidas en obra antes de cortar.");
            doc.close();
            return salida.toByteArray();
        } catch (IOException e) {
            throw new RuntimeException("No se pudo generar el PDF del plan de cortes", e);
        }
    }

    // ==================== helpers compartidos ====================

    private void agregarEncabezado(Document doc, String titulo) throws IOException {
        // Banda superior de color, a todo el ancho, detrás del logo y el título
        Table banda = new Table(UnitValue.createPercentArray(new float[]{1, 2}))
                .useAllAvailableWidth()
                .setBackgroundColor(COLOR_AZUL)
                .setMarginBottom(0);

        Cell celdaLogo = new Cell().setBorder(com.itextpdf.layout.borders.Border.NO_BORDER)
                .setPadding(14).setVerticalAlignment(com.itextpdf.layout.properties.VerticalAlignment.MIDDLE);
        try (InputStream logoStream = new ClassPathResource("static/images-pdf/logo-bodegazo.png").getInputStream()) {
            byte[] logoBytes = logoStream.readAllBytes();
            Image logo = new Image(ImageDataFactory.create(logoBytes)).setWidth(75);
            celdaLogo.add(logo);
        } catch (Exception e) {
            celdaLogo.add(new Paragraph("BODEGAZO DE LA TEJA").setBold().setFontSize(13).setFontColor(ColorConstants.WHITE));
        }
        banda.addCell(celdaLogo);

        Cell celdaTitulo = new Cell().setBorder(com.itextpdf.layout.borders.Border.NO_BORDER)
                .setPadding(14).setVerticalAlignment(com.itextpdf.layout.properties.VerticalAlignment.MIDDLE);
        celdaTitulo.add(new Paragraph(titulo).setBold().setFontSize(17).setFontColor(ColorConstants.WHITE).setTextAlignment(TextAlignment.RIGHT).setMarginBottom(2));
        celdaTitulo.add(new Paragraph("Bodegazo de la Teja / El Bodegón del Manto").setFontSize(8).setFontColor(new DeviceRgb(200, 200, 200)).setTextAlignment(TextAlignment.RIGHT));
        banda.addCell(celdaTitulo);

        doc.add(banda);
        doc.add(new com.itextpdf.layout.element.LineSeparator(new com.itextpdf.kernel.pdf.canvas.draw.SolidLine(3f))
                .setStrokeColor(COLOR_NARANJA).setMarginBottom(14));
    }

    private void agregarEncabezadoTabla(Table tabla, String... columnas) {
        for (String col : columnas) {
            Cell celda = new Cell()
                    .add(new Paragraph(col).setBold().setFontColor(ColorConstants.WHITE).setFontSize(10))
                    .setBackgroundColor(COLOR_AZUL)
                    .setPadding(6);
            tabla.addHeaderCell(celda);
        }
    }

    private Cell celdaCuerpo(String texto, TextAlignment alineacion) {
        return new Cell().add(new Paragraph(texto).setFontSize(10)).setTextAlignment(alineacion).setPadding(6);
    }

    /** Igual que celdaCuerpo, pero con franja de fondo alternada (fila par/impar) para tablas largas. */
    private Cell celdaCuerpoFila(String texto, TextAlignment alineacion, boolean filaPar) {
        Cell celda = new Cell().add(new Paragraph(texto).setFontSize(10)).setTextAlignment(alineacion).setPadding(7)
                .setBorder(com.itextpdf.layout.borders.Border.NO_BORDER)
                .setBorderBottom(new com.itextpdf.layout.borders.SolidBorder(new DeviceRgb(230, 230, 230), 0.5f));
        if (filaPar) {
            celda.setBackgroundColor(COLOR_GRIS_CLARO);
        }
        return celda;
    }

    private Cell celdaSinBorde(String texto, boolean negrita) {
        Paragraph p = new Paragraph(texto).setFontSize(10);
        if (negrita) {
            p.setBold();
        }
        return new Cell().add(p).setBorder(com.itextpdf.layout.borders.Border.NO_BORDER).setPadding(2);
    }

    private Cell tarjetaResumen(String etiqueta, String valor) {
        Cell celda = new Cell()
                .setBackgroundColor(COLOR_GRIS_CLARO)
                .setBorder(com.itextpdf.layout.borders.Border.NO_BORDER)
                .setBorderTop(new com.itextpdf.layout.borders.SolidBorder(COLOR_NARANJA, 2f))
                .setPadding(12)
                .setTextAlignment(TextAlignment.CENTER);
        celda.add(new Paragraph(etiqueta.toUpperCase()).setFontSize(8).setFontColor(ColorConstants.GRAY).setMarginBottom(2));
        celda.add(new Paragraph(valor).setBold().setFontSize(15).setFontColor(COLOR_AZUL));
        return celda;
    }

    private void agregarTotales(Document doc, BigDecimal subtotal, BigDecimal impuesto, BigDecimal total) {
        Table totales = new Table(UnitValue.createPercentArray(new float[]{3, 1}))
                .useAllAvailableWidth().setMarginTop(10).setHorizontalAlignment(HorizontalAlignment.RIGHT);

        totales.addCell(celdaSinBorde("TOTAL", true).setTextAlignment(TextAlignment.RIGHT).setFontColor(COLOR_NARANJA));
        totales.addCell(celdaSinBorde(MONEDA.format(total), true).setTextAlignment(TextAlignment.RIGHT).setFontColor(COLOR_NARANJA));
        doc.add(totales);
        doc.add(new Paragraph("IVA incluido").setFontSize(8).setFontColor(ColorConstants.GRAY).setTextAlignment(TextAlignment.RIGHT));
    }

    private void agregarPie(Document doc, String texto) {
        doc.add(new com.itextpdf.layout.element.LineSeparator(new com.itextpdf.kernel.pdf.canvas.draw.SolidLine(0.5f))
                .setStrokeColor(ColorConstants.LIGHT_GRAY).setMarginTop(16).setMarginBottom(6));
        doc.add(new Paragraph(texto).setFontSize(8).setFontColor(ColorConstants.GRAY));
        doc.add(new Paragraph("Bodegazo de la Teja — Impermeabilizantes y Tejas UPVC").setFontSize(8).setFontColor(ColorConstants.GRAY).setMarginTop(4));
    }

    private String valorOVacio(String valor) {
        return valor != null ? valor : "—";
    }

    private float[] repetir(int veces, float valor) {
        float[] arreglo = new float[Math.max(veces, 1)];
        java.util.Arrays.fill(arreglo, valor);
        return arreglo;
    }
}

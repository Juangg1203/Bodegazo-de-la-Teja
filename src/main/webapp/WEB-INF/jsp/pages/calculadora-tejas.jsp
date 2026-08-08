<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/jsp/fragments/head.jsp"/>
<body>
<jsp:include page="/WEB-INF/jsp/fragments/navbar.jsp"/>

<main>
  <section class="hero-section py-5">
    <div class="container text-center">
      <h1 class="mb-2"><i class="bi bi-calculator me-2"></i>Calculadora de Tejas</h1>
      <p class="lead mb-0">Calcula cuántas tejas UPVC necesitas, con los traslapos ya incluidos.</p>
    </div>
  </section>

  <section class="py-5">
    <div class="container">
      <div class="row g-5">
        <div class="col-lg-4">
          <div class="card card-bodegazo p-4 sticky-top" style="top: 90px;">
            <h5 class="fw-bold mb-3"><i class="bi bi-rulers text-accent me-2"></i>Ingresa las medidas del área</h5>

            <c:if test="${not empty error}">
              <div class="alert alert-danger py-2"><c:out value="${error}"/></div>
            </c:if>

            <form action="${pageContext.request.contextPath}/calculadora-tejas" method="post">
              <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>

              <div class="mb-3">
                <label class="form-label fw-semibold">Tipo de teja</label>
                <div class="btn-group w-100" role="group">
                  <input type="radio" class="btn-check" name="tipoTeja" id="tipoColonial" value="COLONIAL"
                         ${empty resultado.tipoTeja || resultado.tipoTeja == 'COLONIAL' ? 'checked' : ''}>
                  <label class="btn btn-outline-accent" for="tipoColonial"><i class="bi bi-house-fill me-1"></i>Colonial</label>

                  <input type="radio" class="btn-check" name="tipoTeja" id="tipoTrapezoidal" value="TRAPEZOIDAL"
                         ${resultado.tipoTeja == 'TRAPEZOIDAL' ? 'checked' : ''}>
                  <label class="btn btn-outline-accent" for="tipoTrapezoidal"><i class="bi bi-triangle-fill me-1"></i>Trapezoidal</label>
                </div>
              </div>

              <div class="mb-3">
                <label class="form-label fw-semibold">Color</label>
                <div class="d-flex gap-2 flex-wrap" id="selectorColor">
                  <input type="radio" class="btn-check color-radio" name="color" id="colorTerracota" value="TERRACOTA"
                         ${empty colorSeleccionado || colorSeleccionado == 'TERRACOTA' ? 'checked' : ''}>
                  <label class="color-swatch" for="colorTerracota" style="background-color:#a0522d;" title="Terracota (Colonial)"></label>

                  <input type="radio" class="btn-check color-radio" name="color" id="colorBlanca" value="BLANCA"
                         ${colorSeleccionado == 'BLANCA' ? 'checked' : ''}>
                  <label class="color-swatch" for="colorBlanca" style="background-color:#f2f2ee; border:1px solid #ccc;" title="Blanca"></label>

                  <input type="radio" class="btn-check color-radio" name="color" id="colorVerde" value="VERDE"
                         ${colorSeleccionado == 'VERDE' ? 'checked' : ''}>
                  <label class="color-swatch" for="colorVerde" style="background-color:#2d6a4f;" title="Verde"></label>

                  <input type="radio" class="btn-check color-radio" name="color" id="colorRoja" value="ROJA"
                         ${colorSeleccionado == 'ROJA' ? 'checked' : ''}>
                  <label class="color-swatch" for="colorRoja" style="background-color:#9a2b1f;" title="Roja"></label>

                  <input type="radio" class="btn-check color-radio" name="color" id="colorAzul" value="AZUL"
                         ${colorSeleccionado == 'AZUL' ? 'checked' : ''}>
                  <label class="color-swatch" for="colorAzul" style="background-color:#1f4e8c;" title="Azul"></label>

                  <input type="radio" class="btn-check color-radio" name="color" id="colorTransparente" value="TRANSPARENTE"
                         ${colorSeleccionado == 'TRANSPARENTE' ? 'checked' : ''}>
                  <label class="color-swatch" for="colorTransparente" style="background-color:rgba(200,230,255,0.5); border:1px dashed #999;" title="Transparente"></label>
                </div>
                <p class="text-muted small mt-1 mb-0">Solo para ver cómo se vería — no cambia el cálculo de cantidades.</p>
              </div>

              <div class="mb-3">
                <label for="largo" class="form-label fw-semibold">Largo (metros)</label>
                <div class="input-group">
                  <span class="input-group-text bg-white"><i class="bi bi-arrows-angle-expand"></i></span>
                  <input type="number" step="0.01" min="0.01" class="form-control form-control-lg" id="largo" name="largo"
                         value="${resultado.largo}" required placeholder="Ej. 6">
                </div>
              </div>
              <div class="mb-4">
                <label for="ancho" class="form-label fw-semibold">Ancho (metros)</label>
                <div class="input-group">
                  <span class="input-group-text bg-white"><i class="bi bi-arrows-expand"></i></span>
                  <input type="number" step="0.01" min="0.01" class="form-control form-control-lg" id="ancho" name="ancho"
                         value="${resultado.ancho}" required placeholder="Ej. 2.2">
                </div>
              </div>
              <button type="submit" class="btn btn-accent btn-lg w-100 shadow-sm">
                <i class="bi bi-calculator-fill me-2"></i> Calcular
              </button>
            </form>

            <div class="alert alert-light border mt-4 mb-0 small">
              <i class="bi bi-info-circle text-accent me-1"></i>
              <strong>Colonial:</strong> 5.90 m x 1.10 m, traslapo lateral 10 cm (queda 1.00 m útil) y
              traslapo longitudinal 22 cm (queda 5.68 m útil).<br>
              <strong>Trapezoidal:</strong> 5.90 m x 1.10 m, traslapo lateral 10 cm y longitudinal 20 cm.
            </div>
          </div>
        </div>

        <div class="col-lg-8">
          <c:choose>
            <c:when test="${not empty resultado}">

              <div class="mb-3">
                <span class="badge bg-dark fs-6 px-3 py-2">
                  <i class="bi bi-house-fill me-1"></i>
                  Teja <c:out value="${resultado.tipoTeja == 'TRAPEZOIDAL' ? 'Trapezoidal' : 'Colonial'}"/>
                </span>
              </div>

              <!-- Comparación: tejas completas vs. optimizado -->
              <div class="row g-3 mb-4">
                <div class="col-md-6">
                  <div class="card card-bodegazo p-4 h-100 text-center">
                    <span class="badge bg-secondary align-self-center mb-2">Sin optimizar</span>
                    <i class="bi bi-grid-3x3-gap-fill fs-1 mb-2" style="color: var(--bodegazo-azul);"></i>
                    <h2 class="fw-bold mb-0"><c:out value="${resultado.cantidadTejas}"/></h2>
                    <p class="text-muted small mb-0">teja(s) completas</p>
                  </div>
                </div>
                <div class="col-md-6">
                  <c:choose>
                    <c:when test="${not empty resultado.cantidadTejasOptimizado}">
                      <div class="card p-4 h-100 text-center text-white shadow" style="background: linear-gradient(135deg, var(--bodegazo-naranja), var(--bodegazo-naranja-oscuro));">
                        <span class="badge bg-white text-accent align-self-center mb-2 fw-bold">Optimizado</span>
                        <i class="bi bi-scissors fs-1 mb-2"></i>
                        <h2 class="fw-bold mb-0"><c:out value="${resultado.cantidadTejasOptimizado}"/></h2>
                        <p class="mb-0 small">teja(s) — ahorras <strong><c:out value="${resultado.tejasAhorradasOptimizando}"/></strong></p>
                      </div>
                    </c:when>
                    <c:otherwise>
                      <div class="card card-bodegazo p-4 h-100 text-center d-flex align-items-center justify-content-center">
                        <i class="bi bi-check-circle text-muted fs-2 mb-2"></i>
                        <p class="text-muted small mb-0">No hay sobrantes reaprovechables con estas medidas.</p>
                      </div>
                    </c:otherwise>
                  </c:choose>
                </div>
              </div>

              <!-- Simulador visual del techo -->
              <div class="card card-bodegazo p-4 mb-4">
                <h6 class="fw-bold mb-3"><i class="bi bi-eye-fill text-accent me-2"></i>Simulación visual del techo</h6>
                <c:set var="colorHex" value="#a0522d"/>
                <c:choose>
                  <c:when test="${colorSeleccionado == 'BLANCA'}"><c:set var="colorHex" value="#f2f2ee"/></c:when>
                  <c:when test="${colorSeleccionado == 'VERDE'}"><c:set var="colorHex" value="#2d6a4f"/></c:when>
                  <c:when test="${colorSeleccionado == 'ROJA'}"><c:set var="colorHex" value="#9a2b1f"/></c:when>
                  <c:when test="${colorSeleccionado == 'AZUL'}"><c:set var="colorHex" value="#1f4e8c"/></c:when>
                  <c:when test="${colorSeleccionado == 'TRANSPARENTE'}"><c:set var="colorHex" value="rgba(200,230,255,0.55)"/></c:when>
                </c:choose>
                <div class="border rounded p-2" style="background: repeating-linear-gradient(45deg, #eee, #eee 10px, #e4e4e4 10px, #e4e4e4 20px); overflow-x:auto;">
                  <c:choose>
                    <c:when test="${resultado.cantidadTejas <= 400}">
                      <div style="display:grid; grid-template-columns: repeat(${resultado.tejasPorHilera}, minmax(28px, 1fr)); grid-template-rows: repeat(${resultado.hileras}, 24px); gap:2px; min-width: 320px;">
                        <c:forEach begin="1" end="${resultado.hileras * resultado.tejasPorHilera}">
                          <div class="simulador-teja" style="background-color: ${colorHex}; border-radius: 3px;"></div>
                        </c:forEach>
                      </div>
                    </c:when>
                    <c:otherwise>
                      <p class="text-muted small text-center py-4 mb-0">El área es muy grande para mostrar la simulación completa aquí — pero el cálculo de cantidades arriba sigue siendo exacto.</p>
                    </c:otherwise>
                  </c:choose>
                </div>
                <p class="text-muted small mt-2 mb-0">
                  Cada rectángulo representa una teja
                  (<c:out value="${resultado.hileras}"/> hileras x <c:out value="${resultado.tejasPorHilera}"/> tejas por hilera).
                  Es solo una referencia visual, no a escala real.
                </p>
              </div>

              <c:if test="${not empty resultado.explicacionOptimizacion}">
                <div class="alert alert-success shadow-sm mb-4" role="alert">
                  <div class="d-flex">
                    <i class="bi bi-scissors fs-4 me-3"></i>
                    <div><strong>Cómo se logra el ahorro:</strong> <c:out value="${resultado.explicacionOptimizacion}"/></div>
                  </div>
                </div>
              </c:if>

              <!-- Costo -->
              <div class="card p-4 mb-4 text-center text-white" style="background: linear-gradient(135deg, var(--bodegazo-azul), var(--bodegazo-azul-claro));">
                <p class="small opacity-75 mb-1">Costo estimado (precio de referencia, tejas completas)</p>
                <h2 class="fw-bold mb-0"><fmt:formatNumber value="${resultado.costoEstimado}" type="currency" currencySymbol="$"/></h2>
              </div>

              <!-- Detalle técnico -->
              <div class="card card-bodegazo p-4">
                <h6 class="fw-bold mb-3"><i class="bi bi-clipboard-data-fill text-accent me-2"></i>Detalle del cálculo</h6>
                <div class="row g-3 text-center">
                  <div class="col-6 col-md-3">
                    <div class="p-2 rounded bg-light">
                      <p class="text-muted small mb-0">Área a cubrir</p>
                      <h5 class="fw-bold mb-0"><fmt:formatNumber value="${resultado.areaUtil}" maxFractionDigits="2"/></h5>
                      <p class="text-muted small mb-0">m²</p>
                    </div>
                  </div>
                  <div class="col-6 col-md-3">
                    <div class="p-2 rounded bg-light">
                      <p class="text-muted small mb-0">Área cubierta</p>
                      <h5 class="fw-bold mb-0"><fmt:formatNumber value="${resultado.areaCubierta}" maxFractionDigits="2"/></h5>
                      <p class="text-muted small mb-0">m²</p>
                    </div>
                  </div>
                  <div class="col-6 col-md-3">
                    <div class="p-2 rounded bg-light">
                      <p class="text-muted small mb-0">Hileras</p>
                      <h5 class="fw-bold mb-0"><c:out value="${resultado.hileras}"/></h5>
                    </div>
                  </div>
                  <div class="col-6 col-md-3">
                    <div class="p-2 rounded bg-light">
                      <p class="text-muted small mb-0">Tejas/hilera</p>
                      <h5 class="fw-bold mb-0"><c:out value="${resultado.tejasPorHilera}"/></h5>
                    </div>
                  </div>
                  <div class="col-6 col-md-3">
                    <div class="p-2 rounded bg-light">
                      <p class="text-muted small mb-0">Desperdicio</p>
                      <h5 class="fw-bold mb-0"><fmt:formatNumber value="${resultado.porcentajeDesperdicio}" maxFractionDigits="1"/>%</h5>
                    </div>
                  </div>
                  <div class="col-6 col-md-3">
                    <div class="p-2 rounded bg-light">
                      <p class="text-muted small mb-0">Sobrante ancho</p>
                      <h5 class="fw-bold mb-0"><fmt:formatNumber value="${resultado.sobranteAnchoM}" maxFractionDigits="2"/> m</h5>
                    </div>
                  </div>
                  <c:if test="${not empty resultado.metrosAdicionalesUltimoTramoM}">
                    <div class="col-6 col-md-3">
                      <div class="p-2 rounded" style="background-color: rgba(242,140,40,0.10);">
                        <p class="text-muted small mb-0">Metros adicionales</p>
                        <h5 class="fw-bold mb-0 text-accent"><fmt:formatNumber value="${resultado.metrosAdicionalesUltimoTramoM}" maxFractionDigits="2"/> m</h5>
                      </div>
                    </div>
                  </c:if>
                </div>
              </div>

              <form action="${pageContext.request.contextPath}/calculadora-tejas/pdf" method="post" target="_blank" class="mt-3">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                <input type="hidden" name="largo" value="${resultado.largo}">
                <input type="hidden" name="ancho" value="${resultado.ancho}">
                <input type="hidden" name="tipoTeja" value="${resultado.tipoTeja}">
                <button type="submit" class="btn btn-accent w-100">
                  <i class="bi bi-file-earmark-pdf-fill me-1"></i> Descargar formato de corte (PDF)
                </button>
              </form>

              <a href="${pageContext.request.contextPath}/tejas-upvc" class="btn btn-outline-accent w-100 mt-2">
                <i class="bi bi-grid-3x3-gap-fill me-1"></i> Ver tejas UPVC disponibles
              </a>
            </c:when>
            <c:otherwise>
              <div class="d-flex flex-column align-items-center justify-content-center h-100 text-muted py-5">
                <i class="bi bi-calculator display-1 mb-3 opacity-25"></i>
                <p class="fs-5">Ingresa las medidas de tu área para ver el resultado aquí.</p>
              </div>
            </c:otherwise>
          </c:choose>
        </div>
      </div>
    </div>
  </section>
</main>

<jsp:include page="/WEB-INF/jsp/fragments/footer.jsp"/>
<jsp:include page="/WEB-INF/jsp/fragments/scripts.jsp"/>

<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/jsp/fragments/head.jsp"/>
<body>
<jsp:include page="/WEB-INF/jsp/fragments/navbar.jsp"/>

<main>
  <section class="hero-section py-5">
    <div class="container text-center">
      <h1 class="mb-2"><i class="bi bi-calculator me-2"></i>Calculadora de Mantos</h1>
      <p class="lead mb-0">Calcula cuántos rollos necesitas, con el traslapo obligatorio ya incluido.</p>
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

            <form action="${pageContext.request.contextPath}/calculadora-mantos" method="post">
              <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
              <div class="mb-3">
                <label for="largo" class="form-label fw-semibold">Largo (metros)</label>
                <div class="input-group">
                  <span class="input-group-text bg-white"><i class="bi bi-arrows-angle-expand"></i></span>
                  <input type="number" step="0.01" min="0.01" class="form-control form-control-lg" id="largo" name="largo"
                         value="${resultado.largo}" required placeholder="Ej. 12">
                </div>
              </div>
              <div class="mb-4">
                <label for="ancho" class="form-label fw-semibold">Ancho (metros)</label>
                <div class="input-group">
                  <span class="input-group-text bg-white"><i class="bi bi-arrows-expand"></i></span>
                  <input type="number" step="0.01" min="0.01" class="form-control form-control-lg" id="ancho" name="ancho"
                         value="${resultado.ancho}" required placeholder="Ej. 48">
                </div>
              </div>
              <button type="submit" class="btn btn-accent btn-lg w-100 shadow-sm">
                <i class="bi bi-calculator-fill me-2"></i> Calcular
              </button>
            </form>

            <div class="alert alert-light border mt-4 mb-0 small">
              <i class="bi bi-info-circle text-accent me-1"></i>
              El rollo mide <fmt:formatNumber value="1.00"/> m de ancho x <fmt:formatNumber value="10.00"/> m
              de largo, con un traslapo obligatorio de <strong>0.80 m</strong> entre empalmes.
              Área efectiva por rollo: <strong>9.20 m²</strong>.
            </div>
          </div>
        </div>

        <div class="col-lg-8">
          <c:choose>
            <c:when test="${not empty resultado}">

              <!-- Tarjeta principal: cantidad recomendada -->
              <div class="card card-bodegazo p-4 mb-4 text-center bg-gradient" style="background: linear-gradient(135deg, var(--bodegazo-azul), var(--bodegazo-azul-claro)); color: white;">
                <p class="text-uppercase small mb-2 opacity-75" style="letter-spacing: 1px;">Necesitas comprar</p>
                <h1 class="display-5 fw-bold mb-1">
                  <c:out value="${resultado.rollosCompletosNecesarios}"/> rollo(s)
                  <c:if test="${resultado.metrosSueltosNecesarios > 0}">
                    <span class="text-accent">+ <fmt:formatNumber value="${resultado.metrosSueltosNecesarios}" maxFractionDigits="0"/> m sueltos</span>
                  </c:if>
                </h1>
                <p class="mb-0 opacity-75">
                  Equivale a <fmt:formatNumber value="${resultado.cantidadRollosEquivalente}" maxFractionDigits="2"/> rollos
                  (<fmt:formatNumber value="${resultado.cantidadRollosDecimal}" maxFractionDigits="4"/> exacto)
                </p>
                <hr class="opacity-25 my-3">
                <div class="row">
                  <div class="col-6 border-end border-light border-opacity-25">
                    <p class="small opacity-75 mb-0">Costo estimado</p>
                    <h3 class="fw-bold mb-0"><fmt:formatNumber value="${resultado.costoEstimado}" type="currency" currencySymbol="$"/></h3>
                  </div>
                  <div class="col-6">
                    <p class="small opacity-75 mb-0">Desperdicio</p>
                    <h3 class="fw-bold mb-0"><fmt:formatNumber value="${resultado.porcentajeDesperdicio}" maxFractionDigits="1"/>%</h3>
                  </div>
                </div>
              </div>

              <c:if test="${not empty resultado.recomendacionLargo}">
                <div class="alert alert-warning shadow-sm mb-4" role="alert">
                  <div class="d-flex">
                    <i class="bi bi-lightbulb-fill fs-4 me-3 text-warning-emphasis"></i>
                    <div>
                      <strong>Recomendación de ahorro:</strong>
                      <c:out value="${resultado.recomendacionLargo}"/>
                    </div>
                  </div>
                </div>
              </c:if>

              <!-- Reparto de la compra: rollos completos vs. metros sueltos -->
              <div class="card card-bodegazo p-4 mb-4">
                <h6 class="fw-bold mb-3"><i class="bi bi-bar-chart-fill text-accent me-2"></i>Reparto de la compra</h6>
                <div class="row g-3 text-center">
                  <div class="col-6">
                    <div class="p-3 rounded" style="background-color: rgba(10,37,64,0.06);">
                      <i class="bi bi-box-seam-fill fs-3 mb-1 d-block" style="color: var(--bodegazo-azul);"></i>
                      <h3 class="fw-bold mb-0"><c:out value="${resultado.rollosCompletosNecesarios}"/></h3>
                      <p class="text-muted small mb-0">rollo(s) completo(s)</p>
                    </div>
                  </div>
                  <div class="col-6">
                    <div class="p-3 rounded" style="background-color: rgba(242,140,40,0.10);">
                      <i class="bi bi-scissors fs-3 mb-1 d-block text-accent"></i>
                      <h3 class="fw-bold mb-0 text-accent"><fmt:formatNumber value="${resultado.metrosSueltosNecesarios}" maxFractionDigits="0"/></h3>
                      <p class="text-muted small mb-0">
                        <c:choose>
                          <c:when test="${resultado.metrosSueltosNecesarios > 0}">metros sueltos (a medida)</c:when>
                          <c:otherwise>no se necesitan cortes sueltos</c:otherwise>
                        </c:choose>
                      </p>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Datos técnicos del cálculo -->
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
                      <p class="text-muted small mb-0">Área comprada</p>
                      <h5 class="fw-bold mb-0"><fmt:formatNumber value="${resultado.areaComprada}" maxFractionDigits="2"/></h5>
                      <p class="text-muted small mb-0">m²</p>
                    </div>
                  </div>
                  <div class="col-6 col-md-3">
                    <div class="p-2 rounded bg-light">
                      <p class="text-muted small mb-0">Área efectiva/rollo</p>
                      <h5 class="fw-bold mb-0"><fmt:formatNumber value="${resultado.areaEfectivaPorRolloM2}" maxFractionDigits="2"/></h5>
                      <p class="text-muted small mb-0">m²</p>
                    </div>
                  </div>
                  <div class="col-6 col-md-3">
                    <div class="p-2 rounded bg-light">
                      <p class="text-muted small mb-0">Traslapo</p>
                      <h5 class="fw-bold mb-0"><fmt:formatNumber value="${resultado.traslapoM}" maxFractionDigits="2"/></h5>
                      <p class="text-muted small mb-0">m</p>
                    </div>
                  </div>
                </div>
              </div>

              <a href="${pageContext.request.contextPath}/impermeabilizantes" class="btn btn-outline-accent w-100 mt-4">
                <i class="bi bi-droplet-fill me-1"></i> Ver impermeabilizantes disponibles
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

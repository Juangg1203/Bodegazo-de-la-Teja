<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/jsp/fragments/head.jsp"/>
<body>
<jsp:include page="/WEB-INF/jsp/fragments/navbar.jsp"/>

<main>
  <div class="container py-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
      <h1 class="fw-bold mb-0"><i class="bi bi-scissors text-accent me-2"></i>Plan de Cortes</h1>
      <a href="${pageContext.request.contextPath}/plan-cortes" class="btn btn-outline-accent">
        <i class="bi bi-arrow-left me-1"></i> Nuevo cálculo
      </a>
    </div>

    <!-- Resumen -->
    <div class="row g-3 mb-4">
      <div class="col-6 col-md-3">
        <div class="card card-bodegazo p-3 text-center">
          <div class="text-muted small">Láminas usadas</div>
          <div class="fs-3 fw-bold text-accent"><c:out value="${resultado.laminasUsadas}"/></div>
        </div>
      </div>
      <div class="col-6 col-md-3">
        <div class="card card-bodegazo p-3 text-center">
          <div class="text-muted small">Material disponible</div>
          <div class="fs-5 fw-bold"><c:out value="${resultado.materialDisponibleM}"/> m</div>
        </div>
      </div>
      <div class="col-6 col-md-3">
        <div class="card card-bodegazo p-3 text-center">
          <div class="text-muted small">Material usado</div>
          <div class="fs-5 fw-bold"><c:out value="${resultado.materialUsadoM}"/> m</div>
        </div>
      </div>
      <div class="col-6 col-md-3">
        <div class="card card-bodegazo p-3 text-center">
          <div class="text-muted small">Desperdicio total</div>
          <div class="fs-5 fw-bold"><c:out value="${resultado.desperdicioTotalM}"/> m</div>
        </div>
      </div>
    </div>

    <!-- Botón de descarga -->
    <div class="mb-4">
      <form action="${pageContext.request.contextPath}/plan-cortes/pdf-bodeguero" method="post" target="_blank">
        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
        <input type="hidden" name="laminaBase" value="${resultado.laminaBaseM}">
        <c:forEach var="l" items="${largosOriginal}"><input type="hidden" name="largos" value="${l}"></c:forEach>
        <c:forEach var="cant" items="${cantidadesOriginal}"><input type="hidden" name="cantidades" value="${cant}"></c:forEach>
        <button type="submit" class="btn btn-accent w-100 py-3">
          <i class="bi bi-file-earmark-pdf-fill me-1"></i> Descargar plan de cortes (PDF)
        </button>
      </form>
    </div>

    <c:if test="${not empty resultado.pendientes}">
      <div class="alert alert-warning">
        <strong><i class="bi bi-exclamation-triangle-fill me-1"></i>Pendiente por conseguir aparte:</strong>
        <c:forEach var="p" items="${resultado.pendientes}">
          <div class="small mt-1">${p.cantidad} pieza(s) de ${p.largo} m — <c:out value="${p.motivo}"/></div>
        </c:forEach>
      </div>
    </c:if>

    <!-- Detalle por lámina -->
    <div class="card card-bodegazo p-0 overflow-hidden mb-4">
      <div class="table-responsive">
        <table class="table table-hover align-middle mb-0">
          <thead class="table-light">
            <tr>
              <th>Lámina</th>
              <th>Cortes (m)</th>
              <th class="text-end">Total usado</th>
              <th class="text-end">Sobrante</th>
            </tr>
          </thead>
          <tbody>
            <c:forEach var="lamina" items="${resultado.laminas}">
              <tr>
                <td><span class="badge bg-secondary">${lamina.numero}</span></td>
                <td>
                  <c:forEach var="corte" items="${lamina.cortes}" varStatus="s">
                    <c:out value="${corte}"/><c:if test="${!s.last}"> + </c:if>
                  </c:forEach>
                </td>
                <td class="text-end fw-bold"><c:out value="${lamina.totalUsado}"/> m</td>
                <td class="text-end ${lamina.sobrante == 0 ? 'text-success fw-bold' : 'text-muted'}"><c:out value="${lamina.sobrante}"/> m</td>
              </tr>
            </c:forEach>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Verificación -->
    <h6 class="fw-bold mb-2">Verificación de cantidades</h6>
    <div class="d-flex flex-wrap gap-2">
      <c:forEach var="r" items="${resultado.resumenCantidades}">
        <span class="badge bg-light text-dark border">${r.largo} x ${r.cantidad}</span>
      </c:forEach>
    </div>
  </div>
</main>

<jsp:include page="/WEB-INF/jsp/fragments/footer.jsp"/>
<jsp:include page="/WEB-INF/jsp/fragments/scripts.jsp"/>

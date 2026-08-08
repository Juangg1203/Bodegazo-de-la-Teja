<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/jsp/fragments/head.jsp"/>
<body>
<jsp:include page="/WEB-INF/jsp/fragments/navbar.jsp"/>

<main>
  <div class="container py-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
      <h1 class="fw-bold mb-0"><i class="bi bi-box-arrow-up text-accent me-2"></i>Registrar salida</h1>
      <a href="${pageContext.request.contextPath}/inventario" class="btn btn-outline-accent">
        <i class="bi bi-arrow-left me-1"></i> Volver
      </a>
    </div>

    <c:if test="${not empty error}">
      <div class="alert alert-danger"><i class="bi bi-exclamation-triangle-fill me-2"></i><c:out value="${error}"/></div>
    </c:if>

    <div class="alert alert-light border small">
      <i class="bi bi-info-circle text-accent me-1"></i>
      Esto es para ajustes manuales (daños, devoluciones, correcciones de conteo) — las salidas por venta se registran solas al aceptar una cotización.
    </div>

    <div class="card card-bodegazo p-4" style="max-width: 640px;">
      <form action="${pageContext.request.contextPath}/inventario/salidas" method="post">
        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>

        <div class="mb-3">
          <label class="form-label fw-semibold">Producto *</label>
          <select class="form-select" name="productoId" required>
            <option value="">Selecciona...</option>
            <c:forEach var="p" items="${productos}">
              <option value="${p.id}" ${form.productoId == p.id ? 'selected' : ''}><c:out value="${p.nombre} (${p.codigo})"/></option>
            </c:forEach>
          </select>
        </div>

        <div class="mb-3">
          <label class="form-label fw-semibold">Motivo *</label>
          <select class="form-select" name="motivo" required>
            <c:forEach var="m" items="${motivos}">
              <option value="${m}" ${form.motivo == m ? 'selected' : ''}>${m}</option>
            </c:forEach>
          </select>
        </div>

        <div class="mb-3">
          <label class="form-label fw-semibold">Cantidad *</label>
          <input type="number" step="0.01" min="0.01" class="form-control" name="cantidad" value="${form.cantidad}" required>
        </div>

        <div class="mb-4">
          <label class="form-label fw-semibold">Observaciones</label>
          <textarea class="form-control" name="observaciones" rows="3" maxlength="255">${form.observaciones}</textarea>
        </div>

        <button type="submit" class="btn btn-accent w-100">
          <i class="bi bi-check-circle-fill me-1"></i> Registrar salida
        </button>
      </form>
    </div>
  </div>
</main>

<jsp:include page="/WEB-INF/jsp/fragments/footer.jsp"/>
<jsp:include page="/WEB-INF/jsp/fragments/scripts.jsp"/>

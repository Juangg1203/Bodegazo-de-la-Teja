<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/jsp/fragments/head.jsp"/>
<body>
<jsp:include page="/WEB-INF/jsp/fragments/navbar.jsp"/>

<main>
  <div class="container py-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
      <h1 class="fw-bold mb-0"><i class="bi bi-box-arrow-in-down text-accent me-2"></i>Registrar entrada</h1>
      <a href="${pageContext.request.contextPath}/inventario" class="btn btn-outline-accent">
        <i class="bi bi-arrow-left me-1"></i> Volver
      </a>
    </div>

    <c:if test="${not empty error}">
      <div class="alert alert-danger"><c:out value="${error}"/></div>
    </c:if>

    <div class="card card-bodegazo p-4" style="max-width: 640px;">
      <form action="${pageContext.request.contextPath}/inventario/entradas" method="post">
        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>

        <div class="mb-3">
          <label class="form-label fw-semibold">Producto *</label>
          <select class="form-select" name="productoId" required>
            <option value="">Selecciona...</option>
            <c:forEach var="p" items="${productos}">
              <option value="${p.id}"><c:out value="${p.nombre} (${p.codigo})"/></option>
            </c:forEach>
          </select>
        </div>

        <div class="mb-3">
          <label class="form-label fw-semibold">Proveedor</label>
          <select class="form-select" name="proveedorId">
            <option value="">Sin proveedor</option>
            <c:forEach var="prov" items="${proveedores}">
              <option value="${prov.id}"><c:out value="${prov.nombreEmpresa}"/></option>
            </c:forEach>
          </select>
        </div>

        <div class="row g-3 mb-3">
          <div class="col-6">
            <label class="form-label fw-semibold">Cantidad *</label>
            <input type="number" step="0.01" min="0.01" class="form-control" name="cantidad" required>
          </div>
          <div class="col-6">
            <label class="form-label fw-semibold">Costo unitario *</label>
            <div class="input-group">
              <span class="input-group-text">$</span>
              <input type="number" step="0.01" min="0" class="form-control" name="costoUnitario" required>
            </div>
          </div>
        </div>

        <div class="mb-3">
          <label class="form-label fw-semibold">Número de factura</label>
          <input type="text" class="form-control" name="numeroFactura" maxlength="50">
        </div>

        <div class="mb-4">
          <label class="form-label fw-semibold">Observaciones</label>
          <textarea class="form-control" name="observaciones" rows="3" maxlength="255"></textarea>
        </div>

        <button type="submit" class="btn btn-accent w-100">
          <i class="bi bi-check-circle-fill me-1"></i> Registrar entrada
        </button>
      </form>
    </div>
  </div>
</main>

<jsp:include page="/WEB-INF/jsp/fragments/footer.jsp"/>
<jsp:include page="/WEB-INF/jsp/fragments/scripts.jsp"/>

<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/jsp/fragments/head.jsp"/>
<body>
<jsp:include page="/WEB-INF/jsp/fragments/navbar.jsp"/>

<main>
  <div class="container py-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
      <h1 class="fw-bold mb-0">Cotización #<c:out value="${cotizacion.id}"/></h1>
      <a href="${pageContext.request.contextPath}/cotizaciones" class="btn btn-outline-accent">
        <i class="bi bi-arrow-left me-1"></i> Volver
      </a>
    </div>

    <c:if test="${not empty mensaje}">
      <div class="alert alert-success alert-dismissible fade show" role="alert">
        <i class="bi bi-check-circle-fill me-2"></i><c:out value="${mensaje}"/>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
      </div>
    </c:if>

    <div class="row g-4">
      <div class="col-lg-8">
        <div class="card card-bodegazo p-0 overflow-hidden mb-4">
          <div class="table-responsive">
            <table class="table align-middle mb-0">
              <thead class="table-light">
                <tr>
                  <th>Producto</th>
                  <th class="text-end">Cantidad</th>
                  <th class="text-end">Precio unitario</th>
                  <th class="text-end">Subtotal</th>
                </tr>
              </thead>
              <tbody>
                <c:forEach var="item" items="${cotizacion.items}">
                  <tr>
                    <td><c:out value="${item.nombreProducto}"/> <span class="text-muted small">(<c:out value="${item.codigoProducto}"/>)</span></td>
                    <td class="text-end"><c:out value="${item.cantidad}"/></td>
                    <td class="text-end"><fmt:formatNumber value="${item.precioUnitario}" type="currency" currencySymbol="$"/></td>
                    <td class="text-end fw-bold"><fmt:formatNumber value="${item.subtotal}" type="currency" currencySymbol="$"/></td>
                  </tr>
                </c:forEach>
              </tbody>
            </table>
          </div>
        </div>

        <c:if test="${esPersonal && cotizacion.estado == 'PENDIENTE'}">
          <div class="card card-bodegazo p-4">
            <h6 class="fw-bold mb-3">Acciones</h6>
            <div class="d-flex gap-2">
              <form action="${pageContext.request.contextPath}/cotizaciones/${cotizacion.id}/aceptar" method="post" class="flex-fill">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                <button type="submit" class="btn btn-success w-100" onclick="return confirm('¿Aceptar esta cotización? Se generará la venta y se descontará el inventario.');">
                  <i class="bi bi-check-circle-fill me-1"></i> Aceptar y generar venta
                </button>
              </form>
              <form action="${pageContext.request.contextPath}/cotizaciones/${cotizacion.id}/rechazar" method="post" class="flex-fill">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                <button type="submit" class="btn btn-outline-danger w-100" onclick="return confirm('¿Rechazar esta cotización?');">
                  <i class="bi bi-x-circle-fill me-1"></i> Rechazar
                </button>
              </form>
            </div>
          </div>
        </c:if>
      </div>

      <div class="col-lg-4">
        <div class="card card-bodegazo p-4 mb-3">
          <h6 class="fw-bold mb-3">Resumen</h6>
          <div class="d-flex justify-content-between small mb-1">
            <span class="text-muted">Estado</span>
            <c:choose>
              <c:when test="${cotizacion.estado == 'ACEPTADA'}"><span class="badge bg-success">Aceptada</span></c:when>
              <c:when test="${cotizacion.estado == 'RECHAZADA'}"><span class="badge bg-danger">Rechazada</span></c:when>
              <c:when test="${cotizacion.estado == 'VENCIDA'}"><span class="badge bg-secondary">Vencida</span></c:when>
              <c:otherwise><span class="badge bg-warning text-dark">Pendiente</span></c:otherwise>
            </c:choose>
          </div>
          <div class="d-flex justify-content-between small mb-1">
            <span class="text-muted">Cliente</span><span><c:out value="${cotizacion.clienteNombre}"/></span>
          </div>
          <div class="d-flex justify-content-between small mb-1">
            <span class="text-muted">Documento</span><span><c:out value="${cotizacion.clienteDocumento}"/></span>
          </div>
          <div class="d-flex justify-content-between small mb-1">
            <span class="text-muted">Vendedor</span><span><c:out value="${cotizacion.usuarioNombre}"/></span>
          </div>
          <div class="d-flex justify-content-between small mb-3">
            <span class="text-muted">Válida hasta</span><span><c:out value="${cotizacion.fechaValidez}"/></span>
          </div>
          <hr>
          <div class="d-flex justify-content-between small mb-1">
            <span class="text-muted">Subtotal</span><span><fmt:formatNumber value="${cotizacion.subtotal}" type="currency" currencySymbol="$"/></span>
          </div>
          <div class="d-flex justify-content-between small mb-2">
            <span class="text-muted">IVA</span><span><fmt:formatNumber value="${cotizacion.impuesto}" type="currency" currencySymbol="$"/></span>
          </div>
          <div class="d-flex justify-content-between">
            <span class="fw-bold">Total</span>
            <span class="fw-bold text-accent fs-5"><fmt:formatNumber value="${cotizacion.total}" type="currency" currencySymbol="$"/></span>
          </div>
        </div>
      </div>
    </div>
  </div>
</main>

<jsp:include page="/WEB-INF/jsp/fragments/footer.jsp"/>
<jsp:include page="/WEB-INF/jsp/fragments/scripts.jsp"/>

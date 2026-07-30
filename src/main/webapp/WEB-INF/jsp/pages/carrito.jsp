<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/jsp/fragments/head.jsp"/>
<body>
<jsp:include page="/WEB-INF/jsp/fragments/navbar.jsp"/>

<main>
  <div class="container py-5">
    <h1 class="fw-bold mb-4"><i class="bi bi-cart-fill text-accent me-2"></i>Carrito de cotización</h1>

    <c:if test="${not empty mensaje}">
      <div class="alert alert-success alert-dismissible fade show" role="alert">
        <i class="bi bi-check-circle-fill me-2"></i><c:out value="${mensaje}"/>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
      </div>
    </c:if>
    <c:if test="${not empty error}">
      <div class="alert alert-danger"><c:out value="${error}"/></div>
    </c:if>

    <c:choose>
      <c:when test="${empty carrito}">
        <div class="text-center text-muted py-5">
          <i class="bi bi-cart-x fs-1 d-block mb-3"></i>
          <p class="mb-3">Aún no has agregado productos a tu cotización.</p>
          <a href="${pageContext.request.contextPath}/productos" class="btn btn-accent">Ver catálogo</a>
        </div>
      </c:when>
      <c:otherwise>
        <div class="card card-bodegazo p-0 overflow-hidden mb-4">
          <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
              <thead class="table-light">
                <tr>
                  <th>Producto</th>
                  <th class="text-end">Precio unitario</th>
                  <th class="text-end">Cantidad</th>
                  <th class="text-end">Subtotal</th>
                  <th></th>
                </tr>
              </thead>
              <tbody>
                <c:forEach var="item" items="${carrito}">
                  <tr>
                    <td>
                      <c:out value="${item.nombre}"/>
                      <div class="text-muted small"><code><c:out value="${item.codigo}"/></code></div>
                    </td>
                    <td class="text-end"><fmt:formatNumber value="${item.precioUnitario}" type="currency" currencySymbol="$"/></td>
                    <td class="text-end"><c:out value="${item.cantidad}"/></td>
                    <td class="text-end fw-bold"><fmt:formatNumber value="${item.subtotal}" type="currency" currencySymbol="$"/></td>
                    <td class="text-end">
                      <form action="${pageContext.request.contextPath}/cotizaciones/carrito/quitar/${item.productoId}" method="post">
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                        <button type="submit" class="btn btn-sm btn-outline-danger"><i class="bi bi-trash-fill"></i></button>
                      </form>
                    </td>
                  </tr>
                </c:forEach>
              </tbody>
            </table>
          </div>
        </div>

        <div class="row justify-content-end mb-4">
          <div class="col-md-5">
            <div class="card card-bodegazo p-3 text-center">
              <p class="text-muted small mb-1">Total (sin IVA)</p>
              <h3 class="fw-bold text-accent mb-0"><fmt:formatNumber value="${totalCarrito}" type="currency" currencySymbol="$"/></h3>
            </div>
          </div>
        </div>

        <div class="card card-bodegazo p-4">
          <h5 class="fw-bold mb-3">Confirmar cotización</h5>
          <form action="${pageContext.request.contextPath}/cotizaciones/confirmar" method="post">
            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>

            <c:choose>
              <c:when test="${esPersonal}">
                <div class="mb-3">
                  <label class="form-label fw-semibold">Cliente</label>
                  <select class="form-select" name="clienteId" required>
                    <option value="">Selecciona un cliente...</option>
                    <c:forEach var="cli" items="${clientes}">
                      <option value="${cli.id}"><c:out value="${cli.nombre} ${cli.apellido} — ${cli.numeroDocumento}"/></option>
                    </c:forEach>
                  </select>
                </div>
              </c:when>
              <c:otherwise>
                <c:choose>
                  <c:when test="${not empty miCliente}">
                    <input type="hidden" name="clienteId" value="${miCliente.id}">
                    <p class="text-muted small">Esta cotización quedará a tu nombre: <strong><c:out value="${miCliente.nombre} ${miCliente.apellido}"/></strong></p>
                  </c:when>
                  <c:otherwise>
                    <div class="alert alert-warning small mb-0">
                      Tu cuenta aún no tiene un registro de cliente asociado. Contáctanos para completarlo antes de confirmar tu cotización.
                    </div>
                  </c:otherwise>
                </c:choose>
              </c:otherwise>
            </c:choose>

            <button type="submit" class="btn btn-accent w-100 mt-2" ${(!esPersonal && empty miCliente) ? 'disabled' : ''}>
              <i class="bi bi-check-circle-fill me-1"></i> Confirmar cotización
            </button>
          </form>
        </div>
      </c:otherwise>
    </c:choose>
  </div>
</main>

<jsp:include page="/WEB-INF/jsp/fragments/footer.jsp"/>
<jsp:include page="/WEB-INF/jsp/fragments/scripts.jsp"/>

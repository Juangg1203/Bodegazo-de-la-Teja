<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/jsp/fragments/head.jsp"/>
<body>
<jsp:include page="/WEB-INF/jsp/fragments/navbar.jsp"/>

<main>
  <div class="container py-5">
    <div class="d-flex justify-content-between align-items-center flex-wrap gap-3 mb-4">
      <div>
        <h1 class="fw-bold mb-1"><i class="bi bi-box-seam-fill text-accent me-2"></i>Inventario</h1>
        <p class="text-muted mb-0">Consulta el stock y registra entradas o salidas.</p>
      </div>
      <div class="d-flex gap-2">
        <a href="${pageContext.request.contextPath}/inventario/entradas/nueva" class="btn btn-accent">
          <i class="bi bi-box-arrow-in-down me-1"></i> Entrada
        </a>
        <a href="${pageContext.request.contextPath}/inventario/salidas/nueva" class="btn btn-outline-accent">
          <i class="bi bi-box-arrow-up me-1"></i> Salida
        </a>
      </div>
    </div>

    <c:if test="${not empty mensaje}">
      <div class="alert alert-success alert-dismissible fade show" role="alert">
        <i class="bi bi-check-circle-fill me-2"></i><c:out value="${mensaje}"/>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
      </div>
    </c:if>

    <form class="row g-2 mb-4" method="get">
      <div class="col-md-6">
        <div class="input-group">
          <input type="text" class="form-control" name="buscar" placeholder="Buscar por nombre..." value="${buscar}">
          <button class="btn btn-accent" type="submit"><i class="bi bi-search"></i></button>
        </div>
      </div>
    </form>

    <div class="card card-bodegazo p-0 overflow-hidden">
      <div class="table-responsive">
        <table class="table table-hover align-middle mb-0">
          <thead class="table-light">
            <tr>
              <th>Producto</th>
              <th>Código</th>
              <th class="text-end">Stock actual</th>
              <th class="text-end">Stock mínimo</th>
              <th>Ubicación</th>
              <th class="text-center">Estado</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            <c:forEach var="item" items="${inventario.content}">
              <tr class="${item.stockBajo ? 'table-warning' : ''}">
                <td><c:out value="${item.productoNombre}"/></td>
                <td><code><c:out value="${item.productoCodigo}"/></code></td>
                <td class="text-end fw-bold"><c:out value="${item.stockActual}"/></td>
                <td class="text-end"><c:out value="${item.stockMinimo}"/></td>
                <td><c:out value="${item.ubicacion}"/></td>
                <td class="text-center">
                  <c:choose>
                    <c:when test="${item.stockBajo}"><span class="badge bg-danger">Stock bajo</span></c:when>
                    <c:otherwise><span class="badge bg-success">Normal</span></c:otherwise>
                  </c:choose>
                </td>
                <td class="text-end">
                  <a href="${pageContext.request.contextPath}/inventario/${item.productoId}/movimientos" class="btn btn-sm btn-outline-accent">
                    <i class="bi bi-clock-history"></i> Historial
                  </a>
                </td>
              </tr>
            </c:forEach>
            <c:if test="${empty inventario.content}">
              <tr><td colspan="7" class="text-center text-muted py-4">No hay productos que coincidan.</td></tr>
            </c:if>
          </tbody>
        </table>
      </div>
    </div>

    <c:if test="${inventario.totalPages > 1}">
      <nav class="mt-4" aria-label="Paginación">
        <ul class="pagination justify-content-center">
          <c:forEach begin="0" end="${inventario.totalPages - 1}" var="i">
            <li class="page-item ${i == inventario.number ? 'active' : ''}">
              <a class="page-link" href="?pagina=${i}<c:if test="${not empty buscar}">&buscar=${buscar}</c:if>">
                <c:out value="${i + 1}"/>
              </a>
            </li>
          </c:forEach>
        </ul>
      </nav>
    </c:if>
  </div>
</main>

<jsp:include page="/WEB-INF/jsp/fragments/footer.jsp"/>
<jsp:include page="/WEB-INF/jsp/fragments/scripts.jsp"/>

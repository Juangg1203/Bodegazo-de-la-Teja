<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/jsp/fragments/head.jsp"/>
<body>
<jsp:include page="/WEB-INF/jsp/fragments/navbar.jsp"/>

<main>
  <div class="container py-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
      <h1 class="fw-bold mb-0"><i class="bi bi-clock-history text-accent me-2"></i>
        Movimientos — <c:out value="${productoNombre}"/>
      </h1>
      <a href="${pageContext.request.contextPath}/inventario" class="btn btn-outline-accent">
        <i class="bi bi-arrow-left me-1"></i> Volver al inventario
      </a>
    </div>

    <div class="card card-bodegazo p-0 overflow-hidden">
      <div class="table-responsive">
        <table class="table table-hover align-middle mb-0">
          <thead class="table-light">
            <tr>
              <th>Fecha</th>
              <th>Tipo</th>
              <th class="text-end">Cantidad</th>
              <th class="text-end">Stock antes</th>
              <th class="text-end">Stock después</th>
              <th>Usuario</th>
            </tr>
          </thead>
          <tbody>
            <c:forEach var="m" items="${movimientos.content}">
              <tr>
                <td><fmt:formatDate value="${m.fecha}" pattern="dd/MM/yyyy HH:mm"/></td>
                <td>
                  <c:choose>
                    <c:when test="${m.tipoMovimiento == 'ENTRADA'}"><span class="badge bg-success">Entrada</span></c:when>
                    <c:when test="${m.tipoMovimiento == 'SALIDA'}"><span class="badge bg-danger">Salida</span></c:when>
                    <c:when test="${m.tipoMovimiento == 'VENTA'}"><span class="badge bg-primary">Venta</span></c:when>
                    <c:otherwise><span class="badge bg-secondary"><c:out value="${m.tipoMovimiento}"/></span></c:otherwise>
                  </c:choose>
                </td>
                <td class="text-end"><c:out value="${m.cantidad}"/></td>
                <td class="text-end text-muted"><c:out value="${m.stockAnterior}"/></td>
                <td class="text-end fw-bold"><c:out value="${m.stockNuevo}"/></td>
                <td><c:out value="${m.usuarioNombre}"/></td>
              </tr>
            </c:forEach>
            <c:if test="${empty movimientos.content}">
              <tr><td colspan="6" class="text-center text-muted py-4">Este producto aún no tiene movimientos registrados.</td></tr>
            </c:if>
          </tbody>
        </table>
      </div>
    </div>

    <c:if test="${movimientos.totalPages > 1}">
      <nav class="mt-4" aria-label="Paginación">
        <ul class="pagination justify-content-center">
          <c:forEach begin="0" end="${movimientos.totalPages - 1}" var="i">
            <li class="page-item ${i == movimientos.number ? 'active' : ''}">
              <a class="page-link" href="?pagina=${i}"><c:out value="${i + 1}"/></a>
            </li>
          </c:forEach>
        </ul>
      </nav>
    </c:if>
  </div>
</main>

<jsp:include page="/WEB-INF/jsp/fragments/footer.jsp"/>
<jsp:include page="/WEB-INF/jsp/fragments/scripts.jsp"/>

<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/jsp/fragments/head.jsp"/>
<body>
<jsp:include page="/WEB-INF/jsp/fragments/navbar.jsp"/>

<main>
  <div class="container py-5">
    <h1 class="fw-bold mb-4"><i class="bi bi-receipt text-accent me-2"></i>Ventas</h1>

    <div class="card card-bodegazo p-0 overflow-hidden">
      <div class="table-responsive">
        <table class="table table-hover align-middle mb-0">
          <thead class="table-light">
            <tr>
              <th>#</th>
              <th>Cliente</th>
              <th>Fecha</th>
              <th>Método de pago</th>
              <th class="text-end">Total</th>
              <th class="text-center">Estado</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            <c:forEach var="v" items="${ventas.content}">
              <tr>
                <td>#<c:out value="${v.id}"/></td>
                <td><c:out value="${v.clienteNombre}"/></td>
                <td><fmt:formatDate value="${v.fecha}" pattern="dd/MM/yyyy HH:mm"/></td>
                <td><c:out value="${v.metodoPago}"/></td>
                <td class="text-end fw-bold"><fmt:formatNumber value="${v.total}" type="currency" currencySymbol="$"/></td>
                <td class="text-center">
                  <c:choose>
                    <c:when test="${v.estado == 'COMPLETADA'}"><span class="badge bg-success">Completada</span></c:when>
                    <c:when test="${v.estado == 'ANULADA'}"><span class="badge bg-danger">Anulada</span></c:when>
                    <c:otherwise><span class="badge bg-warning text-dark">Pendiente</span></c:otherwise>
                  </c:choose>
                </td>
                <td class="text-end">
                  <a href="${pageContext.request.contextPath}/ventas/${v.id}" class="btn btn-sm btn-outline-accent">Ver</a>
                </td>
              </tr>
            </c:forEach>
            <c:if test="${empty ventas.content}">
              <tr><td colspan="7" class="text-center text-muted py-4">Aún no hay ventas registradas.</td></tr>
            </c:if>
          </tbody>
        </table>
      </div>
    </div>

    <c:if test="${ventas.totalPages > 1}">
      <nav class="mt-4" aria-label="Paginación">
        <ul class="pagination justify-content-center">
          <c:forEach begin="0" end="${ventas.totalPages - 1}" var="i">
            <li class="page-item ${i == ventas.number ? 'active' : ''}">
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

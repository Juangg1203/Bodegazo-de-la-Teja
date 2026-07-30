<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/jsp/fragments/head.jsp"/>
<body>
<jsp:include page="/WEB-INF/jsp/fragments/navbar.jsp"/>

<main>
  <div class="container py-5">
    <h1 class="fw-bold mb-4"><i class="bi bi-file-earmark-text-fill text-accent me-2"></i>
      <c:out value="${esPersonal ? 'Cotizaciones' : 'Mis cotizaciones'}"/>
    </h1>

    <c:if test="${not empty mensaje}">
      <div class="alert alert-success alert-dismissible fade show" role="alert">
        <i class="bi bi-check-circle-fill me-2"></i><c:out value="${mensaje}"/>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
      </div>
    </c:if>

    <div class="card card-bodegazo p-0 overflow-hidden">
      <div class="table-responsive">
        <table class="table table-hover align-middle mb-0">
          <thead class="table-light">
            <tr>
              <th>#</th>
              <c:if test="${esPersonal}"><th>Cliente</th></c:if>
              <th>Emitida</th>
              <th>Válida hasta</th>
              <th class="text-end">Total</th>
              <th class="text-center">Estado</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            <c:forEach var="cot" items="${cotizaciones.content}">
              <tr>
                <td>#<c:out value="${cot.id}"/></td>
                <c:if test="${esPersonal}"><td><c:out value="${cot.clienteNombre}"/></td></c:if>
                <td><fmt:formatDate value="${cot.fechaEmision}" pattern="dd/MM/yyyy"/></td>
                <td><c:out value="${cot.fechaValidez}"/></td>
                <td class="text-end fw-bold"><fmt:formatNumber value="${cot.total}" type="currency" currencySymbol="$"/></td>
                <td class="text-center">
                  <c:choose>
                    <c:when test="${cot.estado == 'ACEPTADA'}"><span class="badge bg-success">Aceptada</span></c:when>
                    <c:when test="${cot.estado == 'RECHAZADA'}"><span class="badge bg-danger">Rechazada</span></c:when>
                    <c:when test="${cot.estado == 'VENCIDA'}"><span class="badge bg-secondary">Vencida</span></c:when>
                    <c:otherwise><span class="badge bg-warning text-dark">Pendiente</span></c:otherwise>
                  </c:choose>
                </td>
                <td class="text-end">
                  <a href="${pageContext.request.contextPath}/cotizaciones/${cot.id}" class="btn btn-sm btn-outline-accent">Ver</a>
                </td>
              </tr>
            </c:forEach>
            <c:if test="${empty cotizaciones.content}">
              <tr><td colspan="7" class="text-center text-muted py-4">Aún no hay cotizaciones.</td></tr>
            </c:if>
          </tbody>
        </table>
      </div>
    </div>

    <c:if test="${cotizaciones.totalPages > 1}">
      <nav class="mt-4" aria-label="Paginación">
        <ul class="pagination justify-content-center">
          <c:forEach begin="0" end="${cotizaciones.totalPages - 1}" var="i">
            <li class="page-item ${i == cotizaciones.number ? 'active' : ''}">
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

<%@ page contentType="text/html;charset=UTF-8" %>
<jsp:include page="/WEB-INF/jsp/fragments/head.jsp"/>
<body>
<jsp:include page="/WEB-INF/jsp/fragments/navbar.jsp"/>
<main>
  <div class="container error-page">
    <i class="bi bi-hammer fs-1 text-accent mb-3 d-block"></i>
    <h2 class="fw-bold mb-3">Esta sección está en construcción</h2>
    <p class="text-muted mb-4">La estamos desarrollando en la siguiente entrega del sistema. Vuelve pronto.</p>
    <a href="${pageContext.request.contextPath}/inicio" class="btn btn-accent">
      <i class="bi bi-house-door-fill me-1"></i> Volver al inicio
    </a>
  </div>
</main>
<jsp:include page="/WEB-INF/jsp/fragments/footer.jsp"/>
<jsp:include page="/WEB-INF/jsp/fragments/scripts.jsp"/>

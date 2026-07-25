<%@ page contentType="text/html;charset=UTF-8" %>
<jsp:include page="/WEB-INF/jsp/fragments/head.jsp"/>
<body>
<jsp:include page="/WEB-INF/jsp/fragments/navbar.jsp"/>
<main>
  <div class="container error-page">
    <i class="bi bi-tools fs-1 text-accent mb-3 d-block"></i>
    <h2 class="fw-bold mb-3">Sitio en mantenimiento</h2>
    <p class="text-muted mb-4">Estamos mejorando la plataforma. Vuelve a intentarlo en unos minutos.</p>
    <a href="${pageContext.request.contextPath}/inicio" class="btn btn-accent">
      <i class="bi bi-house-door-fill me-1"></i> Volver al inicio
    </a>
  </div>
</main>
<jsp:include page="/WEB-INF/jsp/fragments/footer.jsp"/>
<jsp:include page="/WEB-INF/jsp/fragments/scripts.jsp"/>

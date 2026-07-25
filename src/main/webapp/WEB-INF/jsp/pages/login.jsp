<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/jsp/fragments/head.jsp"/>
<body>
<jsp:include page="/WEB-INF/jsp/fragments/navbar.jsp"/>

<main>
  <div class="container">
    <div class="card card-bodegazo auth-card p-4">
      <h3 class="fw-bold text-center mb-1">Iniciar sesión</h3>
      <p class="text-muted text-center mb-4">Accede a tu cuenta de Bodegazo de la Teja</p>

      <c:if test="${not empty error}">
        <div class="alert alert-danger" role="alert">
          <i class="bi bi-exclamation-triangle-fill me-2"></i><c:out value="${error}"/>
        </div>
      </c:if>
      <c:if test="${not empty mensaje}">
        <div class="alert alert-success alert-dismissible fade show" role="alert">
          <i class="bi bi-check-circle-fill me-2"></i><c:out value="${mensaje}"/>
          <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
      </c:if>

      <form action="${pageContext.request.contextPath}/login" method="post">
        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>

        <div class="mb-3">
          <label for="correo" class="form-label">Correo electrónico</label>
          <input type="email" class="form-control" id="correo" name="correo" required autofocus>
        </div>
        <div class="mb-3">
          <label for="password" class="form-label">Contraseña</label>
          <input type="password" class="form-control" id="password" name="password" required>
        </div>
        <div class="form-check mb-3">
          <input class="form-check-input" type="checkbox" id="remember-me" name="remember-me">
          <label class="form-check-label" for="remember-me">Recordarme</label>
        </div>
        <button type="submit" class="btn btn-accent w-100">
          <i class="bi bi-box-arrow-in-right me-1"></i> Iniciar sesión
        </button>
      </form>

      <p class="text-center text-muted small mt-4 mb-0">
        ¿Aún no tienes cuenta? <a href="${pageContext.request.contextPath}/registro">Regístrate aquí</a>
      </p>
    </div>
  </div>
</main>

<jsp:include page="/WEB-INF/jsp/fragments/footer.jsp"/>
<jsp:include page="/WEB-INF/jsp/fragments/scripts.jsp"/>

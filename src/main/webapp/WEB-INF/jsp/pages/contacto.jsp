<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/jsp/fragments/head.jsp"/>
<body>
<jsp:include page="/WEB-INF/jsp/fragments/navbar.jsp"/>

<main>
  <section class="hero-section py-5">
    <div class="container text-center">
      <h1 class="mb-2">Contáctanos</h1>
      <p class="lead mb-0">Escríbenos y te ayudamos a encontrar el material ideal para tu proyecto.</p>
    </div>
  </section>

  <section class="py-5">
    <div class="container">
      <div class="row g-5">
        <div class="col-md-5">
          <h4 class="fw-bold mb-4">Información de contacto</h4>
          <ul class="list-unstyled">
            <li class="mb-3"><i class="bi bi-whatsapp text-accent fs-4 me-2"></i>WhatsApp: <span class="text-muted">próximamente</span></li>
            <li class="mb-3"><i class="bi bi-envelope-fill text-accent fs-4 me-2"></i>Correo: <span class="text-muted">próximamente</span></li>
            <li class="mb-3"><i class="bi bi-geo-alt-fill text-accent fs-4 me-2"></i>Ubicación: <span class="text-muted">próximamente</span></li>
          </ul>
          <div class="ratio ratio-4x3 rounded overflow-hidden mt-4 bg-light d-flex align-items-center justify-content-center text-muted">
            <span><i class="bi bi-map fs-1"></i><br>Mapa de Google Maps (próximamente)</span>
          </div>
        </div>

        <div class="col-md-7">
          <div class="card card-bodegazo p-4">

            <c:if test="${enviado}">
              <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="bi bi-check-circle-fill me-2"></i>
                ¡Gracias, <c:out value="${nombreEnviado}"/>! Recibimos tu mensaje y te contactaremos pronto.
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
              </div>
            </c:if>

            <form action="${pageContext.request.contextPath}/contacto" method="post">
              <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>

              <div class="mb-3">
                <label for="nombre" class="form-label">Nombre completo</label>
                <input type="text" class="form-control" id="nombre" name="nombre" required maxlength="150">
              </div>
              <div class="mb-3">
                <label for="correo" class="form-label">Correo electrónico</label>
                <input type="email" class="form-control" id="correo" name="correo" required maxlength="150">
              </div>
              <div class="mb-3">
                <label for="mensaje" class="form-label">Mensaje</label>
                <textarea class="form-control" id="mensaje" name="mensaje" rows="5" required maxlength="1000"></textarea>
              </div>
              <button type="submit" class="btn btn-accent w-100">
                <i class="bi bi-send-fill me-1"></i> Enviar mensaje
              </button>
            </form>
          </div>
        </div>
      </div>
    </div>
  </section>
</main>

<jsp:include page="/WEB-INF/jsp/fragments/footer.jsp"/>
<jsp:include page="/WEB-INF/jsp/fragments/scripts.jsp"/>

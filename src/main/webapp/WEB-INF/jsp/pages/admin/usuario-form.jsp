<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/jsp/fragments/head.jsp"/>
<body>
<jsp:include page="/WEB-INF/jsp/fragments/navbar.jsp"/>

<main>
  <div class="container py-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
      <h1 class="fw-bold mb-0">
        <i class="bi bi-${not empty form.id ? 'pencil-fill' : 'person-plus-fill'} text-accent me-2"></i>
        <c:out value="${pageTitle}"/>
      </h1>
      <a href="${pageContext.request.contextPath}/usuarios" class="btn btn-outline-accent">
        <i class="bi bi-arrow-left me-1"></i> Volver al listado
      </a>
    </div>

    <c:if test="${not empty error}">
      <div class="alert alert-danger"><c:out value="${error}"/></div>
    </c:if>

    <div class="card card-bodegazo p-4" style="max-width: 640px;">
      <form action="${pageContext.request.contextPath}/usuarios" method="post">
        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
        <c:if test="${not empty form.id}">
          <input type="hidden" name="id" value="${form.id}">
        </c:if>

        <div class="row g-3 mb-3">
          <div class="col-6">
            <label class="form-label fw-semibold">Nombre *</label>
            <input type="text" class="form-control" name="nombre" value="${form.nombre}" required maxlength="80">
          </div>
          <div class="col-6">
            <label class="form-label fw-semibold">Apellido *</label>
            <input type="text" class="form-control" name="apellido" value="${form.apellido}" required maxlength="80">
          </div>
        </div>

        <div class="mb-3">
          <label class="form-label fw-semibold">Correo *</label>
          <input type="email" class="form-control" name="correo" value="${form.correo}" required maxlength="150">
        </div>

        <div class="mb-3">
          <label class="form-label fw-semibold">Teléfono</label>
          <input type="text" class="form-control" name="telefono" value="${form.telefono}" maxlength="20">
        </div>

        <div class="mb-3">
          <label class="form-label fw-semibold">
            Contraseña <c:if test="${empty form.id}">*</c:if>
          </label>
          <input type="password" class="form-control" name="password" ${empty form.id ? 'required' : ''} minlength="4">
          <c:if test="${not empty form.id}">
            <p class="text-muted small mt-1 mb-0">Déjala en blanco para no cambiarla.</p>
          </c:if>
        </div>

        <div class="mb-4">
          <label class="form-label fw-semibold d-block">Roles *</label>
          <c:forEach var="rol" items="${roles}">
            <div class="form-check form-check-inline">
              <input class="form-check-input" type="checkbox" name="rolesIds" value="${rol.id}"
                     id="rol${rol.id}" ${not empty form.rolesIds && form.rolesIds.contains(rol.id) ? 'checked' : ''}>
              <label class="form-check-label" for="rol${rol.id}"><c:out value="${rol.nombre}"/></label>
            </div>
          </c:forEach>
        </div>

        <button type="submit" class="btn btn-accent w-100">
          <i class="bi bi-check-circle-fill me-1"></i> Guardar usuario
        </button>
      </form>
    </div>
  </div>
</main>

<jsp:include page="/WEB-INF/jsp/fragments/footer.jsp"/>
<jsp:include page="/WEB-INF/jsp/fragments/scripts.jsp"/>

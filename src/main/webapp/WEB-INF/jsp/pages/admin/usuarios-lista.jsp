<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/jsp/fragments/head.jsp"/>
<body>
<jsp:include page="/WEB-INF/jsp/fragments/navbar.jsp"/>

<main>
  <div class="container py-5">
    <div class="d-flex justify-content-between align-items-center flex-wrap gap-3 mb-4">
      <div>
        <h1 class="fw-bold mb-1"><i class="bi bi-people-fill text-accent me-2"></i>Administrar Usuarios</h1>
        <p class="text-muted mb-0">Crea, edita y controla el acceso de empleados, jefes de bodega, clientes y administradores.</p>
      </div>
      <a href="${pageContext.request.contextPath}/usuarios/nuevo" class="btn btn-accent">
        <i class="bi bi-person-plus-fill me-1"></i> Nuevo usuario
      </a>
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
          <input type="text" class="form-control" name="buscar" placeholder="Buscar por nombre o correo..." value="${buscar}">
          <button class="btn btn-accent" type="submit"><i class="bi bi-search"></i></button>
        </div>
      </div>
    </form>

    <div class="card card-bodegazo p-0 overflow-hidden">
      <div class="table-responsive">
        <table class="table table-hover align-middle mb-0">
          <thead class="table-light">
            <tr>
              <th>Nombre</th>
              <th>Correo</th>
              <th>Roles</th>
              <th class="text-center">Estado</th>
              <th class="text-end">Acciones</th>
            </tr>
          </thead>
          <tbody>
            <c:forEach var="u" items="${usuarios.content}">
              <tr>
                <td><c:out value="${u.nombre} ${u.apellido}"/></td>
                <td><c:out value="${u.correo}"/></td>
                <td>
                  <c:forEach var="rol" items="${u.roles}">
                    <span class="badge bg-secondary me-1"><c:out value="${rol}"/></span>
                  </c:forEach>
                </td>
                <td class="text-center">
                  <c:choose>
                    <c:when test="${u.activo}"><span class="badge bg-success">Activo</span></c:when>
                    <c:otherwise><span class="badge bg-danger">Inactivo</span></c:otherwise>
                  </c:choose>
                </td>
                <td class="text-end">
                  <a href="${pageContext.request.contextPath}/usuarios/${u.id}/editar" class="btn btn-sm btn-outline-accent">
                    <i class="bi bi-pencil-fill"></i> Editar
                  </a>
                  <c:choose>
                    <c:when test="${u.activo}">
                      <form action="${pageContext.request.contextPath}/usuarios/${u.id}/desactivar" method="post" class="d-inline">
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                        <button type="submit" class="btn btn-sm btn-outline-secondary" onclick="return confirm('¿Desactivar este usuario? No podrá iniciar sesión.');">
                          <i class="bi bi-lock-fill"></i>
                        </button>
                      </form>
                    </c:when>
                    <c:otherwise>
                      <form action="${pageContext.request.contextPath}/usuarios/${u.id}/activar" method="post" class="d-inline">
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                        <button type="submit" class="btn btn-sm btn-outline-success">
                          <i class="bi bi-unlock-fill"></i>
                        </button>
                      </form>
                    </c:otherwise>
                  </c:choose>
                </td>
              </tr>
            </c:forEach>
            <c:if test="${empty usuarios.content}">
              <tr><td colspan="5" class="text-center text-muted py-4">No hay usuarios que coincidan.</td></tr>
            </c:if>
          </tbody>
        </table>
      </div>
    </div>

    <c:if test="${usuarios.totalPages > 1}">
      <nav class="mt-4" aria-label="Paginación">
        <ul class="pagination justify-content-center">
          <c:forEach begin="0" end="${usuarios.totalPages - 1}" var="i">
            <li class="page-item ${i == usuarios.number ? 'active' : ''}">
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

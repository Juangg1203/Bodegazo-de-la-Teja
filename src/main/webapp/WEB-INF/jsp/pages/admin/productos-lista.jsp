<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/jsp/fragments/head.jsp"/>
<body>
<jsp:include page="/WEB-INF/jsp/fragments/navbar.jsp"/>

<main>
  <div class="container py-5">

    <div class="d-flex justify-content-between align-items-center flex-wrap gap-3 mb-4">
      <div>
        <h1 class="fw-bold mb-1"><i class="bi bi-grid-3x3-gap-fill text-accent me-2"></i>Administrar Productos</h1>
        <p class="text-muted mb-0">Crea, edita y controla la disponibilidad del catálogo.</p>
      </div>
      <a href="${pageContext.request.contextPath}/administracion/productos/nuevo?empresa=${empresaActiva}" class="btn btn-accent">
        <i class="bi bi-plus-circle-fill me-1"></i> Nuevo producto
      </a>
    </div>

    <ul class="nav nav-pills mb-4 gap-2">
      <li class="nav-item">
        <a class="nav-link d-flex align-items-center gap-2 ${empresaActiva == 'BODEGAZO' ? 'active bg-dark' : 'bg-light text-dark'}"
           href="${pageContext.request.contextPath}/administracion/productos?empresa=BODEGAZO">
          <span class="bg-white rounded px-1 py-1 d-inline-flex align-items-center">
            <img src="${pageContext.request.contextPath}/images/logo-bodegazo.png" alt="" height="22">
          </span>
          Bodegazo de la Teja <span class="small opacity-75">(Tejas y accesorios)</span>
        </a>
      </li>
      <li class="nav-item">
        <a class="nav-link d-flex align-items-center gap-2 ${empresaActiva == 'MANTO' ? 'active' : 'bg-light text-dark'}"
           href="${pageContext.request.contextPath}/administracion/productos?empresa=MANTO"
           style="${empresaActiva == 'MANTO' ? 'background-color: var(--bodegazo-naranja);' : ''}">
          <span class="bg-white rounded px-1 py-1 d-inline-flex align-items-center">
            <img src="${pageContext.request.contextPath}/images/logo-bodegon-manto.png" alt="" height="22">
          </span>
          El Bodegón del Manto <span class="small opacity-75">(Impermeabilizantes)</span>
        </a>
      </li>
    </ul>

    <c:if test="${not empty mensaje}">
      <div class="alert alert-success alert-dismissible fade show" role="alert">
        <i class="bi bi-check-circle-fill me-2"></i><c:out value="${mensaje}"/>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
      </div>
    </c:if>

    <form class="row g-2 mb-4" method="get">
      <input type="hidden" name="empresa" value="${empresaActiva}">
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
              <th>Categoría</th>
              <th class="text-end">Precio</th>
              <th class="text-center">Estado</th>
              <th class="text-end">Acciones</th>
            </tr>
          </thead>
          <tbody>
            <c:forEach var="producto" items="${productos.content}">
              <tr>
                <td class="d-flex align-items-center gap-2">
                  <c:choose>
                    <c:when test="${not empty producto.imagenPrincipal}">
                      <img src="${producto.imagenPrincipal}" alt="" style="width:44px;height:44px;object-fit:cover;border-radius:6px;">
                    </c:when>
                    <c:otherwise>
                      <div class="d-flex align-items-center justify-content-center bg-light" style="width:44px;height:44px;border-radius:6px;">
                        <i class="bi bi-image text-muted"></i>
                      </div>
                    </c:otherwise>
                  </c:choose>
                  <span><c:out value="${producto.nombre}"/></span>
                </td>
                <td><code><c:out value="${producto.codigo}"/></code></td>
                <td><c:out value="${producto.categoriaNombre}"/></td>
                <td class="text-end"><fmt:formatNumber value="${producto.precioVenta}" type="currency" currencySymbol="$"/></td>
                <td class="text-center">
                  <c:choose>
                    <c:when test="${producto.activo}">
                      <span class="badge bg-success">Activo</span>
                    </c:when>
                    <c:otherwise>
                      <span class="badge bg-secondary">Inactivo</span>
                    </c:otherwise>
                  </c:choose>
                  <c:if test="${!producto.disponible}">
                    <span class="badge bg-danger ms-1">Sin stock</span>
                  </c:if>
                </td>
                <td class="text-end">
                  <a href="${pageContext.request.contextPath}/administracion/productos/${producto.id}/editar" class="btn btn-sm btn-outline-accent">
                    <i class="bi bi-pencil-fill"></i> Editar
                  </a>
                  <c:choose>
                    <c:when test="${producto.activo}">
                      <form action="${pageContext.request.contextPath}/administracion/productos/${producto.id}/desactivar" method="post" class="d-inline">
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                        <button type="submit" class="btn btn-sm btn-outline-secondary" onclick="return confirm('¿Desactivar este producto? Dejará de verse en el catálogo público.');">
                          <i class="bi bi-eye-slash-fill"></i>
                        </button>
                      </form>
                    </c:when>
                    <c:otherwise>
                      <form action="${pageContext.request.contextPath}/administracion/productos/${producto.id}/activar" method="post" class="d-inline">
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                        <button type="submit" class="btn btn-sm btn-outline-success">
                          <i class="bi bi-eye-fill"></i>
                        </button>
                      </form>
                    </c:otherwise>
                  </c:choose>
                </td>
              </tr>
            </c:forEach>
            <c:if test="${empty productos.content}">
              <tr><td colspan="6" class="text-center text-muted py-4">No hay productos que coincidan con la búsqueda.</td></tr>
            </c:if>
          </tbody>
        </table>
      </div>
    </div>

    <c:if test="${productos.totalPages > 1}">
      <nav class="mt-4" aria-label="Paginación de productos">
        <ul class="pagination justify-content-center">
          <c:forEach begin="0" end="${productos.totalPages - 1}" var="i">
            <li class="page-item ${i == productos.number ? 'active' : ''}">
              <a class="page-link" href="?pagina=${i}&empresa=${empresaActiva}<c:if test="${not empty buscar}">&buscar=${buscar}</c:if>">
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

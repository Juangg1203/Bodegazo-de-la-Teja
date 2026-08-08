<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/jsp/fragments/head.jsp"/>
<body>
<jsp:include page="/WEB-INF/jsp/fragments/navbar.jsp"/>

<main>
  <section class="hero-section py-5">
    <div class="container text-center">
      <c:if test="${not empty logoSeccion}">
        <span class="bg-white rounded px-3 py-2 d-inline-flex align-items-center mb-3">
          <img src="${pageContext.request.contextPath}${logoSeccion}" alt="${subtituloSeccion}" width="200" style="height:auto;">
        </span>
      </c:if>
      <h1 class="mb-1"><c:out value="${tituloSeccion}"/></h1>
      <c:if test="${not empty subtituloSeccion}">
        <p class="mb-2 opacity-75"><c:out value="${subtituloSeccion}"/></p>
      </c:if>
      <p class="lead mb-0">Encuentra el producto ideal para tu proyecto.</p>
    </div>
  </section>

  <section class="py-5">
    <div class="container">

      <form class="row g-2 justify-content-center mb-5" method="get">
        <div class="col-md-6">
          <div class="input-group">
            <input type="text" class="form-control" name="buscar" placeholder="Buscar por nombre..." value="${buscar}">
            <button class="btn btn-accent" type="submit"><i class="bi bi-search"></i></button>
          </div>
        </div>
      </form>

      <c:choose>
        <c:when test="${empty productos.content}">
          <div class="text-center text-muted py-5">
            <i class="bi bi-box-seam fs-1 d-block mb-3"></i>
            <p class="mb-0">No encontramos productos con ese criterio de búsqueda.</p>
          </div>
        </c:when>
        <c:otherwise>
          <div class="row g-4">
            <c:forEach var="producto" items="${productos.content}">
              <div class="col-sm-6 col-lg-3">
                <div class="card card-bodegazo h-100">
                  <c:choose>
                    <c:when test="${not empty producto.imagenPrincipal}">
                      <img src="${producto.imagenPrincipal}" class="card-img-top" alt="${producto.nombre}" style="height:180px;object-fit:cover;border-radius:0.75rem 0.75rem 0 0;">
                    </c:when>
                    <c:otherwise>
                      <div class="d-flex align-items-center justify-content-center bg-light" style="height:180px;border-radius:0.75rem 0.75rem 0 0;">
                        <i class="bi bi-image fs-1 text-muted"></i>
                      </div>
                    </c:otherwise>
                  </c:choose>
                  <div class="card-body d-flex flex-column">
                    <c:if test="${not empty producto.marcaNombre}">
                      <span class="badge bg-secondary align-self-start mb-2"><c:out value="${producto.marcaNombre}"/></span>
                    </c:if>
                    <h6 class="fw-bold"><c:out value="${producto.nombre}"/></h6>
                    <p class="fw-bold text-accent mb-2">
                      <fmt:formatNumber value="${producto.precioVenta}" type="currency" currencySymbol="$"/>
                    </p>
                    <c:choose>
                      <c:when test="${producto.disponible}">
                        <span class="badge bg-success mb-3 align-self-start">Disponible</span>
                      </c:when>
                      <c:otherwise>
                        <span class="badge bg-danger mb-3 align-self-start">Agotado</span>
                      </c:otherwise>
                    </c:choose>
                    <a href="${pageContext.request.contextPath}/productos/${producto.id}" class="btn btn-outline-accent mt-auto btn-sm">
                      Ver detalle
                    </a>
                  </div>
                </div>
              </div>
            </c:forEach>
          </div>

          <c:if test="${productos.totalPages > 1}">
            <nav class="mt-5" aria-label="Paginación de productos">
              <ul class="pagination justify-content-center">
                <c:forEach begin="0" end="${productos.totalPages - 1}" var="i">
                  <li class="page-item ${i == productos.number ? 'active' : ''}">
                    <a class="page-link"
                       href="?pagina=${i}<c:if test="${not empty buscar}">&buscar=${buscar}</c:if>">
                       <c:out value="${i + 1}"/>
                    </a>
                  </li>
                </c:forEach>
              </ul>
            </nav>
          </c:if>
        </c:otherwise>
      </c:choose>

    </div>
  </section>
</main>

<jsp:include page="/WEB-INF/jsp/fragments/footer.jsp"/>
<jsp:include page="/WEB-INF/jsp/fragments/scripts.jsp"/>

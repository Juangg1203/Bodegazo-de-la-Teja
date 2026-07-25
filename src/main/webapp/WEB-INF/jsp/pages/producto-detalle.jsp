<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/jsp/fragments/head.jsp"/>
<body>
<jsp:include page="/WEB-INF/jsp/fragments/navbar.jsp"/>

<main>
  <div class="container py-5">

    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/inicio">Inicio</a></li>
        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/productos">Productos</a></li>
        <li class="breadcrumb-item active" aria-current="page"><c:out value="${producto.nombre}"/></li>
      </ol>
    </nav>

    <div class="row g-5">
      <div class="col-md-6">
        <c:choose>
          <c:when test="${not empty producto.imagenPrincipal}">
            <img src="${producto.imagenPrincipal}" class="img-fluid rounded card-bodegazo" alt="${producto.nombre}">
          </c:when>
          <c:otherwise>
            <div class="d-flex align-items-center justify-content-center bg-light rounded card-bodegazo" style="height:360px;">
              <i class="bi bi-image fs-1 text-muted"></i>
            </div>
          </c:otherwise>
        </c:choose>

        <c:if test="${not empty producto.galeria}">
          <div class="row g-2 mt-2">
            <c:forEach var="img" items="${producto.galeria}">
              <div class="col-3">
                <img src="${img}" class="img-fluid rounded" alt="Galería">
              </div>
            </c:forEach>
          </div>
        </c:if>
      </div>

      <div class="col-md-6">
        <c:if test="${not empty producto.marcaNombre}">
          <span class="badge bg-secondary mb-2"><c:out value="${producto.marcaNombre}"/></span>
        </c:if>
        <h1 class="fw-bold"><c:out value="${producto.nombre}"/></h1>
        <p class="text-muted">Código: <c:out value="${producto.codigo}"/> &middot; Categoría: <c:out value="${producto.categoriaNombre}"/></p>

        <h2 class="text-accent fw-bold my-3">
          <fmt:formatNumber value="${producto.precioVenta}" type="currency" currencySymbol="$"/>
          <small class="fs-6 text-muted">/ <c:out value="${producto.unidadMedida}"/></small>
        </h2>

        <c:choose>
          <c:when test="${producto.disponible}">
            <span class="badge bg-success mb-3"><i class="bi bi-check-circle-fill me-1"></i>Disponible</span>
          </c:when>
          <c:otherwise>
            <span class="badge bg-danger mb-3"><i class="bi bi-x-circle-fill me-1"></i>Agotado</span>
          </c:otherwise>
        </c:choose>

        <p class="text-muted"><c:out value="${producto.descripcion}"/></p>

        <c:if test="${not empty producto.largoM}">
          <ul class="list-unstyled small text-muted">
            <li><i class="bi bi-arrows-expand me-2"></i>Largo: <c:out value="${producto.largoM}"/> m &middot; Ancho: <c:out value="${producto.anchoM}"/> m</li>
          </ul>
        </c:if>

        <div class="d-flex gap-2 mt-4">
          <c:if test="${producto.tipoProducto == 'TEJA_UPVC'}">
            <a href="${pageContext.request.contextPath}/calculadora-tejas" class="btn btn-accent">
              <i class="bi bi-calculator-fill me-1"></i> Calcular cantidad necesaria
            </a>
          </c:if>
          <c:if test="${producto.tipoProducto == 'IMPERMEABILIZANTE'}">
            <a href="${pageContext.request.contextPath}/calculadora-mantos" class="btn btn-accent">
              <i class="bi bi-calculator-fill me-1"></i> Calcular cantidad necesaria
            </a>
          </c:if>
          <a href="${pageContext.request.contextPath}/contacto" class="btn btn-outline-accent">
            <i class="bi bi-chat-dots-fill me-1"></i> Solicitar cotización
          </a>
        </div>

        <c:if test="${not empty producto.fichaTecnicaPdf}">
          <a href="${producto.fichaTecnicaPdf}" class="d-inline-block mt-3 small" target="_blank">
            <i class="bi bi-file-earmark-pdf-fill text-accent me-1"></i> Descargar ficha técnica (PDF)
          </a>
        </c:if>
      </div>
    </div>
  </div>
</main>

<jsp:include page="/WEB-INF/jsp/fragments/footer.jsp"/>
<jsp:include page="/WEB-INF/jsp/fragments/scripts.jsp"/>

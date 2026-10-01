<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
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
          <c:when test="${fn:length(producto.galeria) >= 2}">
            <div id="visor360" class="rounded card-bodegazo position-relative" style="cursor: grab; overflow:hidden;">
              <img id="imagen360" src="${producto.galeria[0]}" class="img-fluid w-100" alt="${producto.nombre} — vista 360°" draggable="false">
              <span class="badge bg-dark bg-opacity-75 position-absolute top-0 end-0 m-2">
                <i class="bi bi-arrow-repeat me-1"></i> Arrastra para girar
              </span>
            </div>
            <script>
              (function () {
                var fotos = [
                  <c:forEach var="img" items="${producto.galeria}" varStatus="s">'${img}'<c:if test="${!s.last}">,</c:if></c:forEach>
                ];
                var visor = document.getElementById('visor360');
                var imagen = document.getElementById('imagen360');
                var indiceActual = 0;
                var arrastrando = false;
                var xInicial = 0;
                var PIXELES_POR_FRAME = 12; // sensibilidad del arrastre

                function mostrarFrame(indice) {
                  indiceActual = ((indice % fotos.length) + fotos.length) % fotos.length;
                  imagen.src = fotos[indiceActual];
                }

                function empezar(x) {
                  arrastrando = true;
                  xInicial = x;
                  visor.style.cursor = 'grabbing';
                }
                function mover(x) {
                  if (!arrastrando) return;
                  var delta = x - xInicial;
                  if (Math.abs(delta) >= PIXELES_POR_FRAME) {
                    var pasos = Math.trunc(delta / PIXELES_POR_FRAME);
                    mostrarFrame(indiceActual - pasos); // arrastrar a la derecha gira "hacia atrás", como en la mayoría de visores 360
                    xInicial = x;
                  }
                }
                function terminar() {
                  arrastrando = false;
                  visor.style.cursor = 'grab';
                }

                visor.addEventListener('mousedown', function (e) { empezar(e.clientX); });
                window.addEventListener('mousemove', function (e) { mover(e.clientX); });
                window.addEventListener('mouseup', terminar);

                visor.addEventListener('touchstart', function (e) { empezar(e.touches[0].clientX); }, {passive: true});
                visor.addEventListener('touchmove', function (e) { mover(e.touches[0].clientX); }, {passive: true});
                visor.addEventListener('touchend', terminar);
              })();
            </script>
          </c:when>
          <c:when test="${not empty producto.imagenPrincipal}">
            <img src="${producto.imagenPrincipal}" class="img-fluid rounded card-bodegazo" alt="${producto.nombre}">
          </c:when>
          <c:otherwise>
            <div class="d-flex align-items-center justify-content-center bg-light rounded card-bodegazo" style="height:360px;">
              <i class="bi bi-image fs-1 text-muted"></i>
            </div>
          </c:otherwise>
        </c:choose>

        <c:if test="${fn:length(producto.galeria) < 2 && not empty producto.galeria}">
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
          <sec:authorize access="hasRole('EMPLEADO')">
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
          </sec:authorize>
          <sec:authorize access="isAuthenticated()">
            <form action="${pageContext.request.contextPath}/cotizaciones/carrito/agregar" method="post" class="d-flex gap-2">
              <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
              <input type="hidden" name="productoId" value="${producto.id}">
              <input type="number" name="cantidad" value="1" min="1" step="1" class="form-control" style="width:90px;">
              <button type="submit" class="btn btn-outline-accent">
                <i class="bi bi-cart-plus-fill me-1"></i> Agregar a cotización
              </button>
            </form>
          </sec:authorize>
          <sec:authorize access="!isAuthenticated()">
            <a href="${pageContext.request.contextPath}/login" class="btn btn-outline-accent">
              <i class="bi bi-box-arrow-in-right me-1"></i> Inicia sesión para cotizar
            </a>
          </sec:authorize>
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

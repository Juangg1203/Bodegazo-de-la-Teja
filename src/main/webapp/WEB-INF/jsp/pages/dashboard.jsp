<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/jsp/fragments/head.jsp"/>
<body>
<jsp:include page="/WEB-INF/jsp/fragments/navbar.jsp"/>

<main>
  <div class="container py-5">
    <h1 class="fw-bold mb-1">¡Bienvenido, <c:out value="${usuario.nombre}"/>!</h1>
    <p class="text-muted mb-4">
      <c:out value="${usuario.correo}"/>
      <c:forEach var="rol" items="${usuario.authorities}">
        <span class="badge bg-secondary ms-1"><c:out value="${rol.authority}"/></span>
      </c:forEach>
    </p>

    <!-- ================= ADMINISTRADOR: reportes generales ================= -->
    <c:if test="${esAdmin}">
      <h5 class="fw-bold mb-3"><i class="bi bi-graph-up-arrow text-accent me-2"></i>Reportes generales</h5>
      <div class="row g-3 mb-4">
        <div class="col-6 col-md-3">
          <div class="card card-bodegazo p-3 text-center">
            <i class="bi bi-grid-3x3-gap-fill fs-3 text-accent mb-1"></i>
            <h3 class="fw-bold mb-0"><c:out value="${totalProductos}"/></h3>
            <p class="text-muted small mb-0">Productos</p>
          </div>
        </div>
        <div class="col-6 col-md-3">
          <div class="card card-bodegazo p-3 text-center">
            <i class="bi bi-people-fill fs-3 text-accent mb-1"></i>
            <h3 class="fw-bold mb-0"><c:out value="${totalUsuarios}"/></h3>
            <p class="text-muted small mb-0">Usuarios</p>
          </div>
        </div>
        <div class="col-6 col-md-3">
          <div class="card card-bodegazo p-3 text-center">
            <i class="bi bi-person-vcard-fill fs-3 text-accent mb-1"></i>
            <h3 class="fw-bold mb-0"><c:out value="${totalClientes}"/></h3>
            <p class="text-muted small mb-0">Clientes</p>
          </div>
        </div>
        <div class="col-6 col-md-3">
          <div class="card p-3 text-center text-white" style="background-color: ${cantidadStockBajo > 0 ? '#9a2b1f' : 'var(--bodegazo-azul)'};">
            <i class="bi bi-exclamation-triangle-fill fs-3 mb-1"></i>
            <h3 class="fw-bold mb-0"><c:out value="${cantidadStockBajo}"/></h3>
            <p class="small mb-0">Productos con stock bajo</p>
          </div>
        </div>
      </div>
      <div class="row g-3 mb-4">
        <div class="col-md-4">
          <a href="${pageContext.request.contextPath}/usuarios" class="btn btn-outline-accent w-100 py-3">
            <i class="bi bi-people-fill me-2"></i>Gestionar usuarios
          </a>
        </div>
        <div class="col-md-4">
          <a href="${pageContext.request.contextPath}/inventario" class="btn btn-outline-accent w-100 py-3">
            <i class="bi bi-box-seam-fill me-2"></i>Ver inventario
          </a>
        </div>
        <div class="col-md-4">
          <a href="${pageContext.request.contextPath}/reportes" class="btn btn-outline-accent w-100 py-3">
            <i class="bi bi-file-earmark-bar-graph-fill me-2"></i>Reportes detallados
          </a>
        </div>
      </div>

      <h5 class="fw-bold mb-3 mt-5"><i class="bi bi-bar-chart-line-fill text-accent me-2"></i>Gráficos</h5>
      <div class="row g-3 mb-4">
        <div class="col-lg-6">
          <div class="card card-bodegazo p-3">
            <h6 class="fw-bold mb-3">Ventas de los últimos 7 días</h6>
            <canvas id="graficoVentas" height="220"></canvas>
          </div>
        </div>
        <div class="col-lg-6">
          <div class="card card-bodegazo p-3">
            <h6 class="fw-bold mb-3">Productos activos por categoría</h6>
            <canvas id="graficoCategorias" height="220"></canvas>
          </div>
        </div>
        <div class="col-12">
          <div class="card card-bodegazo p-3">
            <h6 class="fw-bold mb-3">Top 5 productos más vendidos</h6>
            <canvas id="graficoTop" height="140"></canvas>
          </div>
        </div>
      </div>

      <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.4/chart.umd.min.js"></script>
      <script>
        document.addEventListener('DOMContentLoaded', function () {
          const colorAccent = '#9a2b1f';
          const colorAzul = '#1c1c1c';
          const paletaCategorias = ['#9a2b1f', '#1c1c1c', '#c9773f', '#5a5a5a', '#e0a377'];

          // Ventas últimos 7 días (línea)
          new Chart(document.getElementById('graficoVentas'), {
            type: 'line',
            data: {
              labels: [<c:forEach var="e" items="${etiquetasVentas}" varStatus="s">'<c:out value="${e}"/>'<c:if test="${!s.last}">,</c:if></c:forEach>],
              datasets: [{
                label: 'Ventas ($)',
                data: [<c:forEach var="v" items="${valoresVentas}" varStatus="s">${v}<c:if test="${!s.last}">,</c:if></c:forEach>],
                borderColor: colorAccent,
                backgroundColor: 'rgba(154,43,31,0.12)',
                tension: 0.35,
                fill: true,
                pointBackgroundColor: colorAccent
              }]
            },
            options: { plugins: { legend: { display: false } }, scales: { y: { beginAtZero: true } } }
          });

          // Productos por categoría (dona)
          new Chart(document.getElementById('graficoCategorias'), {
            type: 'doughnut',
            data: {
              labels: [<c:forEach var="e" items="${etiquetasCategorias}" varStatus="s">'<c:out value="${e}"/>'<c:if test="${!s.last}">,</c:if></c:forEach>],
              datasets: [{
                data: [<c:forEach var="v" items="${valoresCategorias}" varStatus="s">${v}<c:if test="${!s.last}">,</c:if></c:forEach>],
                backgroundColor: paletaCategorias
              }]
            },
            options: { plugins: { legend: { position: 'bottom' } } }
          });

          // Top productos más vendidos (barras horizontales)
          new Chart(document.getElementById('graficoTop'), {
            type: 'bar',
            data: {
              labels: [<c:forEach var="e" items="${etiquetasTop}" varStatus="s">'<c:out value="${e}"/>'<c:if test="${!s.last}">,</c:if></c:forEach>],
              datasets: [{
                label: 'Unidades vendidas',
                data: [<c:forEach var="v" items="${valoresTop}" varStatus="s">${v}<c:if test="${!s.last}">,</c:if></c:forEach>],
                backgroundColor: colorAzul
              }]
            },
            options: { indexAxis: 'y', plugins: { legend: { display: false } }, scales: { x: { beginAtZero: true } } }
          });
        });
      </script>
    </c:if>

    <!-- ================= JEFE DE BODEGA: alerta de inventario ================= -->
    <c:if test="${esJefeBodega}">
      <h5 class="fw-bold mb-3"><i class="bi bi-box-seam-fill text-accent me-2"></i>Estado del inventario</h5>
      <c:choose>
        <c:when test="${cantidadStockBajo > 0}">
          <div class="alert alert-warning shadow-sm">
            <i class="bi bi-exclamation-triangle-fill me-2"></i>
            Tienes <strong><c:out value="${cantidadStockBajo}"/></strong> producto(s) con stock igual o por debajo del mínimo.
          </div>
          <div class="card card-bodegazo p-3 mb-4">
            <table class="table table-sm mb-0">
              <thead>
                <tr><th>Producto</th><th class="text-end">Stock actual</th><th class="text-end">Stock mínimo</th></tr>
              </thead>
              <tbody>
                <c:forEach var="item" items="${stockBajo}">
                  <tr>
                    <td><c:out value="${item.producto.nombre}"/></td>
                    <td class="text-end text-danger fw-bold"><c:out value="${item.stockActual}"/></td>
                    <td class="text-end"><c:out value="${item.stockMinimo}"/></td>
                  </tr>
                </c:forEach>
              </tbody>
            </table>
          </div>
        </c:when>
        <c:otherwise>
          <div class="alert alert-success shadow-sm mb-4">
            <i class="bi bi-check-circle-fill me-2"></i>Todo el inventario está por encima del stock mínimo.
          </div>
        </c:otherwise>
      </c:choose>
      <div class="row g-3 mb-4">
        <div class="col-md-4">
          <a href="${pageContext.request.contextPath}/inventario" class="btn btn-outline-accent w-100 py-3">
            <i class="bi bi-box-seam-fill me-2"></i>Gestionar inventario
          </a>
        </div>
        <div class="col-md-4">
          <a href="${pageContext.request.contextPath}/calculadora-tejas" class="btn btn-outline-accent w-100 py-3">
            <i class="bi bi-calculator-fill me-2"></i>Calculadora de Tejas
          </a>
        </div>
        <div class="col-md-4">
          <a href="${pageContext.request.contextPath}/calculadora-mantos" class="btn btn-outline-accent w-100 py-3">
            <i class="bi bi-calculator-fill me-2"></i>Calculadora de Mantos
          </a>
        </div>
      </div>
    </c:if>

    <!-- ================= EMPLEADO: accesos rápidos de venta ================= -->
    <c:if test="${esEmpleado}">
      <h5 class="fw-bold mb-3"><i class="bi bi-headset text-accent me-2"></i>Accesos rápidos</h5>
      <div class="row g-3 mb-4">
        <div class="col-md-3">
          <a href="${pageContext.request.contextPath}/productos" class="btn btn-outline-accent w-100 py-3">
            <i class="bi bi-grid-3x3-gap-fill me-2"></i>Catálogo
          </a>
        </div>
        <div class="col-md-3">
          <a href="${pageContext.request.contextPath}/calculadora-tejas" class="btn btn-outline-accent w-100 py-3">
            <i class="bi bi-calculator-fill me-2"></i>Calculadora de Tejas
          </a>
        </div>
        <div class="col-md-3">
          <a href="${pageContext.request.contextPath}/calculadora-mantos" class="btn btn-outline-accent w-100 py-3">
            <i class="bi bi-calculator-fill me-2"></i>Calculadora de Mantos
          </a>
        </div>
        <div class="col-md-3">
          <a href="${pageContext.request.contextPath}/cotizaciones" class="btn btn-outline-accent w-100 py-3">
            <i class="bi bi-file-earmark-text-fill me-2"></i>Cotizaciones
          </a>
        </div>
      </div>
    </c:if>

    <!-- ================= CLIENTE: bienvenida simple ================= -->
    <c:if test="${esCliente}">
      <div class="alert alert-light border">
        <i class="bi bi-info-circle text-accent me-2"></i>
        Desde aquí podrás ver tus cotizaciones y pedidos cuando ese módulo esté disponible.
      </div>
      <div class="row g-3 mb-4">
        <div class="col-md-6">
          <a href="${pageContext.request.contextPath}/productos" class="btn btn-outline-accent w-100 py-3">
            <i class="bi bi-grid-3x3-gap-fill me-2"></i>Ver catálogo
          </a>
        </div>
        <div class="col-md-6">
          <a href="${pageContext.request.contextPath}/contacto" class="btn btn-outline-accent w-100 py-3">
            <i class="bi bi-chat-dots-fill me-2"></i>Solicitar cotización
          </a>
        </div>
      </div>
    </c:if>
  </div>
</main>

<jsp:include page="/WEB-INF/jsp/fragments/footer.jsp"/>
<jsp:include page="/WEB-INF/jsp/fragments/scripts.jsp"/>

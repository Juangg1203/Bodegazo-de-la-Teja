<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
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

    <!-- ================= ADMINISTRADOR: panel administrativo, estadísticas y control ================= -->
    <c:if test="${esAdmin}">
      <div class="alert alert-light border d-flex align-items-center mb-4">
        <i class="bi bi-shield-lock-fill text-accent fs-4 me-2"></i>
        <div>
          <strong>Panel de Administración</strong> — gestión, estadísticas y control del sistema.
          La venta, cotización y consulta del catálogo son funciones operativas de Empleados, Jefe de Bodega y Clientes.
        </div>
      </div>
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
        <div class="col-md-3">
          <a href="${pageContext.request.contextPath}/usuarios" class="btn btn-outline-accent w-100 py-3">
            <i class="bi bi-people-fill me-2"></i>Gestionar usuarios
          </a>
        </div>
        <div class="col-md-3">
          <a href="${pageContext.request.contextPath}/administracion/productos" class="btn btn-outline-accent w-100 py-3">
            <i class="bi bi-gear-fill me-2"></i>Administrar productos
          </a>
        </div>
        <div class="col-md-3">
          <a href="${pageContext.request.contextPath}/inventario" class="btn btn-outline-accent w-100 py-3">
            <i class="bi bi-box-seam-fill me-2"></i>Ver inventario
          </a>
        </div>
        <div class="col-md-3">
          <a href="#graficosAdmin" class="btn btn-outline-accent w-100 py-3">
            <i class="bi bi-file-earmark-bar-graph-fill me-2"></i>Ver estadísticas
          </a>
        </div>
      </div>

      <h5 id="graficosAdmin" class="fw-bold mb-3 mt-5"><i class="bi bi-bar-chart-line-fill text-accent me-2"></i>Gráficos</h5>
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

      <c:if test="${not empty movimientosRecientes}">
        <h6 class="fw-bold mb-2">Movimientos recientes de inventario</h6>
        <div class="card card-bodegazo p-0 overflow-hidden mb-4">
          <table class="table table-hover align-middle mb-0">
            <thead class="table-light">
              <tr><th>Producto</th><th>Tipo</th><th class="text-end">Cantidad</th><th>Fecha</th></tr>
            </thead>
            <tbody>
              <c:forEach var="m" items="${movimientosRecientes}">
                <tr>
                  <td><c:out value="${m.producto.nombre}"/></td>
                  <td>
                    <c:choose>
                      <c:when test="${m.tipoMovimiento == 'ENTRADA'}"><span class="badge bg-success">Entrada</span></c:when>
                      <c:when test="${m.tipoMovimiento == 'SALIDA'}"><span class="badge bg-danger">Salida</span></c:when>
                      <c:when test="${m.tipoMovimiento == 'VENTA'}"><span class="badge bg-primary">Venta</span></c:when>
                      <c:otherwise><span class="badge bg-secondary"><c:out value="${m.tipoMovimiento}"/></span></c:otherwise>
                    </c:choose>
                  </td>
                  <td class="text-end"><c:out value="${m.cantidad}"/></td>
                  <td><c:out value="${m.fechaFormateada}"/></td>
                </tr>
              </c:forEach>
            </tbody>
          </table>
        </div>
      </c:if>

      <%-- Apartado separado a propósito: Plan de Cortes, Inventario y
           Administrar Productos ya no están en la barra de arriba (recargaba
           la navegación); se consultan de vez en cuando, así que quedan aquí
           agrupados en su propio bloque "Herramientas de Bodega". --%>
      <div class="card card-bodegazo p-3 mb-4" style="border-style:dashed;">
        <h6 class="fw-bold mb-3 text-muted">
          <i class="bi bi-tools me-2"></i>Herramientas de Bodega
          <span class="badge bg-secondary fw-normal ms-1">uso ocasional</span>
        </h6>
        <div class="row g-3">
          <div class="col-md-4">
            <a href="${pageContext.request.contextPath}/inventario" class="btn btn-outline-accent w-100 py-3">
              <i class="bi bi-box-seam-fill me-2"></i>Gestionar inventario
            </a>
          </div>
          <div class="col-md-4">
            <a href="${pageContext.request.contextPath}/plan-cortes" class="btn btn-outline-accent w-100 py-3">
              <i class="bi bi-scissors me-2"></i>Plan de Cortes
            </a>
          </div>
          <div class="col-md-4">
            <a href="${pageContext.request.contextPath}/administracion/productos" class="btn btn-outline-accent w-100 py-3">
              <i class="bi bi-gear-fill me-2"></i>Administrar Productos
            </a>
          </div>
        </div>
      </div>
    </c:if>

    <!-- ================= EMPLEADO: mis ventas de hoy + cotizaciones pendientes ================= -->
    <c:if test="${esEmpleado}">
      <div class="row g-3 mb-4">
        <div class="col-md-6">
          <div class="card card-bodegazo p-4 text-center">
            <div class="text-muted small">Mis ventas de hoy</div>
            <div class="fs-2 fw-bold text-accent"><c:out value="${ventasHoyCantidad}"/></div>
            <div class="text-muted">$<fmt:formatNumber value="${ventasHoyTotal}" type="number" groupingUsed="true" maxFractionDigits="0"/></div>
          </div>
        </div>
        <div class="col-md-6">
          <div class="card card-bodegazo p-4 text-center">
            <div class="text-muted small">Cotizaciones pendientes por atender</div>
            <div class="fs-2 fw-bold text-accent"><c:out value="${cotizacionesPendientes.size()}"/></div>
            <a href="${pageContext.request.contextPath}/cotizaciones" class="small">Ver todas →</a>
          </div>
        </div>
      </div>

      <c:if test="${not empty cotizacionesPendientes}">
        <h6 class="fw-bold mb-2">Últimas cotizaciones pendientes</h6>
        <div class="card card-bodegazo p-0 overflow-hidden mb-4">
          <table class="table table-hover align-middle mb-0">
            <tbody>
              <c:forEach var="cot" items="${cotizacionesPendientes}">
                <tr>
                  <td>#<c:out value="${cot.id}"/></td>
                  <td><c:out value="${cot.clienteNombre}"/></td>
                  <td class="text-end">$<fmt:formatNumber value="${cot.total}" type="number" groupingUsed="true" maxFractionDigits="0"/></td>
                  <td class="text-end">
                    <a href="${pageContext.request.contextPath}/cotizaciones/${cot.id}" class="btn btn-sm btn-outline-accent">Ver</a>
                  </td>
                </tr>
              </c:forEach>
            </tbody>
          </table>
        </div>
      </c:if>

      <h5 class="fw-bold mb-3"><i class="bi bi-headset text-accent me-2"></i>Accesos rápidos</h5>
      <div class="row g-3 mb-4">
        <div class="col-md-3">
          <a href="${pageContext.request.contextPath}/ventas/rapida" class="btn btn-accent w-100 py-3">
            <i class="bi bi-lightning-charge-fill me-2"></i>Venta Rápida
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
          <a href="${pageContext.request.contextPath}/productos" class="btn btn-outline-accent w-100 py-3">
            <i class="bi bi-grid-3x3-gap-fill me-2"></i>Catálogo
          </a>
        </div>
      </div>
    </c:if>

    <!-- ================= CLIENTE: mis cotizaciones y compras ================= -->
    <c:if test="${esCliente}">
      <c:choose>
        <c:when test="${not empty misCotizaciones || not empty misCompras}">
          <div class="row g-3 mb-4">
            <div class="col-md-4">
              <div class="card card-bodegazo p-4 text-center">
                <div class="text-muted small">Total gastado</div>
                <div class="fs-4 fw-bold text-accent">$<fmt:formatNumber value="${totalGastado}" type="number" groupingUsed="true" maxFractionDigits="0"/></div>
              </div>
            </div>
          </div>

          <c:if test="${not empty misCotizaciones}">
            <h6 class="fw-bold mb-2">Mis cotizaciones recientes</h6>
            <div class="card card-bodegazo p-0 overflow-hidden mb-4">
              <table class="table table-hover align-middle mb-0">
                <tbody>
                  <c:forEach var="cot" items="${misCotizaciones}">
                    <tr>
                      <td>#<c:out value="${cot.id}"/></td>
                      <td><span class="badge bg-secondary"><c:out value="${cot.estado}"/></span></td>
                      <td class="text-end">$<fmt:formatNumber value="${cot.total}" type="number" groupingUsed="true" maxFractionDigits="0"/></td>
                      <td class="text-end">
                        <a href="${pageContext.request.contextPath}/cotizaciones/${cot.id}" class="btn btn-sm btn-outline-accent">Ver</a>
                      </td>
                    </tr>
                  </c:forEach>
                </tbody>
              </table>
            </div>
          </c:if>

          <c:if test="${not empty misCompras}">
            <h6 class="fw-bold mb-2">Mis compras recientes</h6>
            <div class="card card-bodegazo p-0 overflow-hidden mb-4">
              <table class="table table-hover align-middle mb-0">
                <tbody>
                  <c:forEach var="v" items="${misCompras}">
                    <tr>
                      <td>#<c:out value="${v.id}"/></td>
                      <td><c:out value="${v.metodoPago}"/></td>
                      <td class="text-end">$<fmt:formatNumber value="${v.total}" type="number" groupingUsed="true" maxFractionDigits="0"/></td>
                    </tr>
                  </c:forEach>
                </tbody>
              </table>
            </div>
          </c:if>
        </c:when>
        <c:otherwise>
          <div class="alert alert-light border">
            <i class="bi bi-info-circle text-accent me-2"></i>
            Todavía no tienes cotizaciones ni compras — cuando hagas tu primera cotización, la vas a ver aquí.
          </div>
        </c:otherwise>
      </c:choose>

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

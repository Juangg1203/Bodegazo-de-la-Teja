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

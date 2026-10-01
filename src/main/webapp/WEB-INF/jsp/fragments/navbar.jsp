<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<nav class="navbar navbar-expand-lg navbar-dark bodegazo-navbar sticky-top">
  <div class="container">
    <a class="navbar-brand fw-bold d-flex align-items-center" href="${pageContext.request.contextPath}/inicio">
      <span class="bg-white rounded px-2 py-1 d-inline-flex align-items-center">
        <img src="${pageContext.request.contextPath}/images/logo-bodegazo.png" alt="Bodegazo de la Teja" height="46">
      </span>
    </a>
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navMenu">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="navMenu">
      <ul class="navbar-nav mx-auto mb-2 mb-lg-0">
        <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/inicio">Inicio</a></li>
        <%-- El catálogo público (Productos) es para visitantes/clientes/operativos.
             El Administrador no vende ni cotiza desde aquí: sus funciones viven
             en el Dashboard, así que este menú no le sale por fuera. --%>
        <sec:authorize access="!hasRole('ADMINISTRADOR')">
          <li class="nav-item dropdown">
            <a class="nav-link dropdown-toggle" href="#" id="productosMenu" role="button" data-bs-toggle="dropdown">Productos</a>
            <ul class="dropdown-menu p-3" style="min-width: 420px;">
              <div class="row g-2">
                <div class="col-6">
                  <a class="d-block text-decoration-none p-2 rounded border h-100" href="${pageContext.request.contextPath}/tejas-upvc">
                    <span class="bg-white rounded px-2 py-1 d-inline-flex align-items-center mb-2 border">
                      <img src="${pageContext.request.contextPath}/images/logo-bodegazo.png" alt="Bodegazo de la Teja" height="36">
                    </span>
                    <div class="small text-dark fw-semibold"><i class="bi bi-grid-3x3-gap-fill me-1 text-accent"></i>Tejas UPVC</div>
                  </a>
                </div>
                <div class="col-6">
                  <a class="d-block text-decoration-none p-2 rounded border h-100" href="${pageContext.request.contextPath}/impermeabilizantes">
                    <span class="bg-white rounded px-2 py-1 d-inline-flex align-items-center mb-2 border">
                      <img src="${pageContext.request.contextPath}/images/logo-bodegon-manto.png" alt="El Bodegón del Manto" height="36">
                    </span>
                    <div class="small text-dark fw-semibold"><i class="bi bi-droplet-fill me-1 text-accent"></i>Impermeabilizantes</div>
                  </a>
                </div>
              </div>
            </ul>
          </li>
        </sec:authorize>
        <sec:authorize access="hasRole('EMPLEADO')">
          <li class="nav-item dropdown">
            <a class="nav-link dropdown-toggle" href="#" id="calcMenu" role="button" data-bs-toggle="dropdown">Calculadoras</a>
            <ul class="dropdown-menu">
              <li><a class="dropdown-item" href="${pageContext.request.contextPath}/calculadora-mantos">Calculadora de Mantos</a></li>
              <li><a class="dropdown-item" href="${pageContext.request.contextPath}/calculadora-tejas">Calculadora de Tejas</a></li>
            </ul>
          </li>
        </sec:authorize>
        <%-- Plan de Cortes, Inventario y Administrar Productos se movieron al
             Dashboard del Jefe de Bodega (apartado "Herramientas de Bodega"):
             son cosas que se consultan de vez en cuando, no en cada página, así
             que ya no van en la barra de arriba para no recargarla. --%>
        <%-- Carrito/Cotizaciones son de quien compra o cotiza (cliente/operativo),
             no del Administrador. --%>
        <sec:authorize access="isAuthenticated() and !hasRole('ADMINISTRADOR')">
          <li class="nav-item">
            <a class="nav-link" href="${pageContext.request.contextPath}/cotizaciones/carrito">
              <i class="bi bi-cart-fill me-1"></i>Carrito
            </a>
          </li>
          <li class="nav-item">
            <a class="nav-link" href="${pageContext.request.contextPath}/cotizaciones">
              <i class="bi bi-file-earmark-text-fill me-1"></i>Cotizaciones
            </a>
          </li>
        </sec:authorize>
        <%-- Venta Rápida/Ventas son operación de mostrador (Empleado/Jefe de
             Bodega). El Administrador no vende desde aquí. --%>
        <sec:authorize access="hasAnyRole('EMPLEADO','JEFE_BODEGA')">
          <li class="nav-item">
            <a class="nav-link" href="${pageContext.request.contextPath}/ventas/rapida">
              <i class="bi bi-lightning-charge-fill me-1"></i>Venta Rápida
            </a>
          </li>
          <li class="nav-item">
            <a class="nav-link" href="${pageContext.request.contextPath}/ventas">
              <i class="bi bi-receipt me-1"></i>Ventas
            </a>
          </li>
        </sec:authorize>
        <%-- Inventario/Administrar Productos: el Jefe de Bodega los sigue usando
             desde la barra porque son su trabajo diario. Para el Administrador
             estos mismos accesos viven en el Dashboard (ver más abajo), no aquí. --%>
        <%-- Inventario/Administrar Productos: junto con Plan de Cortes, ahora
             viven solo en el Dashboard del Jefe de Bodega ("Herramientas de
             Bodega"), no en esta barra — se consultan de vez en cuando, no en
             cada página. --%>
        <%-- Usuarios: función 100% administrativa. Solo vive como botón dentro
             del Dashboard del Administrador (ver dashboard.jsp), no en la barra. --%>
        <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/nosotros">Nosotros</a></li>
        <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/contacto">Contacto</a></li>
      </ul>
      <ul class="navbar-nav">
        <sec:authorize access="isAuthenticated()">
          <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/dashboard"><i class="bi bi-speedometer2 me-1"></i>Dashboard</a></li>
          <li class="nav-item">
            <form action="${pageContext.request.contextPath}/logout" method="post" class="d-inline">
              <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
              <button type="submit" class="btn btn-sm btn-accent ms-lg-2">Cerrar sesión</button>
            </form>
          </li>
        </sec:authorize>
        <sec:authorize access="!isAuthenticated()">
          <li class="nav-item"><a class="btn btn-sm btn-accent ms-lg-2" href="${pageContext.request.contextPath}/login">Iniciar sesión</a></li>
        </sec:authorize>
      </ul>
    </div>
  </div>
</nav>

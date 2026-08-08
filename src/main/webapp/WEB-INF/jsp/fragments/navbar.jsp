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
        <sec:authorize access="hasAnyRole('EMPLEADO','JEFE_BODEGA','ADMINISTRADOR')">
          <li class="nav-item dropdown">
            <a class="nav-link dropdown-toggle" href="#" id="calcMenu" role="button" data-bs-toggle="dropdown">Calculadoras</a>
            <ul class="dropdown-menu">
              <li><a class="dropdown-item" href="${pageContext.request.contextPath}/calculadora-mantos">Calculadora de Mantos</a></li>
              <li><a class="dropdown-item" href="${pageContext.request.contextPath}/calculadora-tejas">Calculadora de Tejas</a></li>
            </ul>
          </li>
        </sec:authorize>
        <sec:authorize access="isAuthenticated()">
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
        <sec:authorize access="hasAnyRole('EMPLEADO','JEFE_BODEGA','ADMINISTRADOR')">
          <li class="nav-item">
            <a class="nav-link" href="${pageContext.request.contextPath}/ventas">
              <i class="bi bi-receipt me-1"></i>Ventas
            </a>
          </li>
        </sec:authorize>
        <sec:authorize access="hasAnyRole('ADMINISTRADOR','JEFE_BODEGA')">
          <li class="nav-item">
            <a class="nav-link" href="${pageContext.request.contextPath}/inventario">
              <i class="bi bi-box-seam-fill me-1"></i>Inventario
            </a>
          </li>
          <li class="nav-item">
            <a class="nav-link" href="${pageContext.request.contextPath}/administracion/productos">
              <i class="bi bi-gear-fill me-1"></i>Administrar Productos
            </a>
          </li>
        </sec:authorize>
        <sec:authorize access="hasRole('ADMINISTRADOR')">
          <li class="nav-item">
            <a class="nav-link" href="${pageContext.request.contextPath}/usuarios">
              <i class="bi bi-people-fill me-1"></i>Usuarios
            </a>
          </li>
        </sec:authorize>
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

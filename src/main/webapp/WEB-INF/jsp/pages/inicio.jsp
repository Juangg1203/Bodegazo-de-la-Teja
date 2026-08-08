<%@ page contentType="text/html;charset=UTF-8" %>
<jsp:include page="/WEB-INF/jsp/fragments/head.jsp"/>
<body>
<jsp:include page="/WEB-INF/jsp/fragments/navbar.jsp"/>

<main>
  <!-- Hero -->
  <section class="hero-section">
    <div class="container text-center">
      <h1 class="display-4 mb-3">Impermeabilizaciones y Tejas UPVC de calidad</h1>
      <p class="lead mb-4">Todo lo que necesitas para tu cubierta, con asesoría técnica y cálculo exacto de material.</p>
      <a href="${pageContext.request.contextPath}/calculadora-tejas" class="btn btn-accent btn-lg me-2">
        <i class="bi bi-calculator-fill me-1"></i> Calcula tus tejas
      </a>
      <a href="${pageContext.request.contextPath}/calculadora-mantos" class="btn btn-outline-light btn-lg">
        <i class="bi bi-calculator me-1"></i> Calcula tus mantos
      </a>
    </div>
  </section>

  <!-- Categorías destacadas -->
  <section class="py-5">
    <div class="container">
      <h2 class="text-center fw-bold mb-5">Nuestras empresas y sus líneas de producto</h2>
      <div class="row g-4">
        <div class="col-md-6">
          <div class="card card-bodegazo h-100 p-4">
            <img src="${pageContext.request.contextPath}/images/logo-bodegon-manto.png" alt="El Bodegón del Manto" width="220" class="mb-3" style="height:auto;">
            <h4 class="fw-bold">Impermeabilizantes</h4>
            <p class="text-muted">Mantos con y sin foil de aluminio, autoadhesivos o no, en distintos grosores — traslapo garantizado para máxima duración.</p>
            <a href="${pageContext.request.contextPath}/impermeabilizantes" class="btn btn-outline-accent mt-auto align-self-start">Ver catálogo</a>
          </div>
        </div>
        <div class="col-md-6">
          <div class="card card-bodegazo h-100 p-4">
            <img src="${pageContext.request.contextPath}/images/logo-bodegazo.png" alt="Bodegazo de la Teja" width="220" class="mb-3" style="height:auto;">
            <h4 class="fw-bold">Tejas UPVC</h4>
            <p class="text-muted">Tejas plásticas resistentes, livianas y de larga duración, en presentación colonial y trapezoidal.</p>
            <a href="${pageContext.request.contextPath}/tejas-upvc" class="btn btn-outline-accent mt-auto align-self-start">Ver catálogo</a>
          </div>
        </div>
      </div>
    </div>
  </section>

  <!-- Por qué elegirnos -->
  <section class="py-5 bg-white">
    <div class="container">
      <h2 class="text-center fw-bold mb-5">¿Por qué elegir Bodegazo de la Teja?</h2>
      <div class="row g-4 text-center">
        <div class="col-md-4">
          <div class="icon-circle mx-auto mb-3"><i class="bi bi-patch-check-fill"></i></div>
          <h5 class="fw-bold">Calidad garantizada</h5>
          <p class="text-muted small">Productos certificados, listos para proyectos residenciales e industriales.</p>
        </div>
        <div class="col-md-4">
          <div class="icon-circle mx-auto mb-3"><i class="bi bi-calculator-fill"></i></div>
          <h5 class="fw-bold">Cálculo exacto</h5>
          <p class="text-muted small">Calculadoras de mantos y tejas que consideran traslapos reales, sin desperdicio.</p>
        </div>
        <div class="col-md-4">
          <div class="icon-circle mx-auto mb-3"><i class="bi bi-headset"></i></div>
          <h5 class="fw-bold">Asesoría experta</h5>
          <p class="text-muted small">Cotizaciones personalizadas y acompañamiento técnico en cada compra.</p>
        </div>
      </div>
    </div>
  </section>
</main>

<jsp:include page="/WEB-INF/jsp/fragments/footer.jsp"/>
<jsp:include page="/WEB-INF/jsp/fragments/scripts.jsp"/>

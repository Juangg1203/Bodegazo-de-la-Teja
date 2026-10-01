<%@ page contentType="text/html;charset=UTF-8" %>
<jsp:include page="/WEB-INF/jsp/fragments/head.jsp"/>
<body>
<jsp:include page="/WEB-INF/jsp/fragments/navbar.jsp"/>

<main>
  <section class="hero-section py-5">
    <div class="container text-center">
      <h1 class="mb-2">Sobre Bodegazo de la Teja</h1>
      <p class="lead mb-0">Impermeabilizaciones y tejas UPVC, con la experiencia que tu proyecto merece.</p>
    </div>
  </section>

  <section class="py-5">
    <div class="container">
      <div class="row g-5 align-items-center">
        <div class="col-md-6">
          <h2 class="fw-bold mb-3">Nuestra historia</h2>
          <p class="text-muted">
            Bodegazo de la Teja nació con un propósito claro: ofrecer materiales de
            impermeabilización y cubiertas de la más alta calidad, con precios justos
            y asesoría técnica real para quienes construyen y remodelan.
          </p>
          <p class="text-muted">
            Hoy trabajamos con proveedores certificados y un equipo que entiende de
            traslapos, resistencia y durabilidad — no solo de ventas.
          </p>
        </div>
        <div class="col-md-6">
          <div class="row g-3 text-center">
            <div class="col-6">
              <div class="card card-bodegazo p-4">
                <i class="bi bi-award-fill fs-1 text-accent mb-2"></i>
                <h5 class="fw-bold mb-0">Calidad certificada</h5>
              </div>
            </div>
            <div class="col-6">
              <div class="card card-bodegazo p-4">
                <i class="bi bi-truck fs-1 text-accent mb-2"></i>
                <h5 class="fw-bold mb-0">Entrega confiable</h5>
              </div>
            </div>
            <div class="col-6">
              <div class="card card-bodegazo p-4">
                <i class="bi bi-people-fill fs-1 text-accent mb-2"></i>
                <h5 class="fw-bold mb-0">Asesoría experta</h5>
              </div>
            </div>
            <div class="col-6">
              <div class="card card-bodegazo p-4">
                <i class="bi bi-graph-up-arrow fs-1 text-accent mb-2"></i>
                <h5 class="fw-bold mb-0">Precios justos</h5>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>

  <section class="py-5 bg-white">
    <div class="container">
      <div class="row g-5 align-items-center">
        <div class="col-md-5 order-md-1 text-center">
          <img src="${pageContext.request.contextPath}/images/nosotros/importacion.svg" alt="Importación desde China" class="img-fluid rounded" style="max-width: 340px;">
        </div>
        <div class="col-md-7 order-md-2">
          <h2 class="fw-bold mb-3">Importadores directos</h2>
          <p class="text-muted">
            Somos importadores directos de tejas UPVC — las traemos nosotros mismos desde
            China, sin intermediarios de por medio. Eso nos permite ofrecer precios más
            justos y controlar de primera mano la calidad de cada lote que llega a bodega.
          </p>
          <p class="text-muted mb-0">
            Llevamos <strong>14 años</strong> en el negocio de los impermeabilizantes,
            con experiencia real en asesoramiento personalizado — cada cliente recibe una
            recomendación pensada para su proyecto, no una venta genérica.
          </p>
        </div>
      </div>
    </div>
  </section>

  <section class="py-5">
    <div class="container">
      <div class="row g-5 align-items-center">
        <div class="col-md-4 text-center">
          <img src="${pageContext.request.contextPath}/images/nosotros/placeholder-persona.svg" alt="Fundador" class="img-fluid rounded-circle border" style="max-width: 220px;">
          <p class="text-muted small mt-2 mb-0">Foto pendiente por subir</p>
        </div>
        <div class="col-md-8">
          <h2 class="fw-bold mb-3">Detrás de Bodegazo de la Teja</h2>
          <p class="text-muted mb-0">
            Un negocio familiar hecho con la experiencia de 14 años en el sector — conocemos
            las cubiertas y los impermeabilizantes desde la práctica, no solo desde el
            mostrador, y eso es lo que nos permite asesorar de verdad a cada cliente.
          </p>
        </div>
      </div>
    </div>
  </section>
  <section class="py-5 bg-white">
    <div class="container text-center">
      <h2 class="fw-bold mb-4">Nuestra misión</h2>
      <p class="text-muted mx-auto" style="max-width: 700px;">
        Ser el proveedor de confianza en impermeabilizaciones y cubiertas UPVC,
        acompañando a nuestros clientes con productos duraderos y herramientas
        de cálculo precisas que evitan el desperdicio de material.
      </p>
    </div>
  </section>
</main>

<jsp:include page="/WEB-INF/jsp/fragments/footer.jsp"/>
<jsp:include page="/WEB-INF/jsp/fragments/scripts.jsp"/>

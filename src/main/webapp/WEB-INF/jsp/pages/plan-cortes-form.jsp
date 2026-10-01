<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/jsp/fragments/head.jsp"/>
<body>
<jsp:include page="/WEB-INF/jsp/fragments/navbar.jsp"/>

<main>
  <div class="container py-5">
    <div class="text-center mb-4">
      <h1 class="fw-bold"><i class="bi bi-scissors text-accent me-2"></i>Plan de Cortes</h1>
      <p class="text-muted">Para pedidos a la medida — ingresa las piezas que necesitas y calcula cuántas láminas comprar y qué corte va en cada una.</p>
    </div>

    <c:if test="${not empty error}">
      <div class="alert alert-danger" style="max-width: 700px; margin: 0 auto 1rem;"><c:out value="${error}"/></div>
    </c:if>

    <div class="card card-bodegazo p-4 mx-auto" style="max-width: 700px;">
      <form action="${pageContext.request.contextPath}/plan-cortes" method="post" id="formPlanCortes">
        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>

        <div class="mb-4">
          <label class="form-label fw-semibold">Lámina/teja base</label>
          <select class="form-select" name="laminaBase" required>
            <option value="5.90">5.90 m</option>
            <option value="11.80" selected>11.80 m</option>
          </select>
        </div>

        <label class="form-label fw-semibold">Piezas que necesitas</label>
        <div id="filasPiezas">
          <div class="row g-2 mb-2 fila-pieza">
            <div class="col-6">
              <input type="number" step="0.01" min="0.01" class="form-control" name="largos" placeholder="Medida (m)" required>
            </div>
            <div class="col-4">
              <input type="number" min="1" class="form-control" name="cantidades" placeholder="Cantidad" required>
            </div>
            <div class="col-2">
              <button type="button" class="btn btn-outline-secondary w-100 btn-quitar-fila" disabled><i class="bi bi-x-lg"></i></button>
            </div>
          </div>
        </div>

        <button type="button" id="btnAgregarFila" class="btn btn-outline-accent btn-sm mb-4">
          <i class="bi bi-plus-lg me-1"></i> Agregar otra medida
        </button>

        <button type="submit" class="btn btn-accent w-100">
          <i class="bi bi-calculator me-1"></i> Calcular plan de cortes
        </button>
      </form>
    </div>
  </div>
</main>

<jsp:include page="/WEB-INF/jsp/fragments/footer.jsp"/>
<jsp:include page="/WEB-INF/jsp/fragments/scripts.jsp"/>

<script>
  document.getElementById('btnAgregarFila').addEventListener('click', function () {
    const contenedor = document.getElementById('filasPiezas');
    const fila = contenedor.querySelector('.fila-pieza').cloneNode(true);
    fila.querySelectorAll('input').forEach(function (input) { input.value = ''; });
    fila.querySelector('.btn-quitar-fila').disabled = false;
    fila.querySelector('.btn-quitar-fila').addEventListener('click', function () { fila.remove(); });
    contenedor.appendChild(fila);
  });
</script>

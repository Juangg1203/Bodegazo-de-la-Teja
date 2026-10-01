<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/jsp/fragments/head.jsp"/>
<body>
<jsp:include page="/WEB-INF/jsp/fragments/navbar.jsp"/>

<main>
  <div class="container py-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
      <h1 class="fw-bold mb-0"><i class="bi bi-lightning-charge-fill text-accent me-2"></i>Venta Rápida</h1>
      <a href="${pageContext.request.contextPath}/ventas" class="btn btn-outline-accent">
        <i class="bi bi-arrow-left me-1"></i> Ver historial de ventas
      </a>
    </div>
    <p class="text-muted">Para vender en el mostrador — el precio de cada línea se puede ajustar a mano si hay rebaja. Al guardar, el inventario se descuenta solo.</p>

    <c:if test="${not empty error}">
      <div class="alert alert-danger"><i class="bi bi-exclamation-triangle-fill me-2"></i><c:out value="${error}"/></div>
    </c:if>

    <form action="${pageContext.request.contextPath}/ventas/rapida" method="post" id="formVentaRapida">
      <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>

      <div class="card card-bodegazo p-4 mb-3">
        <h6 class="fw-bold mb-3">Cliente</h6>
        <div class="btn-group mb-3" role="group">
          <input type="radio" class="btn-check" name="tipoCliente" id="tipoExistente" checked onclick="mostrarClienteExistente()">
          <label class="btn btn-outline-accent" for="tipoExistente">Cliente ya registrado</label>
          <input type="radio" class="btn-check" name="tipoCliente" id="tipoNuevo" onclick="mostrarClienteNuevo()">
          <label class="btn btn-outline-accent" for="tipoNuevo">Cliente nuevo (mostrador)</label>
        </div>

        <div id="bloqueClienteExistente">
          <select class="form-select" name="clienteId">
            <option value="">Selecciona...</option>
            <c:forEach var="cl" items="${clientes}">
              <option value="${cl.id}"><c:out value="${cl.nombre} ${cl.apellido} (${cl.numeroDocumento})"/></option>
            </c:forEach>
          </select>
        </div>

        <div id="bloqueClienteNuevo" class="row g-2" style="display:none;">
          <div class="col-md-3">
            <input type="text" class="form-control" name="clienteNuevoDocumento" placeholder="Documento">
          </div>
          <div class="col-md-3">
            <input type="text" class="form-control" name="clienteNuevoNombre" placeholder="Nombre">
          </div>
          <div class="col-md-3">
            <input type="text" class="form-control" name="clienteNuevoApellido" placeholder="Apellido">
          </div>
          <div class="col-md-3">
            <input type="text" class="form-control" name="clienteNuevoTelefono" placeholder="Teléfono">
          </div>
        </div>
      </div>

      <div class="card card-bodegazo p-4 mb-3">
        <h6 class="fw-bold mb-3">Método de pago</h6>
        <select class="form-select" name="metodoPago" required>
          <c:forEach var="m" items="${motivosPago}">
            <option value="${m}">${m}</option>
          </c:forEach>
        </select>
      </div>

      <div class="card card-bodegazo p-4 mb-3">
        <h6 class="fw-bold mb-3">Productos</h6>
        <div id="filasProductos"></div>
        <button type="button" class="btn btn-outline-accent btn-sm mt-2" onclick="agregarFilaProducto()">
          <i class="bi bi-plus-lg me-1"></i> Agregar producto
        </button>
      </div>

      <button type="submit" class="btn btn-accent w-100 py-3">
        <i class="bi bi-check-circle-fill me-1"></i> Registrar venta
      </button>
    </form>
  </div>
</main>

<jsp:include page="/WEB-INF/jsp/fragments/footer.jsp"/>
<jsp:include page="/WEB-INF/jsp/fragments/scripts.jsp"/>

<script>
  var productos = [
    <c:forEach var="p" items="${productos}" varStatus="s">
      { id: ${p.id}, nombre: "<c:out value='${p.nombre}'/> (<c:out value='${p.codigo}'/>)", precio: ${p.precioVenta} }<c:if test="${!s.last}">,</c:if>
    </c:forEach>
  ];
  var indiceFila = 0;

  function mostrarClienteExistente() {
    document.getElementById('bloqueClienteExistente').style.display = '';
    document.getElementById('bloqueClienteNuevo').style.display = 'none';
  }
  function mostrarClienteNuevo() {
    document.getElementById('bloqueClienteExistente').style.display = 'none';
    document.getElementById('bloqueClienteNuevo').style.display = '';
  }

  function agregarFilaProducto() {
    var i = indiceFila++;
    var contenedor = document.getElementById('filasProductos');
    var fila = document.createElement('div');
    fila.className = 'row g-2 mb-2 align-items-center';

    var opciones = '<option value="">Selecciona un producto...</option>';
    productos.forEach(function (p) {
      opciones += '<option value="' + p.id + '" data-precio="' + p.precio + '">' + p.nombre + '</option>';
    });

    fila.innerHTML =
      '<div class="col-md-5">' +
        '<select class="form-select" name="items[' + i + '].productoId" required onchange="precargarPrecio(this)">' + opciones + '</select>' +
      '</div>' +
      '<div class="col-md-2">' +
        '<input type="number" step="0.01" min="0.01" class="form-control" name="items[' + i + '].cantidad" placeholder="Cantidad" required>' +
      '</div>' +
      '<div class="col-md-3">' +
        '<div class="input-group"><span class="input-group-text">$</span>' +
        '<input type="number" step="0.01" min="0" class="form-control" name="items[' + i + '].precioUnitario" placeholder="Precio unitario" required></div>' +
      '</div>' +
      '<div class="col-md-2">' +
        '<button type="button" class="btn btn-outline-secondary w-100" onclick="this.closest(\'.row\').remove()"><i class="bi bi-x-lg"></i></button>' +
      '</div>';

    contenedor.appendChild(fila);
  }

  function precargarPrecio(select) {
    var opcion = select.options[select.selectedIndex];
    var precio = opcion.getAttribute('data-precio');
    var fila = select.closest('.row');
    if (precio) {
      fila.querySelector('input[name*="precioUnitario"]').value = precio;
    }
  }

  // Arranca con una fila lista
  agregarFilaProducto();
</script>

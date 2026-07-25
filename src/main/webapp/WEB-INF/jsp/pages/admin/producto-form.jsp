<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/jsp/fragments/head.jsp"/>
<body>
<jsp:include page="/WEB-INF/jsp/fragments/navbar.jsp"/>

<main>
  <div class="container py-5">
    <div class="d-flex justify-content-between align-items-center mb-2">
      <h1 class="fw-bold mb-0">
        <i class="bi bi-${not empty form.id ? 'pencil-fill' : 'plus-circle-fill'} text-accent me-2"></i>
        <c:out value="${pageTitle}"/>
      </h1>
      <a href="${pageContext.request.contextPath}/administracion/productos?empresa=${empresaActiva}" class="btn btn-outline-accent">
        <i class="bi bi-arrow-left me-1"></i> Volver al listado
      </a>
    </div>
    <span class="d-inline-flex align-items-center gap-2 mb-4">
      <span class="bg-white rounded px-1 py-1 d-inline-flex align-items-center border">
        <c:choose>
          <c:when test="${empresaActiva == 'MANTO'}">
            <img src="${pageContext.request.contextPath}/images/logo-bodegon-manto.png" alt="" height="20">
          </c:when>
          <c:otherwise>
            <img src="${pageContext.request.contextPath}/images/logo-bodegazo.png" alt="" height="20">
          </c:otherwise>
        </c:choose>
      </span>
      <span class="text-muted small">${empresaActiva == 'MANTO' ? 'El Bodegón del Manto' : 'Bodegazo de la Teja'}</span>
    </span>

    <c:if test="${not empty error}">
      <div class="alert alert-danger"><c:out value="${error}"/></div>
    </c:if>

    <form action="${pageContext.request.contextPath}/administracion/productos" method="post" enctype="multipart/form-data">
      <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
      <c:if test="${not empty form.id}">
        <input type="hidden" name="id" value="${form.id}">
      </c:if>

      <div class="row g-4">
        <!-- Columna izquierda: datos generales -->
        <div class="col-lg-8">
          <div class="card card-bodegazo p-4 mb-4">
            <h5 class="fw-bold mb-3">Datos generales</h5>
            <div class="row g-3">
              <div class="col-md-4">
                <label class="form-label fw-semibold">Código *</label>
                <input type="text" class="form-control" name="codigo" value="${form.codigo}" required maxlength="30">
              </div>
              <div class="col-md-8">
                <label class="form-label fw-semibold">Nombre *</label>
                <input type="text" class="form-control" name="nombre" value="${form.nombre}" required maxlength="150">
              </div>
              <div class="col-12">
                <label class="form-label fw-semibold">Descripción</label>
                <textarea class="form-control" name="descripcion" rows="4">${form.descripcion}</textarea>
              </div>
              <div class="col-md-4">
                <label class="form-label fw-semibold">Tipo de producto *</label>
                <select class="form-select" name="tipoProducto" required>
                  <option value="">Selecciona...</option>
                  <c:forEach var="tipo" items="${tiposProducto}">
                    <c:set var="preseleccionado" value="${(empty form.tipoProducto) && ((empresaActiva == 'MANTO' && tipo == 'IMPERMEABILIZANTE') || (empresaActiva == 'BODEGAZO' && tipo == 'TEJA_UPVC'))}"/>
                    <option value="${tipo}" ${(form.tipoProducto == tipo || preseleccionado) ? 'selected' : ''}>${tipo}</option>
                  </c:forEach>
                </select>
              </div>
              <div class="col-md-4">
                <label class="form-label fw-semibold">Categoría *</label>
                <select class="form-select" name="categoriaId" required>
                  <option value="">Selecciona...</option>
                  <c:forEach var="cat" items="${categorias}">
                    <option value="${cat.id}" ${form.categoriaId == cat.id ? 'selected' : ''}>${cat.nombre}</option>
                  </c:forEach>
                </select>
              </div>
              <div class="col-md-4">
                <label class="form-label fw-semibold">Unidad de medida</label>
                <input type="text" class="form-control" name="unidadMedida" value="${not empty form.unidadMedida ? form.unidadMedida : 'unidad'}" maxlength="20">
              </div>
              <div class="col-md-6">
                <label class="form-label fw-semibold">Marca</label>
                <select class="form-select" name="marcaId">
                  <option value="">Sin marca</option>
                  <c:forEach var="m" items="${marcas}">
                    <option value="${m.id}" ${form.marcaId == m.id ? 'selected' : ''}>${m.nombre}</option>
                  </c:forEach>
                </select>
              </div>
              <div class="col-md-6">
                <label class="form-label fw-semibold">Proveedor</label>
                <select class="form-select" name="proveedorId">
                  <option value="">Sin proveedor</option>
                  <c:forEach var="p" items="${proveedores}">
                    <option value="${p.id}" ${form.proveedorId == p.id ? 'selected' : ''}>${p.nombreEmpresa}</option>
                  </c:forEach>
                </select>
              </div>
            </div>
          </div>

          <div class="card card-bodegazo p-4 mb-4">
            <h5 class="fw-bold mb-3">Precio y medidas</h5>
            <div class="row g-3">
              <div class="col-md-6">
                <label class="form-label fw-semibold">Precio de venta *</label>
                <div class="input-group">
                  <span class="input-group-text">$</span>
                  <input type="number" step="0.01" min="0" class="form-control" name="precioVenta" value="${form.precioVenta}" required>
                </div>
              </div>
              <div class="col-md-6">
                <label class="form-label fw-semibold">Costo *</label>
                <div class="input-group">
                  <span class="input-group-text">$</span>
                  <input type="number" step="0.01" min="0" class="form-control" name="costo" value="${form.costo}" required>
                </div>
              </div>
              <div class="col-md-6">
                <label class="form-label fw-semibold">Largo (m)</label>
                <input type="number" step="0.01" min="0" class="form-control" name="largoM" value="${form.largoM}">
              </div>
              <div class="col-md-6">
                <label class="form-label fw-semibold">Ancho (m)</label>
                <input type="number" step="0.01" min="0" class="form-control" name="anchoM" value="${form.anchoM}">
              </div>
            </div>
          </div>

          <div class="card card-bodegazo p-4 mb-4">
            <h5 class="fw-bold mb-3">Características de manto</h5>
            <p class="text-muted small mb-3">Solo aplica a impermeabilizantes en rollo — déjalo en blanco para tejas u otros productos.</p>
            <div class="row g-3">
              <div class="col-md-4">
                <label class="form-label fw-semibold">Grosor (mm)</label>
                <input type="number" step="0.01" min="0" class="form-control" name="grosorMm" value="${form.grosorMm}">
              </div>
              <div class="col-md-4">
                <label class="form-label fw-semibold d-block">Foil de aluminio</label>
                <div class="btn-group" role="group">
                  <input type="radio" class="btn-check" name="tieneFoilAluminio" id="foilSi" value="true" ${form.tieneFoilAluminio == true ? 'checked' : ''}>
                  <label class="btn btn-outline-accent btn-sm" for="foilSi">Con foil</label>
                  <input type="radio" class="btn-check" name="tieneFoilAluminio" id="foilNo" value="false" ${form.tieneFoilAluminio == false ? 'checked' : (empty form.tieneFoilAluminio ? 'checked' : '')}>
                  <label class="btn btn-outline-accent btn-sm" for="foilNo">Sin foil</label>
                </div>
              </div>
              <div class="col-md-4">
                <label class="form-label fw-semibold d-block">Adhesivo</label>
                <div class="btn-group" role="group">
                  <input type="radio" class="btn-check" name="tieneAdhesivo" id="adhSi" value="true" ${form.tieneAdhesivo == true ? 'checked' : ''}>
                  <label class="btn btn-outline-accent btn-sm" for="adhSi">Con adhesivo</label>
                  <input type="radio" class="btn-check" name="tieneAdhesivo" id="adhNo" value="false" ${form.tieneAdhesivo == false ? 'checked' : (empty form.tieneAdhesivo ? 'checked' : '')}>
                  <label class="btn btn-outline-accent btn-sm" for="adhNo">Sin adhesivo</label>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Columna derecha: imagen e inventario -->
        <div class="col-lg-4">
          <div class="card card-bodegazo p-4 mb-4">
            <h5 class="fw-bold mb-3">Foto del producto</h5>
            <c:if test="${not empty form.imagenActual}">
              <img src="${form.imagenActual}" class="img-fluid rounded mb-3" alt="">
            </c:if>
            <input type="file" class="form-control" name="imagen" accept="image/*">
            <p class="text-muted small mt-2 mb-0">Formatos JPG o PNG, hasta 10 MB. Si no seleccionas una nueva, se conserva la actual.</p>
          </div>

          <div class="card card-bodegazo p-4">
            <h5 class="fw-bold mb-3">Inventario inicial</h5>
            <div class="mb-3">
              <label class="form-label fw-semibold">Stock actual</label>
              <input type="number" step="0.01" min="0" class="form-control" name="stockActual" value="${form.stockActual}">
            </div>
            <div class="mb-3">
              <label class="form-label fw-semibold">Stock mínimo</label>
              <input type="number" step="0.01" min="0" class="form-control" name="stockMinimo" value="${form.stockMinimo}">
            </div>
            <div class="mb-0">
              <label class="form-label fw-semibold">Ubicación en bodega</label>
              <input type="text" class="form-control" name="ubicacion" value="${form.ubicacion}" maxlength="100">
            </div>
          </div>
        </div>
      </div>

      <div class="d-flex justify-content-end gap-2 mt-4">
        <a href="${pageContext.request.contextPath}/administracion/productos?empresa=${empresaActiva}" class="btn btn-outline-secondary">Cancelar</a>
        <button type="submit" class="btn btn-accent px-4">
          <i class="bi bi-check-circle-fill me-1"></i> Guardar producto
        </button>
      </div>
    </form>
  </div>
</main>

<jsp:include page="/WEB-INF/jsp/fragments/footer.jsp"/>
<jsp:include page="/WEB-INF/jsp/fragments/scripts.jsp"/>

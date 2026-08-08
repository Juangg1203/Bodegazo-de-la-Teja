-- =====================================================================
-- BODEGAZO DE LA TEJA - SISTEMA EMPRESARIAL
-- Script de creación de base de datos - PostgreSQL 15+
-- =====================================================================
-- Convenciones:
--   * snake_case para todos los identificadores
--   * Claves primarias: id BIGSERIAL / BIGINT
--   * Timestamps: TIMESTAMP WITH TIME ZONE
--   * Borrado lógico donde aplica (columna activo)
-- =====================================================================

CREATE SCHEMA IF NOT EXISTS bodegazo;
SET search_path TO bodegazo, public;

-- =====================================================================
-- 1. ROLES
-- =====================================================================
CREATE TABLE roles (
    id              BIGSERIAL PRIMARY KEY,
    nombre          VARCHAR(30) NOT NULL UNIQUE,   -- CLIENTE, EMPLEADO, JEFE_BODEGA, ADMINISTRADOR
    descripcion     VARCHAR(150),
    fecha_creacion  TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE roles IS 'Roles del sistema: permisos independientes por rol';

-- =====================================================================
-- 2. USUARIOS
-- =====================================================================
CREATE TABLE usuarios (
    id                  BIGSERIAL PRIMARY KEY,
    nombre              VARCHAR(80) NOT NULL,
    apellido            VARCHAR(80) NOT NULL,
    correo              VARCHAR(150) NOT NULL UNIQUE,
    password            VARCHAR(255) NOT NULL,       -- BCrypt hash
    telefono            VARCHAR(20),
    activo              BOOLEAN NOT NULL DEFAULT TRUE,
    cuenta_no_expirada  BOOLEAN NOT NULL DEFAULT TRUE,
    cuenta_no_bloqueada BOOLEAN NOT NULL DEFAULT TRUE,
    credenciales_ok     BOOLEAN NOT NULL DEFAULT TRUE,
    ultimo_acceso       TIMESTAMPTZ,
    fecha_creacion      TIMESTAMPTZ NOT NULL DEFAULT now(),
    fecha_actualizacion TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_usuarios_correo ON usuarios(correo);

-- Relación N:M usuarios <-> roles
CREATE TABLE usuarios_roles (
    usuario_id  BIGINT NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    rol_id      BIGINT NOT NULL REFERENCES roles(id) ON DELETE RESTRICT,
    PRIMARY KEY (usuario_id, rol_id)
);

-- Tabla estándar de Spring Security para "recordar usuario" (persistent_logins)
CREATE TABLE usuarios_remember_me_tokens (
    series       VARCHAR(64) PRIMARY KEY,
    username     VARCHAR(150) NOT NULL,
    token        VARCHAR(64) NOT NULL,
    last_used    TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- =====================================================================
-- 3. CLIENTES
-- =====================================================================
CREATE TABLE clientes (
    id                  BIGSERIAL PRIMARY KEY,
    usuario_id          BIGINT UNIQUE REFERENCES usuarios(id) ON DELETE SET NULL,
    tipo_documento       VARCHAR(20) NOT NULL DEFAULT 'CC',
    numero_documento     VARCHAR(30) NOT NULL UNIQUE,
    nombre              VARCHAR(80) NOT NULL,
    apellido            VARCHAR(80) NOT NULL,
    razon_social        VARCHAR(150),               -- para clientes empresariales
    direccion           VARCHAR(200),
    ciudad              VARCHAR(80),
    telefono            VARCHAR(20),
    correo              VARCHAR(150),
    activo              BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_registro      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_clientes_documento ON clientes(numero_documento);

-- =====================================================================
-- 4. MARCAS
-- =====================================================================
CREATE TABLE marcas (
    id              BIGSERIAL PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL UNIQUE,
    descripcion     VARCHAR(255),
    logo_url        VARCHAR(255),
    activo          BOOLEAN NOT NULL DEFAULT TRUE
);

-- =====================================================================
-- 5. CATEGORIAS (auto-referenciada para subcategorías)
-- =====================================================================
CREATE TABLE categorias (
    id                  BIGSERIAL PRIMARY KEY,
    nombre              VARCHAR(100) NOT NULL,
    slug                VARCHAR(120) NOT NULL UNIQUE,
    descripcion         VARCHAR(255),
    categoria_padre_id  BIGINT REFERENCES categorias(id) ON DELETE SET NULL,
    icono               VARCHAR(80),
    activo              BOOLEAN NOT NULL DEFAULT TRUE
);

-- =====================================================================
-- 6. PROVEEDORES
-- =====================================================================
CREATE TABLE proveedores (
    id              BIGSERIAL PRIMARY KEY,
    nombre_empresa  VARCHAR(150) NOT NULL,
    nit             VARCHAR(30) UNIQUE,
    contacto        VARCHAR(100),
    telefono        VARCHAR(20),
    correo          VARCHAR(150),
    direccion       VARCHAR(200),
    activo          BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_registro  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- =====================================================================
-- 7. PRODUCTOS
-- =====================================================================
CREATE TABLE productos (
    id                  BIGSERIAL PRIMARY KEY,
    codigo              VARCHAR(30) NOT NULL UNIQUE,
    nombre              VARCHAR(150) NOT NULL,
    descripcion         TEXT,
    tipo_producto       VARCHAR(30) NOT NULL,        -- IMPERMEABILIZANTE, TEJA_UPVC, ACCESORIO
    categoria_id        BIGINT NOT NULL REFERENCES categorias(id) ON DELETE RESTRICT,
    marca_id            BIGINT REFERENCES marcas(id) ON DELETE SET NULL,
    proveedor_id        BIGINT REFERENCES proveedores(id) ON DELETE SET NULL,
    precio_venta        NUMERIC(12,2) NOT NULL CHECK (precio_venta >= 0),
    costo               NUMERIC(12,2) NOT NULL CHECK (costo >= 0),
    unidad_medida       VARCHAR(20) NOT NULL DEFAULT 'unidad',  -- unidad, m2, ml
    largo_m             NUMERIC(6,2),                 -- para cálculo de mantos/tejas
    ancho_m             NUMERIC(6,2),
    tiene_foil_aluminio BOOLEAN,                       -- solo aplica a mantos: con/sin foil de aluminio
    grosor_mm           NUMERIC(6,2),                  -- grosor en milímetros (mantos)
    tiene_adhesivo      BOOLEAN,                       -- solo aplica a mantos: con/sin adhesivo
    imagen_principal    VARCHAR(255),
    ficha_tecnica_pdf   VARCHAR(255),
    codigo_qr           VARCHAR(255),
    activo              BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_creacion      TIMESTAMPTZ NOT NULL DEFAULT now(),
    fecha_actualizacion TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT chk_tipo_producto CHECK (tipo_producto IN ('IMPERMEABILIZANTE','TEJA_UPVC','ACCESORIO'))
);

CREATE INDEX idx_productos_categoria ON productos(categoria_id);
CREATE INDEX idx_productos_marca ON productos(marca_id);
CREATE INDEX idx_productos_tipo ON productos(tipo_producto);

-- Galería de imágenes por producto
CREATE TABLE producto_imagenes (
    id              BIGSERIAL PRIMARY KEY,
    producto_id     BIGINT NOT NULL REFERENCES productos(id) ON DELETE CASCADE,
    url_imagen      VARCHAR(255) NOT NULL,
    orden           SMALLINT NOT NULL DEFAULT 0
);

CREATE INDEX idx_producto_imagenes_producto ON producto_imagenes(producto_id);

-- =====================================================================
-- 8. INVENTARIO (existencias vigentes, una fila por producto)
-- =====================================================================
CREATE TABLE inventario (
    id                  BIGSERIAL PRIMARY KEY,
    producto_id         BIGINT NOT NULL UNIQUE REFERENCES productos(id) ON DELETE CASCADE,
    stock_actual        NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (stock_actual >= 0),
    stock_minimo        NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (stock_minimo >= 0),
    ubicacion           VARCHAR(100),                 -- bodega / estante
    fecha_actualizacion TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- =====================================================================
-- 9. ENTRADAS DE INVENTARIO
-- =====================================================================
CREATE TABLE entradas (
    id              BIGSERIAL PRIMARY KEY,
    producto_id     BIGINT NOT NULL REFERENCES productos(id) ON DELETE RESTRICT,
    proveedor_id    BIGINT REFERENCES proveedores(id) ON DELETE SET NULL,
    usuario_id      BIGINT NOT NULL REFERENCES usuarios(id) ON DELETE RESTRICT,
    cantidad        NUMERIC(12,2) NOT NULL CHECK (cantidad > 0),
    costo_unitario  NUMERIC(12,2) NOT NULL CHECK (costo_unitario >= 0),
    numero_factura  VARCHAR(50),
    observaciones   VARCHAR(255),
    fecha           TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_entradas_producto ON entradas(producto_id);

-- =====================================================================
-- 10. SALIDAS DE INVENTARIO
-- =====================================================================
CREATE TABLE salidas (
    id              BIGSERIAL PRIMARY KEY,
    producto_id     BIGINT NOT NULL REFERENCES productos(id) ON DELETE RESTRICT,
    usuario_id      BIGINT NOT NULL REFERENCES usuarios(id) ON DELETE RESTRICT,
    cantidad        NUMERIC(12,2) NOT NULL CHECK (cantidad > 0),
    motivo          VARCHAR(30) NOT NULL DEFAULT 'VENTA',  -- VENTA, AJUSTE, DEVOLUCION, DAÑO
    observaciones   VARCHAR(255),
    fecha           TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_salidas_producto ON salidas(producto_id);

-- =====================================================================
-- 11. VENTAS
-- =====================================================================
CREATE TABLE ventas (
    id              BIGSERIAL PRIMARY KEY,
    cliente_id      BIGINT NOT NULL REFERENCES clientes(id) ON DELETE RESTRICT,
    usuario_id      BIGINT NOT NULL REFERENCES usuarios(id) ON DELETE RESTRICT, -- vendedor
    subtotal        NUMERIC(12,2) NOT NULL CHECK (subtotal >= 0),
    impuesto        NUMERIC(12,2) NOT NULL DEFAULT 0,
    total           NUMERIC(12,2) NOT NULL CHECK (total >= 0),
    metodo_pago     VARCHAR(30) NOT NULL DEFAULT 'EFECTIVO',
    estado          VARCHAR(20) NOT NULL DEFAULT 'COMPLETADA',  -- COMPLETADA, ANULADA, PENDIENTE
    fecha           TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT chk_ventas_estado CHECK (estado IN ('COMPLETADA','ANULADA','PENDIENTE'))
);

CREATE INDEX idx_ventas_cliente ON ventas(cliente_id);
CREATE INDEX idx_ventas_fecha ON ventas(fecha);

-- =====================================================================
-- 12. DETALLE VENTAS
-- =====================================================================
CREATE TABLE detalle_ventas (
    id              BIGSERIAL PRIMARY KEY,
    venta_id        BIGINT NOT NULL REFERENCES ventas(id) ON DELETE CASCADE,
    producto_id     BIGINT NOT NULL REFERENCES productos(id) ON DELETE RESTRICT,
    cantidad        NUMERIC(12,2) NOT NULL CHECK (cantidad > 0),
    precio_unitario NUMERIC(12,2) NOT NULL CHECK (precio_unitario >= 0),
    subtotal        NUMERIC(12,2) NOT NULL CHECK (subtotal >= 0)
);

CREATE INDEX idx_detalle_ventas_venta ON detalle_ventas(venta_id);

-- =====================================================================
-- 13. COTIZACIONES
-- =====================================================================
CREATE TABLE cotizaciones (
    id              BIGSERIAL PRIMARY KEY,
    cliente_id      BIGINT NOT NULL REFERENCES clientes(id) ON DELETE RESTRICT,
    usuario_id      BIGINT NOT NULL REFERENCES usuarios(id) ON DELETE RESTRICT,
    subtotal        NUMERIC(12,2) NOT NULL CHECK (subtotal >= 0),
    impuesto        NUMERIC(12,2) NOT NULL DEFAULT 0,
    total           NUMERIC(12,2) NOT NULL CHECK (total >= 0),
    estado          VARCHAR(20) NOT NULL DEFAULT 'PENDIENTE',  -- PENDIENTE, ACEPTADA, RECHAZADA, VENCIDA
    pdf_url         VARCHAR(255),
    fecha_emision   TIMESTAMPTZ NOT NULL DEFAULT now(),
    fecha_validez   DATE NOT NULL,
    CONSTRAINT chk_cotizaciones_estado CHECK (estado IN ('PENDIENTE','ACEPTADA','RECHAZADA','VENCIDA'))
);

CREATE INDEX idx_cotizaciones_cliente ON cotizaciones(cliente_id);

-- =====================================================================
-- 14. DETALLE COTIZACIONES
-- =====================================================================
CREATE TABLE detalle_cotizaciones (
    id              BIGSERIAL PRIMARY KEY,
    cotizacion_id   BIGINT NOT NULL REFERENCES cotizaciones(id) ON DELETE CASCADE,
    producto_id     BIGINT NOT NULL REFERENCES productos(id) ON DELETE RESTRICT,
    cantidad        NUMERIC(12,2) NOT NULL CHECK (cantidad > 0),
    precio_unitario NUMERIC(12,2) NOT NULL CHECK (precio_unitario >= 0),
    subtotal        NUMERIC(12,2) NOT NULL CHECK (subtotal >= 0)
);

CREATE INDEX idx_detalle_cotizaciones_cotizacion ON detalle_cotizaciones(cotizacion_id);

-- =====================================================================
-- 15. MOVIMIENTOS DE INVENTARIO (bitácora unificada)
-- =====================================================================
CREATE TABLE movimientos_inventario (
    id              BIGSERIAL PRIMARY KEY,
    producto_id     BIGINT NOT NULL REFERENCES productos(id) ON DELETE RESTRICT,
    tipo_movimiento VARCHAR(20) NOT NULL,        -- ENTRADA, SALIDA, AJUSTE, VENTA, DEVOLUCION
    cantidad        NUMERIC(12,2) NOT NULL,
    stock_anterior  NUMERIC(12,2) NOT NULL,
    stock_nuevo     NUMERIC(12,2) NOT NULL,
    referencia_tipo VARCHAR(30),                 -- ENTRADA, SALIDA, VENTA, COTIZACION
    referencia_id   BIGINT,
    usuario_id      BIGINT NOT NULL REFERENCES usuarios(id) ON DELETE RESTRICT,
    fecha           TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT chk_tipo_movimiento CHECK (tipo_movimiento IN ('ENTRADA','SALIDA','AJUSTE','VENTA','DEVOLUCION'))
);

CREATE INDEX idx_movimientos_producto ON movimientos_inventario(producto_id);
CREATE INDEX idx_movimientos_fecha ON movimientos_inventario(fecha);

-- =====================================================================
-- 16. AUDITORIA
-- =====================================================================
CREATE TABLE auditoria (
    id              BIGSERIAL PRIMARY KEY,
    usuario_id      BIGINT REFERENCES usuarios(id) ON DELETE SET NULL,
    accion          VARCHAR(50) NOT NULL,         -- CREAR, ACTUALIZAR, ELIMINAR, LOGIN, LOGOUT
    entidad         VARCHAR(50) NOT NULL,         -- nombre de la entidad afectada
    entidad_id      BIGINT,
    detalle         TEXT,
    ip_origen       VARCHAR(45),
    fecha           TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_auditoria_usuario ON auditoria(usuario_id);
CREATE INDEX idx_auditoria_fecha ON auditoria(fecha);

-- =====================================================================
-- 17. CONFIGURACIONES (parámetros globales del sistema, clave-valor)
-- =====================================================================
CREATE TABLE configuraciones (
    id                  BIGSERIAL PRIMARY KEY,
    clave               VARCHAR(80) NOT NULL UNIQUE,
    valor               VARCHAR(255) NOT NULL,
    descripcion         VARCHAR(255),
    fecha_actualizacion TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- =====================================================================
-- TRIGGERS: actualizar fecha_actualizacion automáticamente
-- =====================================================================
CREATE OR REPLACE FUNCTION fn_actualizar_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.fecha_actualizacion = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_usuarios_actualizado
    BEFORE UPDATE ON usuarios
    FOR EACH ROW EXECUTE FUNCTION fn_actualizar_timestamp();

CREATE TRIGGER trg_productos_actualizado
    BEFORE UPDATE ON productos
    FOR EACH ROW EXECUTE FUNCTION fn_actualizar_timestamp();

CREATE TRIGGER trg_inventario_actualizado
    BEFORE UPDATE ON inventario
    FOR EACH ROW EXECUTE FUNCTION fn_actualizar_timestamp();

CREATE TRIGGER trg_configuraciones_actualizado
    BEFORE UPDATE ON configuraciones
    FOR EACH ROW EXECUTE FUNCTION fn_actualizar_timestamp();

-- =====================================================================
-- DATOS INICIALES (SEED)
-- =====================================================================

INSERT INTO roles (nombre, descripcion) VALUES
    ('CLIENTE', 'Usuario final que consulta catálogo y solicita cotizaciones'),
    ('EMPLEADO', 'Personal de ventas y atención al cliente'),
    ('JEFE_BODEGA', 'Responsable del control de inventario, entradas y salidas'),
    ('ADMINISTRADOR', 'Control total del sistema');

-- Usuario administrador inicial.
-- El hash BCrypt corresponde a la contraseña temporal: "password"
-- IMPORTANTE: este usuario y contraseña son SOLO para el primer acceso.
-- Debe iniciar sesión y cambiar la contraseña de inmediato antes de pasar
-- el sistema a producción. Nunca dejar este hash en un entorno real.
INSERT INTO usuarios (nombre, apellido, correo, password, activo) VALUES
    ('Administrador', 'Sistema', 'admin@bodegazodelateja.com',
     '$2a$10$GRLdNijSQMUvl/au9ofL.eDwmoohzzS7.rmNSJZ.0FxO/BTk76klW', TRUE);

INSERT INTO usuarios_roles (usuario_id, rol_id)
    SELECT u.id, r.id FROM usuarios u, roles r
    WHERE u.correo = 'admin@bodegazodelateja.com' AND r.nombre = 'ADMINISTRADOR';

-- =====================================================================
-- CUENTAS DE PRUEBA (una por cada rol restante)
-- Mismo hash BCrypt de arriba -> contraseña temporal: "password"
-- IMPORTANTE: son solo para pruebas de desarrollo. Cambiar o eliminar
-- antes de pasar el sistema a producción.
-- =====================================================================
INSERT INTO usuarios (nombre, apellido, correo, password, activo) VALUES
    ('Empleado', 'Prueba', 'empleado@bodegazodelateja.com',
     '$2a$10$GRLdNijSQMUvl/au9ofL.eDwmoohzzS7.rmNSJZ.0FxO/BTk76klW', TRUE),
    ('Jefe', 'Bodega', 'jefebodega@bodegazodelateja.com',
     '$2a$10$GRLdNijSQMUvl/au9ofL.eDwmoohzzS7.rmNSJZ.0FxO/BTk76klW', TRUE),
    ('Cliente', 'Prueba', 'cliente@bodegazodelateja.com',
     '$2a$10$GRLdNijSQMUvl/au9ofL.eDwmoohzzS7.rmNSJZ.0FxO/BTk76klW', TRUE);

INSERT INTO usuarios_roles (usuario_id, rol_id)
    SELECT u.id, r.id FROM usuarios u, roles r
    WHERE u.correo = 'empleado@bodegazodelateja.com' AND r.nombre = 'EMPLEADO';

INSERT INTO usuarios_roles (usuario_id, rol_id)
    SELECT u.id, r.id FROM usuarios u, roles r
    WHERE u.correo = 'jefebodega@bodegazodelateja.com' AND r.nombre = 'JEFE_BODEGA';

INSERT INTO usuarios_roles (usuario_id, rol_id)
    SELECT u.id, r.id FROM usuarios u, roles r
    WHERE u.correo = 'cliente@bodegazodelateja.com' AND r.nombre = 'CLIENTE';

-- El cliente de prueba también queda registrado en "clientes", vinculado
-- a su usuario, para poder probar cotizaciones/ventas a su nombre.
INSERT INTO clientes (usuario_id, tipo_documento, numero_documento, nombre, apellido, correo)
    SELECT u.id, 'CC', '0000000000', 'Cliente', 'Prueba', 'cliente@bodegazodelateja.com'
    FROM usuarios u WHERE u.correo = 'cliente@bodegazodelateja.com';

INSERT INTO categorias (nombre, slug, descripcion, icono) VALUES
    ('Impermeabilizantes', 'impermeabilizantes', 'Mantos y productos de impermeabilización', 'bi-droplet-fill'),
    ('Tejas UPVC', 'tejas-upvc', 'Tejas plásticas UPVC para cubiertas', 'bi-house-fill'),
    ('Accesorios', 'accesorios', 'Accesorios de instalación y complementos', 'bi-tools');

INSERT INTO configuraciones (clave, valor, descripcion) VALUES
    ('EMPRESA_NOMBRE', 'Bodegazo de la Teja', 'Nombre comercial de la empresa'),
    ('EMPRESA_TELEFONO', '3177042437', 'Teléfono principal de contacto'),
    ('EMPRESA_WHATSAPP', '3176944377', 'Número de WhatsApp para atención al cliente'),
    ('EMPRESA_CORREO', 'elbodegondelmanto@hotmail.com', 'Correo de contacto'),
    ('EMPRESA_DIRECCION', 'CRA 17F #60-06, Ricaurte, Bucaramanga', 'Dirección física de la empresa'),
    ('IVA_PORCENTAJE', '19', 'Porcentaje de IVA aplicado a ventas y cotizaciones'),
    ('MANTO_TRASLAPO_M', '0.80', 'Traslapo obligatorio en metros para cálculo de mantos'),
    ('COTIZACION_VIGENCIA_DIAS', '15', 'Días de vigencia por defecto de una cotización'),
    ('MANTO_ANCHO_ROLLO_M', '1.00', 'Ancho estándar de un rollo de manto impermeabilizante'),
    ('MANTO_LARGO_ROLLO_M', '10.00', 'Largo estándar de un rollo de manto impermeabilizante'),
    ('MANTO_PRECIO_REFERENCIA', '85000', 'Precio de referencia por rollo de manto, usado en el costo estimado de la calculadora'),
    ('TEJA_COLONIAL_LARGO_MODULO_M', '5.90', 'Largo estándar de una teja UPVC Colonial'),
    ('TEJA_COLONIAL_ANCHO_MODULO_M', '1.05', 'Ancho estándar de una teja UPVC Colonial'),
    ('TEJA_COLONIAL_ANCHO_BARRIGA_CM', '22', 'Distancia entre barrigas (ondas) de la teja Colonial, en centimetros — los cortes deben caer en un borde de barriga'),
    ('TEJA_COLONIAL_TRASLAPO_LATERAL_CM', '10', 'Traslapo lateral en centímetros para teja Colonial'),
    ('TEJA_COLONIAL_TRASLAPO_LONGITUDINAL_CM', '22', 'Traslapo longitudinal en centímetros para teja Colonial'),
    ('TEJA_COLONIAL_PRECIO_REFERENCIA', '99000', 'Precio de referencia por teja Colonial'),
    ('TEJA_TRAPEZOIDAL_LARGO_MODULO_M', '5.90', 'Largo estándar de una teja UPVC Trapezoidal'),
    ('TEJA_TRAPEZOIDAL_ANCHO_MODULO_M', '1.10', 'Ancho estándar de una teja UPVC Trapezoidal'),
    ('TEJA_TRAPEZOIDAL_TRASLAPO_LATERAL_CM', '10', 'Traslapo lateral en centímetros para teja Trapezoidal'),
    ('TEJA_TRAPEZOIDAL_TRASLAPO_LONGITUDINAL_CM', '20', 'Traslapo longitudinal en centímetros para teja Trapezoidal'),
    ('TEJA_TRAPEZOIDAL_PRECIO_REFERENCIA', '99000', 'Precio de referencia por teja Trapezoidal');

-- =====================================================================
-- PRODUCTOS DE EJEMPLO (Tejas UPVC del catálogo de la empresa)
-- =====================================================================

INSERT INTO marcas (nombre, descripcion) VALUES
    ('Bodegazo UPVC', 'Línea propia de tejas y accesorios UPVC de Bodegazo de la Teja'),
    ('El Bodegón del Manto', 'Línea propia de mantos e impermeabilizantes de Bodegazo de la Teja');

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m)
SELECT
    v.codigo, v.nombre, v.descripcion, 'TEJA_UPVC', c.id, m.id, v.precio_venta, v.costo, 'unidad', v.largo_m, v.ancho_m
FROM (VALUES
    ('TUC-590', 'Teja Colonial Terracota 5.90m', 'Teja UPVC estilo colonial, color terracota, ideal para cubiertas residenciales.', 95000::numeric, 68000::numeric, 5.90::numeric, 1.05::numeric),
    ('TUC-1180', 'Teja Colonial Terracota 11.80m', 'Teja UPVC estilo colonial, color terracota, presentación extendida para grandes cubiertas.', 178000::numeric, 128000::numeric, 11.80::numeric, 1.05::numeric),
    ('TTA-590', 'Teja Trapezoidal Cresta Alta 5.90m', 'Teja UPVC trapezoidal de cresta alta, disponible en azul, verde, rojo y blanco.', 99000::numeric, 71000::numeric, 5.90::numeric, 1.10::numeric),
    ('TTA-1180', 'Teja Trapezoidal Cresta Alta 11.80m', 'Teja UPVC trapezoidal de cresta alta, presentación extendida, varios colores.', 185000::numeric, 133000::numeric, 11.80::numeric, 1.10::numeric),
    ('TCB-590', 'Teja Cresta Baja 5.90m', 'Teja UPVC de perfil bajo, liviana y resistente, para cubiertas modernas.', 92000::numeric, 66000::numeric, 5.90::numeric, 1.10::numeric),
    ('TCB-1180', 'Teja Cresta Baja 11.80m', 'Teja UPVC de perfil bajo, presentación extendida.', 172000::numeric, 124000::numeric, 11.80::numeric, 1.10::numeric)
) AS v(codigo, nombre, descripcion, precio_venta, costo, largo_m, ancho_m)
CROSS JOIN (SELECT id FROM categorias WHERE slug = 'tejas-upvc') c
CROSS JOIN (SELECT id FROM marcas WHERE nombre = 'Bodegazo UPVC') m;

-- Inventario inicial para cada producto de ejemplo
INSERT INTO inventario (producto_id, stock_actual, stock_minimo, ubicacion)
SELECT p.id, 50, 10, 'Bodega principal'
FROM productos p
WHERE p.codigo IN ('TUC-590','TUC-1180','TTA-590','TTA-1180','TCB-590','TCB-1180');


-- =====================================================================
-- PRODUCTOS ADICIONALES (impermeabilizantes, mantos, cintas, tejas, accesorios)
-- =====================================================================

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'EMU-FIB-14', 'Emulsion Fiberglass 1/4 galon', 'Emulsion asfaltica Fiberglass, presentacion de 1/4 de galon.', 'IMPERMEABILIZANTE', c.id, m.id, 28000, 20160, '1/4 galon', NULL, NULL, NULL, TRUE
FROM categorias c, marcas m WHERE c.slug = 'impermeabilizantes' AND m.nombre = 'El Bodegón del Manto';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'EMU-FIB-1G', 'Emulsion Fiberglass 1 galon', 'Emulsion asfaltica Fiberglass, presentacion de 1 galon.', 'IMPERMEABILIZANTE', c.id, m.id, 88000, 63360, 'galon', NULL, NULL, NULL, TRUE
FROM categorias c, marcas m WHERE c.slug = 'impermeabilizantes' AND m.nombre = 'El Bodegón del Manto';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'EMU-FIB-MC', 'Emulsion Fiberglass medio cuñete', 'Emulsion asfaltica Fiberglass, presentacion de medio cuñete.', 'IMPERMEABILIZANTE', c.id, m.id, 260000, 187200, 'medio cuñete', NULL, NULL, NULL, TRUE
FROM categorias c, marcas m WHERE c.slug = 'impermeabilizantes' AND m.nombre = 'El Bodegón del Manto';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'EMU-FIB-CU', 'Emulsion Fiberglass cuñete', 'Emulsion asfaltica Fiberglass, presentacion de cuñete completo.', 'IMPERMEABILIZANTE', c.id, m.id, 460000, 331200, 'cuñete', NULL, NULL, NULL, TRUE
FROM categorias c, marcas m WHERE c.slug = 'impermeabilizantes' AND m.nombre = 'El Bodegón del Manto';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'EMU-SIK-MG', 'Emulsion Sika medio galon', 'Emulsion asfaltica Sika, presentacion de medio galon.', 'IMPERMEABILIZANTE', c.id, m.id, 48000, 34560, 'medio galon', NULL, NULL, NULL, TRUE
FROM categorias c, marcas m WHERE c.slug = 'impermeabilizantes' AND m.nombre = 'El Bodegón del Manto';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'EMU-SIK-1G', 'Emulsion Sika 1 galon', 'Emulsion asfaltica Sika, presentacion de 1 galon.', 'IMPERMEABILIZANTE', c.id, m.id, 88000, 63360, 'galon', NULL, NULL, NULL, TRUE
FROM categorias c, marcas m WHERE c.slug = 'impermeabilizantes' AND m.nombre = 'El Bodegón del Manto';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'EMU-SIK-BA', 'Emulsion Sika balde', 'Emulsion asfaltica Sika, presentacion en balde.', 'IMPERMEABILIZANTE', c.id, m.id, 95000, 68400, 'balde', NULL, NULL, NULL, TRUE
FROM categorias c, marcas m WHERE c.slug = 'impermeabilizantes' AND m.nombre = 'El Bodegón del Manto';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'EMU-SIK-CU', 'Emulsion Sika cuñete', 'Emulsion asfaltica Sika, presentacion de cuñete completo.', 'IMPERMEABILIZANTE', c.id, m.id, 460000, 331200, 'cuñete', NULL, NULL, NULL, TRUE
FROM categorias c, marcas m WHERE c.slug = 'impermeabilizantes' AND m.nombre = 'El Bodegón del Manto';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'ALU-IPA-14', 'Alumol IPA 1/4 galon', 'Pintura reflectiva de aluminio Alumol IPA, presentacion de 1/4 de galon.', 'IMPERMEABILIZANTE', c.id, m.id, 28000, 20160, '1/4 galon', NULL, NULL, NULL, TRUE
FROM categorias c, marcas m WHERE c.slug = 'impermeabilizantes' AND m.nombre = 'El Bodegón del Manto';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'ALU-IPA-MG', 'Alumol IPA medio galon', 'Pintura reflectiva de aluminio Alumol IPA, presentacion de medio galon.', 'IMPERMEABILIZANTE', c.id, m.id, 48000, 34560, 'medio galon', NULL, NULL, NULL, TRUE
FROM categorias c, marcas m WHERE c.slug = 'impermeabilizantes' AND m.nombre = 'El Bodegón del Manto';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'ALU-IPA-1G', 'Alumol IPA galon', 'Pintura reflectiva de aluminio Alumol IPA, presentacion de 1 galon.', 'IMPERMEABILIZANTE', c.id, m.id, 88000, 63360, 'galon', NULL, NULL, NULL, TRUE
FROM categorias c, marcas m WHERE c.slug = 'impermeabilizantes' AND m.nombre = 'El Bodegón del Manto';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'ALU-IPA-MC', 'Alumol IPA medio cuñete', 'Pintura reflectiva de aluminio Alumol IPA, presentacion de medio cuñete.', 'IMPERMEABILIZANTE', c.id, m.id, 260000, 187200, 'medio cuñete', NULL, NULL, NULL, TRUE
FROM categorias c, marcas m WHERE c.slug = 'impermeabilizantes' AND m.nombre = 'El Bodegón del Manto';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'ALU-IPA-CU', 'Alumol IPA cuñete', 'Pintura reflectiva de aluminio Alumol IPA, presentacion de cuñete completo.', 'IMPERMEABILIZANTE', c.id, m.id, 460000, 331200, 'cuñete', NULL, NULL, NULL, TRUE
FROM categorias c, marcas m WHERE c.slug = 'impermeabilizantes' AND m.nombre = 'El Bodegón del Manto';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'ASF-LIQ-14', 'Asfalto Liquido 1/4 galon', 'Asfalto liquido impermeabilizante, presentacion de 1/4 de galon.', 'IMPERMEABILIZANTE', c.id, m.id, 28000, 20160, '1/4 galon', NULL, NULL, NULL, TRUE
FROM categorias c, marcas m WHERE c.slug = 'impermeabilizantes' AND m.nombre = 'El Bodegón del Manto';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'ASF-LIQ-1G', 'Asfalto Liquido 1 galon', 'Asfalto liquido impermeabilizante, presentacion de 1 galon.', 'IMPERMEABILIZANTE', c.id, m.id, 88000, 63360, 'galon', NULL, NULL, NULL, TRUE
FROM categorias c, marcas m WHERE c.slug = 'impermeabilizantes' AND m.nombre = 'El Bodegón del Manto';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'ASF-LIQ-MC', 'Asfalto Liquido medio cuñete', 'Asfalto liquido impermeabilizante, presentacion de medio cuñete.', 'IMPERMEABILIZANTE', c.id, m.id, 260000, 187200, 'medio cuñete', NULL, NULL, NULL, TRUE
FROM categorias c, marcas m WHERE c.slug = 'impermeabilizantes' AND m.nombre = 'El Bodegón del Manto';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'ASF-LIQ-CU', 'Asfalto Liquido cuñete', 'Asfalto liquido impermeabilizante, presentacion de cuñete completo.', 'IMPERMEABILIZANTE', c.id, m.id, 460000, 331200, 'cuñete', NULL, NULL, NULL, TRUE
FROM categorias c, marcas m WHERE c.slug = 'impermeabilizantes' AND m.nombre = 'El Bodegón del Manto';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'CEM-IPA-1G', 'Cemento Plastico IPA 1 galon', 'Cemento plastico impermeabilizante IPA, presentacion de 1 galon.', 'IMPERMEABILIZANTE', c.id, m.id, 88000, 63360, 'galon', NULL, NULL, NULL, TRUE
FROM categorias c, marcas m WHERE c.slug = 'impermeabilizantes' AND m.nombre = 'El Bodegón del Manto';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'CEM-IPA-CU', 'Cemento Plastico IPA cuñete', 'Cemento plastico impermeabilizante IPA, presentacion de cuñete completo.', 'IMPERMEABILIZANTE', c.id, m.id, 460000, 331200, 'cuñete', NULL, NULL, NULL, TRUE
FROM categorias c, marcas m WHERE c.slug = 'impermeabilizantes' AND m.nombre = 'El Bodegón del Manto';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'IMPAC7000-1G', 'IMPAC 7000 1 galon', 'Impermeabilizante IMPAC 7000, presentacion de 1 galon.', 'IMPERMEABILIZANTE', c.id, m.id, 88000, 63360, 'galon', NULL, NULL, NULL, TRUE
FROM categorias c, marcas m WHERE c.slug = 'impermeabilizantes' AND m.nombre = 'El Bodegón del Manto';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'IMPAC7000-CU', 'IMPAC 7000 cuñete', 'Impermeabilizante IMPAC 7000, presentacion de cuñete completo.', 'IMPERMEABILIZANTE', c.id, m.id, 460000, 331200, 'cuñete', NULL, NULL, NULL, TRUE
FROM categorias c, marcas m WHERE c.slug = 'impermeabilizantes' AND m.nombre = 'El Bodegón del Manto';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'SIKAF7-1G', 'Sikafill 7 Años 1 galon', 'Impermeabilizante Sikafill 7 Años, presentacion de 1 galon.', 'IMPERMEABILIZANTE', c.id, m.id, 88000, 63360, 'galon', NULL, NULL, NULL, TRUE
FROM categorias c, marcas m WHERE c.slug = 'impermeabilizantes' AND m.nombre = 'El Bodegón del Manto';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'SIKAF7-CU', 'Sikafill 7 Años cuñete', 'Impermeabilizante Sikafill 7 Años, presentacion de cuñete completo.', 'IMPERMEABILIZANTE', c.id, m.id, 460000, 331200, 'cuñete', NULL, NULL, NULL, TRUE
FROM categorias c, marcas m WHERE c.slug = 'impermeabilizantes' AND m.nombre = 'El Bodegón del Manto';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'SIKAF100-1G', 'Sikafill 100 Super Gris 1 galon', 'Impermeabilizante Sikafill 100 Super Gris, presentacion de 1 galon.', 'IMPERMEABILIZANTE', c.id, m.id, 88000, 63360, 'galon', NULL, NULL, NULL, TRUE
FROM categorias c, marcas m WHERE c.slug = 'impermeabilizantes' AND m.nombre = 'El Bodegón del Manto';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'SIKAF100-CU', 'Sikafill 100 Super Gris cuñete', 'Impermeabilizante Sikafill 100 Super Gris, presentacion de cuñete completo.', 'IMPERMEABILIZANTE', c.id, m.id, 460000, 331200, 'cuñete', NULL, NULL, NULL, TRUE
FROM categorias c, marcas m WHERE c.slug = 'impermeabilizantes' AND m.nombre = 'El Bodegón del Manto';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'IMPTX7-1G', 'Impertexas 7 Años Gris 1 galon', 'Impermeabilizante Impertexas 7 Años color gris, presentacion de 1 galon.', 'IMPERMEABILIZANTE', c.id, m.id, 88000, 63360, 'galon', NULL, NULL, NULL, TRUE
FROM categorias c, marcas m WHERE c.slug = 'impermeabilizantes' AND m.nombre = 'El Bodegón del Manto';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'IMPTX7-CU', 'Impertexas 7 Años Gris cuñete', 'Impermeabilizante Impertexas 7 Años color gris, presentacion de cuñete completo.', 'IMPERMEABILIZANTE', c.id, m.id, 460000, 331200, 'cuñete', NULL, NULL, NULL, TRUE
FROM categorias c, marcas m WHERE c.slug = 'impermeabilizantes' AND m.nombre = 'El Bodegón del Manto';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'MTX-2', 'Manto Metalex Fiberglass 2.0mm', 'Manto impermeabilizante Manto Metalex Fiberglass, 2.0 mm de grosor.', 'IMPERMEABILIZANTE', c.id, m.id, 96000, 69120, 'rollo', 10.0, 1.0, 2.0, TRUE
FROM categorias c, marcas m WHERE c.slug = 'impermeabilizantes' AND m.nombre = 'El Bodegón del Manto';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'MTX-25', 'Manto Metalex Fiberglass 2.5mm', 'Manto impermeabilizante Manto Metalex Fiberglass, 2.5 mm de grosor.', 'IMPERMEABILIZANTE', c.id, m.id, 100500, 72360, 'rollo', 10.0, 1.0, 2.5, TRUE
FROM categorias c, marcas m WHERE c.slug = 'impermeabilizantes' AND m.nombre = 'El Bodegón del Manto';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'MCOL-FIB-2', 'Manto Colombia Fiberglass 2.0mm', 'Manto impermeabilizante Manto Colombia Fiberglass, 2.0 mm de grosor.', 'IMPERMEABILIZANTE', c.id, m.id, 96000, 69120, 'rollo', 10.0, 1.0, 2.0, TRUE
FROM categorias c, marcas m WHERE c.slug = 'impermeabilizantes' AND m.nombre = 'El Bodegón del Manto';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'MCOL-FIB-25', 'Manto Colombia Fiberglass 2.5mm', 'Manto impermeabilizante Manto Colombia Fiberglass, 2.5 mm de grosor.', 'IMPERMEABILIZANTE', c.id, m.id, 100500, 72360, 'rollo', 10.0, 1.0, 2.5, TRUE
FROM categorias c, marcas m WHERE c.slug = 'impermeabilizantes' AND m.nombre = 'El Bodegón del Manto';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'MIPA-25', 'Manto IPA 2.5mm', 'Manto impermeabilizante Manto IPA, 2.5 mm de grosor.', 'IMPERMEABILIZANTE', c.id, m.id, 100500, 72360, 'rollo', 10.0, 1.0, 2.5, TRUE
FROM categorias c, marcas m WHERE c.slug = 'impermeabilizantes' AND m.nombre = 'El Bodegón del Manto';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'MIPA-27', 'Manto IPA 2.7mm', 'Manto impermeabilizante Manto IPA, 2.7 mm de grosor.', 'IMPERMEABILIZANTE', c.id, m.id, 102300, 73656, 'rollo', 10.0, 1.0, 2.7, TRUE
FROM categorias c, marcas m WHERE c.slug = 'impermeabilizantes' AND m.nombre = 'El Bodegón del Manto';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'MROOF3000', 'Manto Roofer 3000 2.5mm', 'Manto impermeabilizante Manto Roofer 3000, 2.5 mm de grosor.', 'IMPERMEABILIZANTE', c.id, m.id, 100500, 72360, 'rollo', 10.0, 1.0, 2.5, TRUE
FROM categorias c, marcas m WHERE c.slug = 'impermeabilizantes' AND m.nombre = 'El Bodegón del Manto';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'MROOF2500', 'Manto Roofer 2500 2.0mm', 'Manto impermeabilizante Manto Roofer 2500, 2.0 mm de grosor.', 'IMPERMEABILIZANTE', c.id, m.id, 96000, 69120, 'rollo', 10.0, 1.0, 2.0, TRUE
FROM categorias c, marcas m WHERE c.slug = 'impermeabilizantes' AND m.nombre = 'El Bodegón del Manto';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'MROOF3500', 'Manto Roofer 3500 3.0mm', 'Manto impermeabilizante Manto Roofer 3500, 3.0 mm de grosor.', 'IMPERMEABILIZANTE', c.id, m.id, 105000, 75600, 'rollo', 10.0, 1.0, 3.0, TRUE
FROM categorias c, marcas m WHERE c.slug = 'impermeabilizantes' AND m.nombre = 'El Bodegón del Manto';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'MEDIL-ATV100', 'Manto Edil ATV100 2.5mm', 'Manto impermeabilizante Manto Edil ATV100, 2.5 mm de grosor.', 'IMPERMEABILIZANTE', c.id, m.id, 100500, 72360, 'rollo', 10.0, 1.0, 2.5, TRUE
FROM categorias c, marcas m WHERE c.slug = 'impermeabilizantes' AND m.nombre = 'El Bodegón del Manto';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'MEDIL-ATV30', 'Manto Edil ATV30 3.0mm', 'Manto impermeabilizante Manto Edil ATV30, 3.0 mm de grosor.', 'IMPERMEABILIZANTE', c.id, m.id, 105000, 75600, 'rollo', 10.0, 1.0, 3.0, TRUE
FROM categorias c, marcas m WHERE c.slug = 'impermeabilizantes' AND m.nombre = 'El Bodegón del Manto';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'MADH-NEGRO', 'Manto Adhesivo Negro 2.0mm', 'Manto impermeabilizante Manto Adhesivo Negro, 2.0 mm de grosor.', 'IMPERMEABILIZANTE', c.id, m.id, 96000, 69120, 'rollo', 10.0, 1.0, 2.0, TRUE
FROM categorias c, marcas m WHERE c.slug = 'impermeabilizantes' AND m.nombre = 'El Bodegón del Manto';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'MFIB-XT500', 'Manto Fiberglass XT500 2.8mm', 'Manto impermeabilizante Manto Fiberglass XT500, 2.8 mm de grosor.', 'IMPERMEABILIZANTE', c.id, m.id, 103200, 74304, 'rollo', 10.0, 1.0, 2.8, TRUE
FROM categorias c, marcas m WHERE c.slug = 'impermeabilizantes' AND m.nombre = 'El Bodegón del Manto';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'MTEX-ALU-2', 'Manto Texsa Aluadhesivo 2mm', 'Manto Texsa aluminizado autoadhesivo, 2mm de grosor. Presentacion de 10 m2 (1.10 x 9.20 m).', 'IMPERMEABILIZANTE', c.id, m.id, 96000, 69120, 'rollo', 9.2, 1.1, 2.0, TRUE
FROM categorias c, marcas m WHERE c.slug = 'impermeabilizantes' AND m.nombre = 'El Bodegón del Manto';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'MTEX-ADH-NEGRO', 'Manto Adhesivo Texsa Negro 1.5mm', 'Manto Texsa autoadhesivo color negro, 1.5mm de grosor. Presentacion de 20 m2 (1.10 x 18 m).', 'IMPERMEABILIZANTE', c.id, m.id, 183000, 131760, 'rollo', 18.0, 1.1, 1.5, TRUE
FROM categorias c, marcas m WHERE c.slug = 'impermeabilizantes' AND m.nombre = 'El Bodegón del Manto';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'CINTA-TXS-10', 'Cinta Flanche Texsa 10cm', 'Cinta flanche autoadhesiva Texsa, 10 cm de ancho x 10 m de largo, 1.5 mm de grosor.', 'ACCESORIO', c.id, m.id, 25000, 18000, 'rollo', 10.0, 0.1, 1.5, TRUE
FROM categorias c, marcas m WHERE c.slug = 'accesorios' AND m.nombre = 'El Bodegón del Manto';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'CINTA-TXS-15', 'Cinta Flanche Texsa 15cm', 'Cinta flanche autoadhesiva Texsa, 15 cm de ancho x 10 m de largo, 1.5 mm de grosor.', 'ACCESORIO', c.id, m.id, 28500, 20520, 'rollo', 10.0, 0.15, 1.5, TRUE
FROM categorias c, marcas m WHERE c.slug = 'accesorios' AND m.nombre = 'El Bodegón del Manto';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'CINTA-TXS-20', 'Cinta Flanche Texsa 20cm', 'Cinta flanche autoadhesiva Texsa, 20 cm de ancho x 10 m de largo, 1.5 mm de grosor.', 'ACCESORIO', c.id, m.id, 32000, 23040, 'rollo', 10.0, 0.2, 1.5, TRUE
FROM categorias c, marcas m WHERE c.slug = 'accesorios' AND m.nombre = 'El Bodegón del Manto';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'CINTA-TXS-33', 'Cinta Flanche Texsa 33cm', 'Cinta flanche autoadhesiva Texsa, 33 cm de ancho x 10 m de largo, 1.5 mm de grosor.', 'ACCESORIO', c.id, m.id, 41100, 29592, 'rollo', 10.0, 0.33, 1.5, TRUE
FROM categorias c, marcas m WHERE c.slug = 'accesorios' AND m.nombre = 'El Bodegón del Manto';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'CINTA-EDIL-10', 'Cinta Flanche Edil 10cm', 'Cinta flanche autoadhesiva Edil, 10 cm de ancho x 10 m de largo, 2.0 mm de grosor.', 'ACCESORIO', c.id, m.id, 25000, 18000, 'rollo', 10.0, 0.1, 2.0, TRUE
FROM categorias c, marcas m WHERE c.slug = 'accesorios' AND m.nombre = 'El Bodegón del Manto';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'CINTA-EDIL-15', 'Cinta Flanche Edil 15cm', 'Cinta flanche autoadhesiva Edil, 15 cm de ancho x 10 m de largo, 2.0 mm de grosor.', 'ACCESORIO', c.id, m.id, 28500, 20520, 'rollo', 10.0, 0.15, 2.0, TRUE
FROM categorias c, marcas m WHERE c.slug = 'accesorios' AND m.nombre = 'El Bodegón del Manto';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'CINTA-EDIL-30', 'Cinta Flanche Edil 30cm', 'Cinta flanche autoadhesiva Edil, 30 cm de ancho x 10 m de largo, 2.0 mm de grosor.', 'ACCESORIO', c.id, m.id, 39000, 28080, 'rollo', 10.0, 0.3, 2.0, TRUE
FROM categorias c, marcas m WHERE c.slug = 'accesorios' AND m.nombre = 'El Bodegón del Manto';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'TCOL-590-TER', 'Teja Colonial Terracota 5.90m', 'Teja UPVC estilo colonial, color terracota, 5.90 x 1.05 m.', 'TEJA_UPVC', c.id, m.id, 95000, 68400, 'unidad', 5.9, 1.05, NULL, TRUE
FROM categorias c, marcas m WHERE c.slug = 'tejas-upvc' AND m.nombre = 'Bodegazo UPVC';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'TCOL-590-NAR', 'Teja Colonial Naranja 5.90m', 'Teja UPVC estilo colonial, color naranja, 5.90 x 1.05 m.', 'TEJA_UPVC', c.id, m.id, 95000, 68400, 'unidad', 5.9, 1.05, NULL, TRUE
FROM categorias c, marcas m WHERE c.slug = 'tejas-upvc' AND m.nombre = 'Bodegazo UPVC';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'TCOL-590-NEG', 'Teja Colonial Negra 5.90m', 'Teja UPVC estilo colonial, color negra, 5.90 x 1.05 m.', 'TEJA_UPVC', c.id, m.id, 95000, 68400, 'unidad', 5.9, 1.05, NULL, TRUE
FROM categorias c, marcas m WHERE c.slug = 'tejas-upvc' AND m.nombre = 'Bodegazo UPVC';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'TCOL-590-TRP', 'Teja Colonial Transparente 5.90m', 'Teja UPVC estilo colonial, color transparente, 5.90 x 1.05 m.', 'TEJA_UPVC', c.id, m.id, 95000, 68400, 'unidad', 5.9, 1.05, NULL, TRUE
FROM categorias c, marcas m WHERE c.slug = 'tejas-upvc' AND m.nombre = 'Bodegazo UPVC';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'TCOL-590-TRL', 'Teja Colonial Traslucida 5.90m', 'Teja UPVC estilo colonial, color traslucida, 5.90 x 1.05 m.', 'TEJA_UPVC', c.id, m.id, 95000, 68400, 'unidad', 5.9, 1.05, NULL, TRUE
FROM categorias c, marcas m WHERE c.slug = 'tejas-upvc' AND m.nombre = 'Bodegazo UPVC';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'TCOL-1180-NAR', 'Teja Colonial Naranja 11.80m', 'Teja UPVC estilo colonial, color naranja, 11.80 x 1.05 m.', 'TEJA_UPVC', c.id, m.id, 178000, 128160, 'unidad', 11.8, 1.05, NULL, TRUE
FROM categorias c, marcas m WHERE c.slug = 'tejas-upvc' AND m.nombre = 'Bodegazo UPVC';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'TCOL-1180-TER', 'Teja Colonial Terracota 11.80m', 'Teja UPVC estilo colonial, color terracota, 11.80 x 1.05 m.', 'TEJA_UPVC', c.id, m.id, 178000, 128160, 'unidad', 11.8, 1.05, NULL, TRUE
FROM categorias c, marcas m WHERE c.slug = 'tejas-upvc' AND m.nombre = 'Bodegazo UPVC';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'TTA-590-AZU', 'Teja Trapezoidal Cresta Alta Azul 5.9m', 'Teja UPVC trapezoidal cresta alta, color azul, 5.9 x 1.10 m, 2.5mm de grosor.', 'TEJA_UPVC', c.id, m.id, 95000, 68400, 'unidad', 5.9, 1.1, 2.5, TRUE
FROM categorias c, marcas m WHERE c.slug = 'tejas-upvc' AND m.nombre = 'Bodegazo UPVC';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'TTA-1180-AZU', 'Teja Trapezoidal Cresta Alta Azul 11.8m', 'Teja UPVC trapezoidal cresta alta, color azul, 11.8 x 1.10 m, 2.5mm de grosor.', 'TEJA_UPVC', c.id, m.id, 178000, 128160, 'unidad', 11.8, 1.1, 2.5, TRUE
FROM categorias c, marcas m WHERE c.slug = 'tejas-upvc' AND m.nombre = 'Bodegazo UPVC';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'TTA-590-ROJ', 'Teja Trapezoidal Cresta Alta Roja 5.9m', 'Teja UPVC trapezoidal cresta alta, color roja, 5.9 x 1.10 m, 2.5mm de grosor.', 'TEJA_UPVC', c.id, m.id, 95000, 68400, 'unidad', 5.9, 1.1, 2.5, TRUE
FROM categorias c, marcas m WHERE c.slug = 'tejas-upvc' AND m.nombre = 'Bodegazo UPVC';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'TTA-1180-ROJ', 'Teja Trapezoidal Cresta Alta Roja 11.8m', 'Teja UPVC trapezoidal cresta alta, color roja, 11.8 x 1.10 m, 2.5mm de grosor.', 'TEJA_UPVC', c.id, m.id, 178000, 128160, 'unidad', 11.8, 1.1, 2.5, TRUE
FROM categorias c, marcas m WHERE c.slug = 'tejas-upvc' AND m.nombre = 'Bodegazo UPVC';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'TTA-590-VER', 'Teja Trapezoidal Cresta Alta Verde 5.9m', 'Teja UPVC trapezoidal cresta alta, color verde, 5.9 x 1.10 m, 2.5mm de grosor.', 'TEJA_UPVC', c.id, m.id, 95000, 68400, 'unidad', 5.9, 1.1, 2.5, TRUE
FROM categorias c, marcas m WHERE c.slug = 'tejas-upvc' AND m.nombre = 'Bodegazo UPVC';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'TTA-1180-VER', 'Teja Trapezoidal Cresta Alta Verde 11.8m', 'Teja UPVC trapezoidal cresta alta, color verde, 11.8 x 1.10 m, 2.5mm de grosor.', 'TEJA_UPVC', c.id, m.id, 178000, 128160, 'unidad', 11.8, 1.1, 2.5, TRUE
FROM categorias c, marcas m WHERE c.slug = 'tejas-upvc' AND m.nombre = 'Bodegazo UPVC';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'TTA-590-BLA', 'Teja Trapezoidal Cresta Alta Blanca 5.9m', 'Teja UPVC trapezoidal cresta alta, color blanca, 5.9 x 1.10 m, 2.5mm de grosor.', 'TEJA_UPVC', c.id, m.id, 95000, 68400, 'unidad', 5.9, 1.1, 2.5, TRUE
FROM categorias c, marcas m WHERE c.slug = 'tejas-upvc' AND m.nombre = 'Bodegazo UPVC';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'TTA-1180-BLA', 'Teja Trapezoidal Cresta Alta Blanca 11.8m', 'Teja UPVC trapezoidal cresta alta, color blanca, 11.8 x 1.10 m, 2.5mm de grosor.', 'TEJA_UPVC', c.id, m.id, 178000, 128160, 'unidad', 11.8, 1.1, 2.5, TRUE
FROM categorias c, marcas m WHERE c.slug = 'tejas-upvc' AND m.nombre = 'Bodegazo UPVC';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'TTA-590-TRP-15', 'Teja Trapezoidal Cresta Alta Transparente 5.90m', 'Teja UPVC trapezoidal cresta alta, color transparente, 5.90 x 1.10 m, 1.5mm de grosor (ideal para iluminacion natural).', 'TEJA_UPVC', c.id, m.id, 95000, 68400, 'unidad', 5.9, 1.1, 1.5, TRUE
FROM categorias c, marcas m WHERE c.slug = 'tejas-upvc' AND m.nombre = 'Bodegazo UPVC';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'TTA-590-TRL-15', 'Teja Trapezoidal Cresta Alta Traslucida 5.90m', 'Teja UPVC trapezoidal cresta alta, color traslucida, 5.90 x 1.10 m, 1.5mm de grosor (ideal para iluminacion natural).', 'TEJA_UPVC', c.id, m.id, 95000, 68400, 'unidad', 5.9, 1.1, 1.5, TRUE
FROM categorias c, marcas m WHERE c.slug = 'tejas-upvc' AND m.nombre = 'Bodegazo UPVC';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'TCB-590-BLA', 'Teja Trapezoidal Cresta Baja Blanca 5.90m', 'Teja UPVC trapezoidal cresta baja, color blanco, 5.90 x 1.10 m.', 'TEJA_UPVC', c.id, m.id, 95000, 68400, 'unidad', 5.9, 1.1, NULL, TRUE
FROM categorias c, marcas m WHERE c.slug = 'tejas-upvc' AND m.nombre = 'Bodegazo UPVC';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'CAB-COL-NAR', 'Caballete Colonial Naranja', 'Caballete de remate para teja Colonial, color naranja.', 'ACCESORIO', c.id, m.id, 22000, 15840, 'unidad', NULL, NULL, NULL, TRUE
FROM categorias c, marcas m WHERE c.slug = 'accesorios' AND m.nombre = 'Bodegazo UPVC';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'CAB-COL-TER', 'Caballete Colonial Terracota', 'Caballete de remate para teja Colonial, color terracota.', 'ACCESORIO', c.id, m.id, 22000, 15840, 'unidad', NULL, NULL, NULL, TRUE
FROM categorias c, marcas m WHERE c.slug = 'accesorios' AND m.nombre = 'Bodegazo UPVC';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'CAB-TRA-BLA', 'Caballete Trapezoidal Blanco', 'Caballete de remate para teja Trapezoidal, color blanco.', 'ACCESORIO', c.id, m.id, 22000, 15840, 'unidad', NULL, NULL, NULL, TRUE
FROM categorias c, marcas m WHERE c.slug = 'accesorios' AND m.nombre = 'Bodegazo UPVC';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'CAB-TRA-AZU', 'Caballete Trapezoidal Azul', 'Caballete de remate para teja Trapezoidal, color azul.', 'ACCESORIO', c.id, m.id, 22000, 15840, 'unidad', NULL, NULL, NULL, TRUE
FROM categorias c, marcas m WHERE c.slug = 'accesorios' AND m.nombre = 'Bodegazo UPVC';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'LIM-COL-NAR', 'Limatesa Colonial Naranja', 'Limatesa para teja Colonial, color naranja.', 'ACCESORIO', c.id, m.id, 26000, 18720, 'unidad', NULL, NULL, NULL, TRUE
FROM categorias c, marcas m WHERE c.slug = 'accesorios' AND m.nombre = 'Bodegazo UPVC';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'LIM-COL-TER', 'Limatesa Colonial Terracota', 'Limatesa para teja Colonial, color terracota.', 'ACCESORIO', c.id, m.id, 26000, 18720, 'unidad', NULL, NULL, NULL, TRUE
FROM categorias c, marcas m WHERE c.slug = 'accesorios' AND m.nombre = 'Bodegazo UPVC';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'TOR-25', 'Tornillo 2.5 pulgadas', 'Tornillo autoperforante para fijacion de teja UPVC, 2.5 pulgadas de largo.', 'ACCESORIO', c.id, m.id, 900, 648, 'unidad', NULL, NULL, NULL, TRUE
FROM categorias c, marcas m WHERE c.slug = 'accesorios' AND m.nombre = 'Bodegazo UPVC';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'TOR-3', 'Tornillo 3 pulgadas', 'Tornillo autoperforante para fijacion de teja UPVC, 3 pulgadas de largo.', 'ACCESORIO', c.id, m.id, 1100, 792, 'unidad', NULL, NULL, NULL, TRUE
FROM categorias c, marcas m WHERE c.slug = 'accesorios' AND m.nombre = 'Bodegazo UPVC';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'CAP-CALTA-AZU', 'Capuchon Cresta Alta Azul', 'Capuchon de remate para teja de cresta alta, color azul.', 'ACCESORIO', c.id, m.id, 3500, 2520, 'unidad', NULL, NULL, NULL, TRUE
FROM categorias c, marcas m WHERE c.slug = 'accesorios' AND m.nombre = 'Bodegazo UPVC';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'CAP-CALTA-NAR', 'Capuchon Cresta Alta Naranja', 'Capuchon de remate para teja de cresta alta, color naranja.', 'ACCESORIO', c.id, m.id, 3500, 2520, 'unidad', NULL, NULL, NULL, TRUE
FROM categorias c, marcas m WHERE c.slug = 'accesorios' AND m.nombre = 'Bodegazo UPVC';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'CAP-CALTA-ROJ', 'Capuchon Cresta Alta Rojo', 'Capuchon de remate para teja de cresta alta, color rojo.', 'ACCESORIO', c.id, m.id, 3500, 2520, 'unidad', NULL, NULL, NULL, TRUE
FROM categorias c, marcas m WHERE c.slug = 'accesorios' AND m.nombre = 'Bodegazo UPVC';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'CAP-CALTA-BLA', 'Capuchon Cresta Alta Blanco', 'Capuchon de remate para teja de cresta alta, color blanco.', 'ACCESORIO', c.id, m.id, 3500, 2520, 'unidad', NULL, NULL, NULL, TRUE
FROM categorias c, marcas m WHERE c.slug = 'accesorios' AND m.nombre = 'Bodegazo UPVC';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'CAP-CALTA-TER', 'Capuchon Cresta Alta Terracota', 'Capuchon de remate para teja de cresta alta, color terracota.', 'ACCESORIO', c.id, m.id, 3500, 2520, 'unidad', NULL, NULL, NULL, TRUE
FROM categorias c, marcas m WHERE c.slug = 'accesorios' AND m.nombre = 'Bodegazo UPVC';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'CAP-CBAJA-BLA', 'Capuchon Cresta Baja Blanco', 'Capuchon de remate para teja de cresta baja, color blanco.', 'ACCESORIO', c.id, m.id, 3500, 2520, 'unidad', NULL, NULL, NULL, TRUE
FROM categorias c, marcas m WHERE c.slug = 'accesorios' AND m.nombre = 'Bodegazo UPVC';

INSERT INTO inventario (producto_id, stock_actual, stock_minimo, ubicacion)
SELECT p.id, 30, 5, 'Bodega principal'
FROM productos p
WHERE p.codigo IN ('EMU-FIB-14','EMU-FIB-1G','EMU-FIB-MC','EMU-FIB-CU','EMU-SIK-MG','EMU-SIK-1G','EMU-SIK-BA','EMU-SIK-CU','ALU-IPA-14','ALU-IPA-MG','ALU-IPA-1G','ALU-IPA-MC','ALU-IPA-CU','ASF-LIQ-14','ASF-LIQ-1G','ASF-LIQ-MC','ASF-LIQ-CU','CEM-IPA-1G','CEM-IPA-CU','IMPAC7000-1G','IMPAC7000-CU','SIKAF7-1G','SIKAF7-CU','SIKAF100-1G','SIKAF100-CU','IMPTX7-1G','IMPTX7-CU','MTX-2','MTX-25','MCOL-FIB-2','MCOL-FIB-25','MIPA-25','MIPA-27','MROOF3000','MROOF2500','MROOF3500','MEDIL-ATV100','MEDIL-ATV30','MADH-NEGRO','MFIB-XT500','MTEX-ALU-2','MTEX-ADH-NEGRO','CINTA-TXS-10','CINTA-TXS-15','CINTA-TXS-20','CINTA-TXS-33','CINTA-EDIL-10','CINTA-EDIL-15','CINTA-EDIL-30','TCOL-590-TER','TCOL-590-NAR','TCOL-590-NEG','TCOL-590-TRP','TCOL-590-TRL','TCOL-1180-NAR','TCOL-1180-TER','TTA-590-AZU','TTA-1180-AZU','TTA-590-ROJ','TTA-1180-ROJ','TTA-590-VER','TTA-1180-VER','TTA-590-BLA','TTA-1180-BLA','TTA-590-TRP-15','TTA-590-TRL-15','TCB-590-BLA','CAB-COL-NAR','CAB-COL-TER','CAB-TRA-BLA','CAB-TRA-AZU','LIM-COL-NAR','LIM-COL-TER','TOR-25','TOR-3','CAP-CALTA-AZU','CAP-CALTA-NAR','CAP-CALTA-ROJ','CAP-CALTA-BLA','CAP-CALTA-TER','CAP-CBAJA-BLA');


-- =====================================================================
-- PASO 2: Manto Gravillado, Sikaflex, marcas reales de fabricante
-- =====================================================================

-- 1) Marcas nuevas (fabricantes reales)
INSERT INTO marcas (nombre, descripcion, activo)
VALUES ('Sika', 'Linea de productos impermeabilizantes y sellantes Sika', TRUE)
ON CONFLICT (nombre) DO NOTHING;

INSERT INTO marcas (nombre, descripcion, activo)
VALUES ('Texsa', 'Linea de mantos y cintas impermeabilizantes Texsa', TRUE)
ON CONFLICT (nombre) DO NOTHING;

INSERT INTO marcas (nombre, descripcion, activo)
VALUES ('Edil', 'Linea de mantos impermeabilizantes Edil', TRUE)
ON CONFLICT (nombre) DO NOTHING;

INSERT INTO marcas (nombre, descripcion, activo)
VALUES ('Roofer', 'Linea de mantos impermeabilizantes Roofer', TRUE)
ON CONFLICT (nombre) DO NOTHING;

INSERT INTO marcas (nombre, descripcion, activo)
VALUES ('IPA', 'Linea de productos impermeabilizantes IPA', TRUE)
ON CONFLICT (nombre) DO NOTHING;

INSERT INTO marcas (nombre, descripcion, activo)
VALUES ('Fiberglass', 'Linea de emulsiones y mantos Fiberglass', TRUE)
ON CONFLICT (nombre) DO NOTHING;

INSERT INTO marcas (nombre, descripcion, activo)
VALUES ('Metalex', 'Linea de mantos impermeabilizantes Metalex', TRUE)
ON CONFLICT (nombre) DO NOTHING;

INSERT INTO marcas (nombre, descripcion, activo)
VALUES ('Impac', 'Linea de impermeabilizantes Impac', TRUE)
ON CONFLICT (nombre) DO NOTHING;

INSERT INTO marcas (nombre, descripcion, activo)
VALUES ('Impertexas', 'Linea de impermeabilizantes Impertexas', TRUE)
ON CONFLICT (nombre) DO NOTHING;

INSERT INTO marcas (nombre, descripcion, activo)
VALUES ('Manto Colombia', 'Linea de mantos impermeabilizantes Colombia', TRUE)
ON CONFLICT (nombre) DO NOTHING;

-- 2) Productos nuevos
INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'MGRAV-ROJ', 'Manto Gravillado Rojo 3mm', 'Manto impermeabilizante gravillado color rojo, 3mm de grosor, presentacion 1 x 10 m.', 'IMPERMEABILIZANTE', c.id, m.id, 105000.0, 75600, 'rollo', 10.0, 1.0, 3.0, TRUE
FROM categorias c, marcas m WHERE c.slug = 'impermeabilizantes' AND m.nombre = 'El Bodegón del Manto';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'MGRAV-VER', 'Manto Gravillado Verde 3mm', 'Manto impermeabilizante gravillado color verde, 3mm de grosor, presentacion 1 x 10 m.', 'IMPERMEABILIZANTE', c.id, m.id, 105000.0, 75600, 'rollo', 10.0, 1.0, 3.0, TRUE
FROM categorias c, marcas m WHERE c.slug = 'impermeabilizantes' AND m.nombre = 'El Bodegón del Manto';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'MGRAV-GRI', 'Manto Gravillado Gris 3mm', 'Manto impermeabilizante gravillado color gris, 3mm de grosor, presentacion 1 x 10 m.', 'IMPERMEABILIZANTE', c.id, m.id, 105000.0, 75600, 'rollo', 10.0, 1.0, 3.0, TRUE
FROM categorias c, marcas m WHERE c.slug = 'impermeabilizantes' AND m.nombre = 'El Bodegón del Manto';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'SIKAFLEX-1A-GRIS', 'Sikaflex 1A Universal Gris', 'Sellante adhesivo de poliuretano de un componente, color gris, para juntas y sellado de techos y superficies. Presentacion en tubo/cartucho.', 'IMPERMEABILIZANTE', c.id, m.id, 42000, 30240, 'tubo', NULL, NULL, NULL, TRUE
FROM categorias c, marcas m WHERE c.slug = 'impermeabilizantes' AND m.nombre = 'Sika';

INSERT INTO inventario (producto_id, stock_actual, stock_minimo, ubicacion)
SELECT p.id, 30, 5, 'Bodega principal'
FROM productos p
WHERE p.codigo IN ('MGRAV-ROJ','MGRAV-VER','MGRAV-GRI','SIKAFLEX-1A-GRIS');

-- 3) Reasignar marca real a productos existentes
UPDATE productos SET marca_id = (SELECT id FROM marcas WHERE nombre = 'Fiberglass')
WHERE codigo LIKE 'EMU-FIB-%';
UPDATE productos SET marca_id = (SELECT id FROM marcas WHERE nombre = 'Sika')
WHERE codigo LIKE 'EMU-SIK-%';
UPDATE productos SET marca_id = (SELECT id FROM marcas WHERE nombre = 'IPA')
WHERE codigo LIKE 'ALU-IPA-%';
UPDATE productos SET marca_id = (SELECT id FROM marcas WHERE nombre = 'IPA')
WHERE codigo LIKE 'CEM-IPA-%';
UPDATE productos SET marca_id = (SELECT id FROM marcas WHERE nombre = 'Impac')
WHERE codigo LIKE 'IMPAC7000%';
UPDATE productos SET marca_id = (SELECT id FROM marcas WHERE nombre = 'Sika')
WHERE codigo LIKE 'SIKAF7-%';
UPDATE productos SET marca_id = (SELECT id FROM marcas WHERE nombre = 'Sika')
WHERE codigo LIKE 'SIKAF100-%';
UPDATE productos SET marca_id = (SELECT id FROM marcas WHERE nombre = 'Impertexas')
WHERE codigo LIKE 'IMPTX7-%';
UPDATE productos SET marca_id = (SELECT id FROM marcas WHERE nombre = 'Metalex')
WHERE codigo LIKE 'MTX-%';
UPDATE productos SET marca_id = (SELECT id FROM marcas WHERE nombre = 'Manto Colombia')
WHERE codigo LIKE 'MCOL-FIB-%';
UPDATE productos SET marca_id = (SELECT id FROM marcas WHERE nombre = 'IPA')
WHERE codigo LIKE 'MIPA-%';
UPDATE productos SET marca_id = (SELECT id FROM marcas WHERE nombre = 'Roofer')
WHERE codigo LIKE 'MROOF%';
UPDATE productos SET marca_id = (SELECT id FROM marcas WHERE nombre = 'Edil')
WHERE codigo LIKE 'MEDIL-%';
UPDATE productos SET marca_id = (SELECT id FROM marcas WHERE nombre = 'Fiberglass')
WHERE codigo LIKE 'MFIB-XT500%';
UPDATE productos SET marca_id = (SELECT id FROM marcas WHERE nombre = 'Texsa')
WHERE codigo LIKE 'MTEX-%';
UPDATE productos SET marca_id = (SELECT id FROM marcas WHERE nombre = 'Texsa')
WHERE codigo LIKE 'CINTA-TXS-%';
UPDATE productos SET marca_id = (SELECT id FROM marcas WHERE nombre = 'Edil')
WHERE codigo LIKE 'CINTA-EDIL-%';

-- =====================================================================
-- FIN DEL SCRIPT
-- =====================================================================

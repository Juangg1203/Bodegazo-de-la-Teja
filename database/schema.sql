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
    ('EMPRESA_TELEFONO', '', 'Teléfono principal de contacto'),
    ('EMPRESA_WHATSAPP', '', 'Número de WhatsApp para atención al cliente'),
    ('IVA_PORCENTAJE', '19', 'Porcentaje de IVA aplicado a ventas y cotizaciones'),
    ('MANTO_TRASLAPO_M', '0.80', 'Traslapo obligatorio en metros para cálculo de mantos'),
    ('COTIZACION_VIGENCIA_DIAS', '15', 'Días de vigencia por defecto de una cotización'),
    ('MANTO_ANCHO_ROLLO_M', '1.00', 'Ancho estándar de un rollo de manto impermeabilizante'),
    ('MANTO_LARGO_ROLLO_M', '10.00', 'Largo estándar de un rollo de manto impermeabilizante'),
    ('MANTO_PRECIO_REFERENCIA', '85000', 'Precio de referencia por rollo de manto, usado en el costo estimado de la calculadora'),
    ('TEJA_COLONIAL_LARGO_MODULO_M', '5.90', 'Largo estándar de una teja UPVC Colonial'),
    ('TEJA_COLONIAL_ANCHO_MODULO_M', '1.10', 'Ancho estándar de una teja UPVC Colonial'),
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
-- FIN DEL SCRIPT
-- =====================================================================

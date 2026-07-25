-- =====================================================================
-- Datos de prueba SOLO para el perfil "h2" (base de datos en memoria).
-- Se ejecuta automáticamente al arrancar con -Dspring.profiles.active=h2
-- =====================================================================

INSERT INTO roles (nombre, descripcion) VALUES
    ('CLIENTE', 'Usuario final que consulta catalogo y solicita cotizaciones'),
    ('EMPLEADO', 'Personal de ventas y atencion al cliente'),
    ('JEFE_BODEGA', 'Responsable del control de inventario, entradas y salidas'),
    ('ADMINISTRADOR', 'Control total del sistema');

-- Usuario administrador de prueba.
-- Correo: admin@bodegazodelateja.com / Contraseña: password
INSERT INTO usuarios (nombre, apellido, correo, password, activo, cuenta_no_expirada, cuenta_no_bloqueada, credenciales_ok) VALUES
    ('Administrador', 'Sistema', 'admin@bodegazodelateja.com',
     '$2a$10$GRLdNijSQMUvl/au9ofL.eDwmoohzzS7.rmNSJZ.0FxO/BTk76klW', TRUE, TRUE, TRUE, TRUE);

INSERT INTO usuarios_roles (usuario_id, rol_id)
    SELECT u.id, r.id FROM usuarios u, roles r
    WHERE u.correo = 'admin@bodegazodelateja.com' AND r.nombre = 'ADMINISTRADOR';

INSERT INTO categorias (nombre, slug, descripcion, icono, activo) VALUES
    ('Impermeabilizantes', 'impermeabilizantes', 'Mantos y productos de impermeabilizacion', 'bi-droplet-fill', TRUE),
    ('Tejas UPVC', 'tejas-upvc', 'Tejas plasticas UPVC para cubiertas', 'bi-house-fill', TRUE),
    ('Accesorios', 'accesorios', 'Accesorios de instalacion y complementos', 'bi-tools', TRUE);

INSERT INTO marcas (nombre, descripcion, activo) VALUES
    ('Bodegazo UPVC', 'Linea propia de tejas y accesorios UPVC de Bodegazo de la Teja', TRUE);

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, activo)
SELECT 'TUC-590', 'Teja Colonial Terracota 5.90m', 'Teja UPVC estilo colonial, color terracota, ideal para cubiertas residenciales.', 'TEJA_UPVC', c.id, m.id, 95000, 68000, 'unidad', 5.90, 1.05, TRUE
FROM categorias c, marcas m WHERE c.slug = 'tejas-upvc' AND m.nombre = 'Bodegazo UPVC';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, activo)
SELECT 'TUC-1180', 'Teja Colonial Terracota 11.80m', 'Teja UPVC estilo colonial, color terracota, presentacion extendida.', 'TEJA_UPVC', c.id, m.id, 178000, 128000, 'unidad', 11.80, 1.05, TRUE
FROM categorias c, marcas m WHERE c.slug = 'tejas-upvc' AND m.nombre = 'Bodegazo UPVC';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, activo)
SELECT 'TTA-590', 'Teja Trapezoidal Cresta Alta 5.90m', 'Teja UPVC trapezoidal de cresta alta, disponible en azul, verde, rojo y blanco.', 'TEJA_UPVC', c.id, m.id, 99000, 71000, 'unidad', 5.90, 1.10, TRUE
FROM categorias c, marcas m WHERE c.slug = 'tejas-upvc' AND m.nombre = 'Bodegazo UPVC';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, activo)
SELECT 'TTA-1180', 'Teja Trapezoidal Cresta Alta 11.80m', 'Teja UPVC trapezoidal de cresta alta, presentacion extendida.', 'TEJA_UPVC', c.id, m.id, 185000, 133000, 'unidad', 11.80, 1.10, TRUE
FROM categorias c, marcas m WHERE c.slug = 'tejas-upvc' AND m.nombre = 'Bodegazo UPVC';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, activo)
SELECT 'TCB-590', 'Teja Cresta Baja 5.90m', 'Teja UPVC de perfil bajo, liviana y resistente.', 'TEJA_UPVC', c.id, m.id, 92000, 66000, 'unidad', 5.90, 1.10, TRUE
FROM categorias c, marcas m WHERE c.slug = 'tejas-upvc' AND m.nombre = 'Bodegazo UPVC';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, activo)
SELECT 'TCB-1180', 'Teja Cresta Baja 11.80m', 'Teja UPVC de perfil bajo, presentacion extendida.', 'TEJA_UPVC', c.id, m.id, 172000, 124000, 'unidad', 11.80, 1.10, TRUE
FROM categorias c, marcas m WHERE c.slug = 'tejas-upvc' AND m.nombre = 'Bodegazo UPVC';

INSERT INTO inventario (producto_id, stock_actual, stock_minimo, ubicacion)
SELECT p.id, 50, 10, 'Bodega principal'
FROM productos p
WHERE p.codigo IN ('TUC-590','TUC-1180','TTA-590','TTA-1180','TCB-590','TCB-1180');

INSERT INTO configuraciones (clave, valor, descripcion) VALUES
    ('EMPRESA_NOMBRE', 'Bodegazo de la Teja', 'Nombre comercial de la empresa'),
    ('IVA_PORCENTAJE', '19', 'Porcentaje de IVA aplicado a ventas y cotizaciones'),
    ('MANTO_TRASLAPO_M', '0.80', 'Traslapo obligatorio en metros para calculo de mantos'),
    ('MANTO_ANCHO_ROLLO_M', '1.00', 'Ancho estandar de un rollo de manto impermeabilizante'),
    ('MANTO_LARGO_ROLLO_M', '10.00', 'Largo estandar de un rollo de manto impermeabilizante'),
    ('MANTO_PRECIO_REFERENCIA', '85000', 'Precio de referencia por rollo de manto'),
    ('TEJA_COLONIAL_LARGO_MODULO_M', '5.90', 'Largo estandar de una teja UPVC Colonial'),
    ('TEJA_COLONIAL_ANCHO_MODULO_M', '1.10', 'Ancho estandar de una teja UPVC Colonial'),
    ('TEJA_COLONIAL_TRASLAPO_LATERAL_CM', '10', 'Traslapo lateral en centimetros para teja Colonial'),
    ('TEJA_COLONIAL_TRASLAPO_LONGITUDINAL_CM', '22', 'Traslapo longitudinal en centimetros para teja Colonial'),
    ('TEJA_COLONIAL_PRECIO_REFERENCIA', '99000', 'Precio de referencia por teja Colonial'),
    ('TEJA_TRAPEZOIDAL_LARGO_MODULO_M', '5.90', 'Largo estandar de una teja UPVC Trapezoidal'),
    ('TEJA_TRAPEZOIDAL_ANCHO_MODULO_M', '1.10', 'Ancho estandar de una teja UPVC Trapezoidal'),
    ('TEJA_TRAPEZOIDAL_TRASLAPO_LATERAL_CM', '10', 'Traslapo lateral en centimetros para teja Trapezoidal'),
    ('TEJA_TRAPEZOIDAL_TRASLAPO_LONGITUDINAL_CM', '20', 'Traslapo longitudinal en centimetros para teja Trapezoidal'),
    ('TEJA_TRAPEZOIDAL_PRECIO_REFERENCIA', '99000', 'Precio de referencia por teja Trapezoidal'),
    ('COTIZACION_VIGENCIA_DIAS', '15', 'Dias de vigencia por defecto de una cotizacion');

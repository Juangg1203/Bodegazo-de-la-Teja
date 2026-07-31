-- =====================================================================
-- Datos de prueba para el perfil "render" (H2 en memoria).
-- Se ejecuta automaticamente al arrancar con SPRING_PROFILES_ACTIVE=render
-- =====================================================================

INSERT INTO roles (nombre, descripcion) VALUES
    ('CLIENTE', 'Usuario final que consulta catalogo y solicita cotizaciones'),
    ('EMPLEADO', 'Personal de ventas y atencion al cliente'),
    ('JEFE_BODEGA', 'Responsable del control de inventario, entradas y salidas'),
    ('ADMINISTRADOR', 'Control total del sistema');

-- Contraseña para las 4 cuentas: "password"
INSERT INTO usuarios (nombre, apellido, correo, password, activo, cuenta_no_expirada, cuenta_no_bloqueada, credenciales_ok) VALUES
    ('Administrador', 'Sistema', 'admin@bodegazodelateja.com',
     '$2a$10$GRLdNijSQMUvl/au9ofL.eDwmoohzzS7.rmNSJZ.0FxO/BTk76klW', TRUE, TRUE, TRUE, TRUE),
    ('Empleado', 'Prueba', 'empleado@bodegazodelateja.com',
     '$2a$10$GRLdNijSQMUvl/au9ofL.eDwmoohzzS7.rmNSJZ.0FxO/BTk76klW', TRUE, TRUE, TRUE, TRUE),
    ('Jefe', 'Bodega', 'jefebodega@bodegazodelateja.com',
     '$2a$10$GRLdNijSQMUvl/au9ofL.eDwmoohzzS7.rmNSJZ.0FxO/BTk76klW', TRUE, TRUE, TRUE, TRUE),
    ('Cliente', 'Prueba', 'cliente@bodegazodelateja.com',
     '$2a$10$GRLdNijSQMUvl/au9ofL.eDwmoohzzS7.rmNSJZ.0FxO/BTk76klW', TRUE, TRUE, TRUE, TRUE);

INSERT INTO usuarios_roles (usuario_id, rol_id)
    SELECT u.id, r.id FROM usuarios u, roles r WHERE u.correo = 'admin@bodegazodelateja.com' AND r.nombre = 'ADMINISTRADOR';
INSERT INTO usuarios_roles (usuario_id, rol_id)
    SELECT u.id, r.id FROM usuarios u, roles r WHERE u.correo = 'empleado@bodegazodelateja.com' AND r.nombre = 'EMPLEADO';
INSERT INTO usuarios_roles (usuario_id, rol_id)
    SELECT u.id, r.id FROM usuarios u, roles r WHERE u.correo = 'jefebodega@bodegazodelateja.com' AND r.nombre = 'JEFE_BODEGA';
INSERT INTO usuarios_roles (usuario_id, rol_id)
    SELECT u.id, r.id FROM usuarios u, roles r WHERE u.correo = 'cliente@bodegazodelateja.com' AND r.nombre = 'CLIENTE';

INSERT INTO clientes (usuario_id, tipo_documento, numero_documento, nombre, apellido, correo)
    SELECT u.id, 'CC', '0000000000', 'Cliente', 'Prueba', 'cliente@bodegazodelateja.com'
    FROM usuarios u WHERE u.correo = 'cliente@bodegazodelateja.com';

INSERT INTO categorias (nombre, slug, descripcion, icono, activo) VALUES
    ('Impermeabilizantes', 'impermeabilizantes', 'Mantos y productos de impermeabilizacion', 'bi-droplet-fill', TRUE),
    ('Tejas UPVC', 'tejas-upvc', 'Tejas plasticas UPVC para cubiertas', 'bi-house-fill', TRUE),
    ('Accesorios', 'accesorios', 'Accesorios de instalacion y complementos', 'bi-tools', TRUE);

INSERT INTO marcas (nombre, descripcion, activo) VALUES
    ('Bodegazo UPVC', 'Linea propia de tejas y accesorios UPVC de Bodegazo de la Teja', TRUE),
    ('El Bodegon del Manto', 'Linea propia de mantos e impermeabilizantes de Bodegazo de la Teja', TRUE);

INSERT INTO configuraciones (clave, valor, descripcion) VALUES
    ('EMPRESA_NOMBRE', 'Bodegazo de la Teja', 'Nombre comercial de la empresa'),
    ('IVA_PORCENTAJE', '19', 'Porcentaje de IVA aplicado a ventas y cotizaciones'),
    ('MANTO_TRASLAPO_M', '0.80', 'Traslapo obligatorio en metros para calculo de mantos'),
    ('MANTO_ANCHO_ROLLO_M', '1.00', 'Ancho estandar de un rollo de manto impermeabilizante'),
    ('MANTO_LARGO_ROLLO_M', '10.00', 'Largo estandar de un rollo de manto impermeabilizante'),
    ('MANTO_PRECIO_REFERENCIA', '85000', 'Precio de referencia por rollo de manto'),
    ('TEJA_COLONIAL_LARGO_MODULO_M', '5.90', 'Largo estandar de una teja UPVC Colonial'),
    ('TEJA_COLONIAL_ANCHO_MODULO_M', '1.05', 'Ancho estandar de una teja UPVC Colonial'),
    ('TEJA_COLONIAL_TRASLAPO_LATERAL_CM', '10', 'Traslapo lateral en centimetros para teja Colonial'),
    ('TEJA_COLONIAL_TRASLAPO_LONGITUDINAL_CM', '22', 'Traslapo longitudinal en centimetros para teja Colonial'),
    ('TEJA_COLONIAL_PRECIO_REFERENCIA', '99000', 'Precio de referencia por teja Colonial'),
    ('TEJA_TRAPEZOIDAL_LARGO_MODULO_M', '5.90', 'Largo estandar de una teja UPVC Trapezoidal'),
    ('TEJA_TRAPEZOIDAL_ANCHO_MODULO_M', '1.10', 'Ancho estandar de una teja UPVC Trapezoidal'),
    ('TEJA_TRAPEZOIDAL_TRASLAPO_LATERAL_CM', '10', 'Traslapo lateral en centimetros para teja Trapezoidal'),
    ('TEJA_TRAPEZOIDAL_TRASLAPO_LONGITUDINAL_CM', '20', 'Traslapo longitudinal en centimetros para teja Trapezoidal'),
    ('TEJA_TRAPEZOIDAL_PRECIO_REFERENCIA', '99000', 'Precio de referencia por teja Trapezoidal'),
    ('COTIZACION_VIGENCIA_DIAS', '15', 'Dias de vigencia por defecto de una cotizacion');

-- =====================================================================
-- PRODUCTOS: Tejas UPVC (marca Bodegazo UPVC)
-- =====================================================================

-- Colonial Terracota (11.80 y 5.90 x 1.05 m)
INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, activo)
SELECT 'TUC-590', 'Teja Colonial Terracota 5.90m', 'Teja UPVC estilo colonial, color terracota, ideal para cubiertas residenciales.', 'TEJA_UPVC', c.id, m.id, 95000, 68000, 'unidad', 5.90, 1.05, TRUE
FROM categorias c, marcas m WHERE c.slug = 'tejas-upvc' AND m.nombre = 'Bodegazo UPVC';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, activo)
SELECT 'TUC-1180', 'Teja Colonial Terracota 11.80m', 'Teja UPVC estilo colonial, color terracota, presentacion extendida.', 'TEJA_UPVC', c.id, m.id, 178000, 128000, 'unidad', 11.80, 1.05, TRUE
FROM categorias c, marcas m WHERE c.slug = 'tejas-upvc' AND m.nombre = 'Bodegazo UPVC';

-- Trapezoidal 2.5mm, 4 colores x 2 tamaños (11.80 o 5.90 x 1.10 m)
INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'TTB-590', 'Teja Trapezoidal Blanca 5.90m 2.5mm', 'Teja UPVC trapezoidal color blanco, 2.5mm de grosor.', 'TEJA_UPVC', c.id, m.id, 99000, 71000, 'unidad', 5.90, 1.10, 2.5, TRUE
FROM categorias c, marcas m WHERE c.slug = 'tejas-upvc' AND m.nombre = 'Bodegazo UPVC';
INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'TTB-1180', 'Teja Trapezoidal Blanca 11.80m 2.5mm', 'Teja UPVC trapezoidal color blanco, presentacion extendida, 2.5mm de grosor.', 'TEJA_UPVC', c.id, m.id, 185000, 133000, 'unidad', 11.80, 1.10, 2.5, TRUE
FROM categorias c, marcas m WHERE c.slug = 'tejas-upvc' AND m.nombre = 'Bodegazo UPVC';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'TTV-590', 'Teja Trapezoidal Verde 5.90m 2.5mm', 'Teja UPVC trapezoidal color verde, 2.5mm de grosor.', 'TEJA_UPVC', c.id, m.id, 99000, 71000, 'unidad', 5.90, 1.10, 2.5, TRUE
FROM categorias c, marcas m WHERE c.slug = 'tejas-upvc' AND m.nombre = 'Bodegazo UPVC';
INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'TTV-1180', 'Teja Trapezoidal Verde 11.80m 2.5mm', 'Teja UPVC trapezoidal color verde, presentacion extendida, 2.5mm de grosor.', 'TEJA_UPVC', c.id, m.id, 185000, 133000, 'unidad', 11.80, 1.10, 2.5, TRUE
FROM categorias c, marcas m WHERE c.slug = 'tejas-upvc' AND m.nombre = 'Bodegazo UPVC';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'TTR-590', 'Teja Trapezoidal Roja 5.90m 2.5mm', 'Teja UPVC trapezoidal color rojo, 2.5mm de grosor.', 'TEJA_UPVC', c.id, m.id, 99000, 71000, 'unidad', 5.90, 1.10, 2.5, TRUE
FROM categorias c, marcas m WHERE c.slug = 'tejas-upvc' AND m.nombre = 'Bodegazo UPVC';
INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'TTR-1180', 'Teja Trapezoidal Roja 11.80m 2.5mm', 'Teja UPVC trapezoidal color rojo, presentacion extendida, 2.5mm de grosor.', 'TEJA_UPVC', c.id, m.id, 185000, 133000, 'unidad', 11.80, 1.10, 2.5, TRUE
FROM categorias c, marcas m WHERE c.slug = 'tejas-upvc' AND m.nombre = 'Bodegazo UPVC';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'TTAZ-590', 'Teja Trapezoidal Azul 5.90m 2.5mm', 'Teja UPVC trapezoidal color azul, 2.5mm de grosor.', 'TEJA_UPVC', c.id, m.id, 99000, 71000, 'unidad', 5.90, 1.10, 2.5, TRUE
FROM categorias c, marcas m WHERE c.slug = 'tejas-upvc' AND m.nombre = 'Bodegazo UPVC';
INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'TTAZ-1180', 'Teja Trapezoidal Azul 11.80m 2.5mm', 'Teja UPVC trapezoidal color azul, presentacion extendida, 2.5mm de grosor.', 'TEJA_UPVC', c.id, m.id, 185000, 133000, 'unidad', 11.80, 1.10, 2.5, TRUE
FROM categorias c, marcas m WHERE c.slug = 'tejas-upvc' AND m.nombre = 'Bodegazo UPVC';

-- Transparente (5.90 x 1.10 m, 1.5mm)
INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'TTRANS-590', 'Teja Transparente 5.90m 1.5mm', 'Teja UPVC transparente, ideal para iluminacion natural, 1.5mm de grosor.', 'TEJA_UPVC', c.id, m.id, 89000, 63000, 'unidad', 5.90, 1.10, 1.5, TRUE
FROM categorias c, marcas m WHERE c.slug = 'tejas-upvc' AND m.nombre = 'Bodegazo UPVC';

-- =====================================================================
-- PRODUCTOS: Mantos / impermeabilizantes (marca El Bodegon del Manto)
-- =====================================================================

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'MIPA3000', 'Manto IPA 3000 2.5mm', 'Manto impermeabilizante IPA 3000, 2.5mm de grosor.', 'IMPERMEABILIZANTE', c.id, m.id, 95000, 68000, 'rollo', 10.00, 1.00, 2.5, TRUE
FROM categorias c, marcas m WHERE c.slug = 'impermeabilizantes' AND m.nombre = 'El Bodegon del Manto';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'MCOL2', 'Manto Colombia 2mm', 'Manto impermeabilizante Colombia, 2mm de grosor.', 'IMPERMEABILIZANTE', c.id, m.id, 82000, 58000, 'rollo', 10.00, 1.00, 2.0, TRUE
FROM categorias c, marcas m WHERE c.slug = 'impermeabilizantes' AND m.nombre = 'El Bodegon del Manto';

INSERT INTO productos (codigo, nombre, descripcion, tipo_producto, categoria_id, marca_id, precio_venta, costo, unidad_medida, largo_m, ancho_m, grosor_mm, activo)
SELECT 'MMET2', 'Manto Metalex 2mm', 'Manto impermeabilizante Metalex, 2mm de grosor.', 'IMPERMEABILIZANTE', c.id, m.id, 85000, 60000, 'rollo', 10.00, 1.00, 2.0, TRUE
FROM categorias c, marcas m WHERE c.slug = 'impermeabilizantes' AND m.nombre = 'El Bodegon del Manto';

-- =====================================================================
-- INVENTARIO inicial para todos los productos de ejemplo
-- =====================================================================
INSERT INTO inventario (producto_id, stock_actual, stock_minimo, ubicacion)
SELECT p.id, 50, 10, 'Bodega principal'
FROM productos p
WHERE p.codigo IN (
    'TUC-590','TUC-1180',
    'TTB-590','TTB-1180','TTV-590','TTV-1180','TTR-590','TTR-1180','TTAZ-590','TTAZ-1180',
    'TTRANS-590',
    'MIPA3000','MCOL2','MMET2'
);

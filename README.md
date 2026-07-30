# Bodegazo de la Teja — Sistema Empresarial

Sistema web de gestión (catálogo, inventario, ventas, cotizaciones y
administración) para una empresa ferretera especializada en
impermeabilizaciones y tejas UPVC.

## Stack tecnológico

> **Nota:** el proyecto NO usa Lombok. Se probó, pero requiere instalar
> un plugin adicional dentro de Eclipse (`lombok.jar` como `-javaagent`
> en `eclipse.ini`) que en algunos entornos no logra detectarse
> automáticamente. Para evitar esa fricción, todas las entidades, DTOs
> y clases de configuración tienen sus `getters`/`setters`/constructores
> escritos explícitamente — el proyecto compila y se abre en Eclipse
> sin instalar nada adicional en el IDE.


| Capa | Tecnología |
|---|---|
| Lenguaje | Java 21 |
| Framework | Spring Boot 3.3.4 |
| Vistas | JSP + JSTL |
| Seguridad | Spring Security 6 (BCrypt, CSRF, remember-me) |
| Persistencia | Spring Data JPA + Hibernate |
| Base de datos | PostgreSQL 15+ |
| Frontend | Bootstrap 5 + Bootstrap Icons |
| Build | Maven |
| IDE | Eclipse |
| Despliegue | GitHub + Render |

## Arquitectura

Arquitectura en capas, con separación estricta de responsabilidades:

```
Controller  → recibe peticiones HTTP, delega al Service, retorna vista JSP
Service     → interfaces con la lógica de negocio (contratos)
ServiceImpl → implementación de la lógica de negocio
Repository  → interfaces Spring Data JPA (acceso a datos)
Entity      → mapeo objeto-relacional (JPA)
DTO         → objetos de transferencia entre capas (nunca se expone la Entity directamente a la vista)
Security    → configuración de autenticación/autorización
Config      → configuración general (JSP, recursos estáticos, beans)
Exception   → excepciones de negocio y manejo global de errores
Utils       → utilidades transversales (cálculo de mantos/tejas, generación de PDF/QR, etc.)
```

Flujo de una petición:

```
Cliente (navegador)
   → DispatcherServlet
      → Controller
         → Service (interfaz)
            → ServiceImpl (lógica de negocio + validaciones)
               → Repository (Spring Data JPA)
                  → PostgreSQL
      ← DTO
   ← Vista JSP (WEB-INF/jsp/...)
```

## Estructura del proyecto

```
ferreteria-sistema/
├── pom.xml
├── .gitignore
├── README.md
├── database/
│   └── schema.sql              # Script completo de base de datos
└── src/
    └── main/
        ├── java/com/bodegazo/ferreteria/
        │   ├── FerreteriaApplication.java
        │   ├── config/         # WebMvcConfig (JSP, recursos estáticos)
        │   ├── controller/
        │   ├── dto/
        │   ├── entity/
        │   ├── exception/
        │   ├── repository/
        │   ├── security/       # SecurityConfig
        │   ├── service/
        │   ├── serviceImpl/
        │   └── utils/
        ├── resources/
        │   ├── application.properties
        │   ├── application-dev.properties
        │   ├── application-prod.properties
        │   ├── messages.properties
        │   └── static/{css,js,images,icons,fonts}
        └── webapp/
            ├── WEB-INF/jsp/{layouts,fragments,pages}
            ├── css/ js/ images/ uploads/
            └── META-INF/
```

## Prueba rápida SIN configurar PostgreSQL (perfil "h2")

Si todavía no tienes PostgreSQL configurado y solo quieres ver el
sitio funcionando, existe un perfil temporal `h2` que usa una base de
datos en memoria — se crea sola al arrancar, con datos de prueba ya
cargados, y se borra al apagar la aplicación. **No requiere instalar
ni configurar nada.**

**Cómo usarlo en Eclipse:**

1. Clic derecho sobre `FerreteriaApplication.java` → **Run As → Run Configurations...**
2. Pestaña **Arguments** → en "Program arguments" agrega:
   ```
   --spring.profiles.active=h2
   ```
3. **Apply** → **Run**

Al arrancar, verás en la consola que Hibernate crea las tablas solo y
carga automáticamente: los 4 roles, un usuario administrador
(`admin@bodegazodelateja.com` / `password`), categorías, marca de
ejemplo, las 6 tejas UPVC del catálogo, su inventario y los
parámetros de las calculadoras.

Visita `http://localhost:8080/inicio` y navega el sitio completo:
login, catálogo, calculadoras, dashboard — todo funciona igual que con
PostgreSQL, porque el código no cambia, solo la base de datos.

⚠️ **Esto es temporal.** Cuando quieras conectar PostgreSQL de verdad
(local o en Render), vuelve a usar el perfil `dev` o `prod` — el
perfil `h2` y sus dependencias (`h2`, `data-h2.sql`,
`application-h2.properties`) se pueden eliminar del proyecto en ese
momento sin afectar nada más.

## Base de datos

El script `database/schema.sql` crea el esquema `bodegazo` con las
siguientes tablas, normalizadas y con llaves foráneas:

`roles`, `usuarios`, `usuarios_roles`, `usuarios_remember_me_tokens`,
`clientes`, `marcas`, `categorias`, `proveedores`, `productos`,
`producto_imagenes`, `inventario`, `entradas`, `salidas`, `ventas`,
`detalle_ventas`, `cotizaciones`, `detalle_cotizaciones`,
`movimientos_inventario`, `auditoria`, `configuraciones`.

Incluye datos semilla: los 4 roles del sistema, categorías base, un
usuario administrador temporal y parámetros de configuración
(IVA, traslapos de cálculo de mantos y tejas, vigencia de cotizaciones).

### Cómo crear la base de datos

```bash
createdb bodegazo_teja
psql -d bodegazo_teja -f database/schema.sql
```

**Usuario administrador temporal (cambiar contraseña de inmediato):**
- Correo: `admin@bodegazodelateja.com`
- Contraseña: `password`

## Despliegue en Render con Docker

El proyecto incluye un `Dockerfile` multi-stage (compila con Maven+JDK 21
en la primera etapa, corre con un JRE 21 liviano en la segunda) y un
`.dockerignore`. Con esto, Render construye la imagen directamente sin
necesidad de detectar el runtime de Java por su cuenta.

### Probar la imagen en local (opcional pero recomendado antes de desplegar)

```bash
docker build -t ferreteria-sistema .
docker run -p 8080:8080 \
  -e DB_URL=jdbc:postgresql://host.docker.internal:5432/bodegazo_teja \
  -e DB_USERNAME=postgres \
  -e DB_PASSWORD=postgres \
  -e REMEMBER_ME_KEY=clave-local \
  ferreteria-sistema
```

### Desplegar en Render

**a) Base de datos**
1. Render → **New +** → **PostgreSQL**
2. Nómbrala, elige región y plan
3. Copia el **Internal Database URL** (o arma el JDBC: `jdbc:postgresql://<host>:5432/<database>`), usuario y contraseña
4. Ejecuta `database/schema.sql` contra esa base (botón **Connect** de Render te da el comando `psql`)

**b) Servicio web (Docker)**
1. Render → **New +** → **Web Service**
2. Conecta tu repositorio de GitHub (`Bodegazo-de-la-Teja`)
3. En **Language/Runtime**, Render detecta automáticamente el `Dockerfile` en la raíz — selecciona **Docker** si te lo pregunta explícitamente
4. Deja el **Build Command** y **Start Command** vacíos (el `Dockerfile` ya define cómo se construye y arranca con `ENTRYPOINT`)
5. En **Environment Variables**, agrega:
   - `DB_URL` = URL JDBC de tu base en Render
   - `DB_USERNAME` / `DB_PASSWORD` = credenciales de la base
   - `REMEMBER_ME_KEY` = una clave secreta larga que inventes
   - (`SPRING_PROFILES_ACTIVE=prod` y `PORT` ya están cubiertos por el `Dockerfile`/Render, no hace falta agregarlos)
6. **Create Web Service** — Render construye la imagen y despliega

Cada `git push` a `main` dispara un nuevo build y despliegue automático.

1. `File → Import → Maven → Existing Maven Projects`
2. Seleccionar la carpeta `ferreteria-sistema`
3. Eclipse descargará las dependencias definidas en `pom.xml`
4. Configurar la base de datos (ver siguiente sección)
5. Ejecutar `FerreteriaApplication.java` como `Java Application`
   (con `-Dspring.profiles.active=dev`) o como `Spring Boot App`

## Variables de entorno

| Variable | Descripción | Ejemplo |
|---|---|---|
| `DB_URL` | Cadena de conexión JDBC | `jdbc:postgresql://localhost:5432/bodegazo_teja` |
| `DB_USERNAME` | Usuario de PostgreSQL | `postgres` |
| `DB_PASSWORD` | Contraseña de PostgreSQL | — |
| `PORT` | Puerto del servidor (Render lo inyecta automáticamente) | `8080` |
| `REMEMBER_ME_KEY` | Clave secreta para "recordarme" | — |
| `MAIL_HOST` / `MAIL_USERNAME` / `MAIL_PASSWORD` | Envío de cotizaciones por correo | — |
| `UPLOADS_DIR` | Carpeta de imágenes/fichas técnicas subidas | `src/main/webapp/uploads` |

En local, se recomienda usar el perfil `dev`
(`application-dev.properties`). En Render se activa el perfil `prod`
mediante `SPRING_PROFILES_ACTIVE=prod`, y todas las credenciales se
inyectan como variables de entorno del servicio (nunca se versionan).

## Cómo probar la entrega 1 (arquitectura y configuración)

1. Verificar que el proyecto compila: `mvn clean compile`
2. Verificar que la app levanta: `mvn spring-boot:run -Dspring-boot.run.profiles=dev`
   (mostrará errores de `ddl-auto=validate` hasta correr `schema.sql` — es esperado)
3. Ejecutar el script SQL contra PostgreSQL y volver a levantar la app
4. Confirmar en el log que Spring Security y el datasource inician sin errores

## Entrega 2 — Entidades JPA, Repositorios y autenticación real

Se agregaron las 18 entidades JPA (una por tabla del script SQL) en `entity/`,
sus 18 repositorios Spring Data JPA en `repository/`, y la autenticación
real contra PostgreSQL:

- `security/CustomUserPrincipal.java`: adapta la entidad `Usuario` al
  contrato `UserDetails` de Spring Security, exponiendo cada rol como
  autoridad `ROLE_<nombre>`.
- `security/CustomUserDetailsService.java`: busca el usuario por correo
  en `UsuarioRepository`.
- `SecurityConfig.java` registra un `DaoAuthenticationProvider` que usa
  `CustomUserDetailsService` + BCrypt, reemplazando el usuario en
  memoria por defecto de Spring Boot.

## Entrega 3 — Controllers, layout Bootstrap y páginas públicas

Se agregaron:

- **Fragments** (`webapp/WEB-INF/jsp/fragments/`): `head.jsp` (meta tags,
  Bootstrap 5 + Bootstrap Icons vía WebJars, CSS de marca), `navbar.jsp`
  (menú responsive con mega-dropdowns de Productos y Calculadoras,
  cambia según `sec:authorize` si hay sesión activa), `footer.jsp`,
  `scripts.jsp`.
- **`webapp/css/style.css`**: paleta de marca (azul oscuro `#0a2540`,
  naranja de acento `#f28c28`, gris claro, blanco), cards con hover,
  hero con degradado, estilos de formularios y páginas de error.
- **Controllers**: `PublicController` (inicio, nosotros, contacto con
  formulario POST), `AuthViewController` (vista de login con mensajes
  de error/logout/expirado), `DashboardController` (confirma que el
  login autentica de verdad contra PostgreSQL), `GlobalErrorController`
  + `ErrorPagesController` (403/404/500 personalizados, no la página
  "Whitelabel" de Spring Boot), `ComingSoonController` (placeholder
  temporal para catálogo/calculadoras/registro, para que la navegación
  no tenga enlaces rotos mientras se desarrollan en próximas entregas).
- **Páginas** (`webapp/WEB-INF/jsp/pages/`): `inicio.jsp`, `nosotros.jsp`,
  `contacto.jsp`, `login.jsp`, `dashboard.jsp`, `error-403.jsp`,
  `error-404.jsp`, `error-500.jsp`, `mantenimiento.jsp`,
  `en-construccion.jsp`.

Todos los formularios POST (login, logout, contacto) incluyen el token
CSRF (`${_csrf.parameterName}` / `${_csrf.token}`), requerido porque
CSRF sigue habilitado en `SecurityConfig`.

**Cómo probarlo:**

1. Asegúrate de tener `database/schema.sql` ya ejecutado
2. `mvn clean compile` — debe compilar sin errores
3. Levanta la app: `mvn spring-boot:run -Dspring-boot.run.profiles=dev`
4. Ve a `http://localhost:8080/inicio` — deberías ver el sitio con
   navbar, hero y footer con la marca de Bodegazo de la Teja
5. Ve a `http://localhost:8080/login` e inicia sesión con
   `admin@bodegazodelateja.com` / `password` — debe redirigirte a
   `/dashboard` mostrando tu nombre, correo y rol (`ROLE_ADMINISTRADOR`)
6. Prueba `/logout` y confirma que vuelve a `/login` con mensaje de
   "Sesión cerrada correctamente"
7. Prueba una URL que no existe, ej. `/algo-que-no-existe`, y confirma
   que ves la página 404 personalizada, no la de Spring Boot

Se agregaron las 18 entidades JPA (una por tabla del script SQL) en `entity/`,
sus 18 repositorios Spring Data JPA en `repository/`, y la autenticación
real contra PostgreSQL:

- `security/CustomUserPrincipal.java`: adapta la entidad `Usuario` al
  contrato `UserDetails` de Spring Security, exponiendo cada rol como
  autoridad `ROLE_<nombre>`.
- `security/CustomUserDetailsService.java`: busca el usuario por correo
  en `UsuarioRepository`.
- `SecurityConfig.java` ahora registra un `DaoAuthenticationProvider`
  que usa `CustomUserDetailsService` + BCrypt, reemplazando el usuario
  en memoria por defecto de Spring Boot.

**Cómo probarlo:**

1. Ejecuta `database/schema.sql` si aún no lo has hecho (ya trae el
   usuario admin semilla).
2. Levanta la app: `mvn spring-boot:run -Dspring-boot.run.profiles=dev`
3. Ve a `http://localhost:8080/login` — el login ya no responderá con
   un usuario en memoria, sino que consultará la tabla `usuarios`.
   (Nota: la vista `login.jsp` todavía no existe — eso se agrega en la
   entrega de Controllers + Vistas. Por ahora puedes verificar la
   autenticación con una petición POST directa a `/login` con
   `correo` y `password`, o esperar a la siguiente entrega.)
4. Credenciales semilla: `admin@bodegazodelateja.com` / `password`

## Entrega 4 — Catálogo de productos

Se agregaron:

- **DTOs**: `ProductoResumenDTO` (tarjetas de listado) y `ProductoDetalleDTO`
  (ficha completa con galería) — la entidad JPA `Producto` nunca se
  expone directamente a la vista.
- **`ProductoService` / `ProductoServiceImpl`**: listado paginado con
  filtros combinables (tipo de producto, categoría, búsqueda por
  nombre) y obtención de detalle por id, calculando disponibilidad a
  partir del `Inventario` asociado.
- **`ProductoController`**: `/productos` (catálogo completo con
  búsqueda y paginación), `/impermeabilizantes` y `/tejas-upvc`
  (atajos filtrados por tipo de producto — ya no muestran "en
  construcción"), y `/productos/{id}` (ficha de detalle).
- **`RecursoNoEncontradoException` + `GlobalExceptionHandler`**: si
  alguien visita `/productos/999` y no existe, se muestra la página
  404 personalizada en vez de un error 500.
- **Vistas**: `productos-lista.jsp` (grid de tarjetas, buscador,
  paginación) y `producto-detalle.jsp` (galería, precio, disponibilidad,
  botón directo a la calculadora correspondiente y a cotización).
- **Datos de ejemplo en `schema.sql`**: se agregaron las 6 tejas UPVC
  reales de tu catálogo (Colonial Terracota, Trapezoidal Cresta Alta,
  Cresta Baja, en sus dos presentaciones) con inventario inicial, para
  que el catálogo no se vea vacío al probarlo.

**Cómo probarlo:**

1. Si ya tenías la base de datos creada de entregas anteriores, corre
   solo la sección nueva de `schema.sql` (desde `-- PRODUCTOS DE EJEMPLO`
   hasta el final) para no reintentar crear tablas existentes. Si es
   una base nueva, corre el script completo.
2. `mvn clean compile` y levanta la app
3. Ve a `http://localhost:8080/tejas-upvc` — deberías ver las 6 tejas
   de ejemplo en tarjetas, con precio y disponibilidad
4. Prueba el buscador (ej. "colonial") y la paginación
5. Haz clic en "Ver detalle" de cualquier producto — confirma que
   carga la ficha completa con el botón "Calcular cantidad necesaria"
6. Prueba `/productos/9999` (un id que no existe) y confirma que
   muestra la página 404 personalizada, no un error 500

## Entrega 5 — Calculadora de Mantos y Calculadora de Tejas

Se agregaron:

- **`CalculoService` / `CalculoServiceImpl`**: implementa el método de
  cálculo por franjas/hileras — cada módulo adicional (rollo o teja)
  solo aporta cobertura nueva de `(tamaño_módulo - traslapo)`, porque
  el traslapo se solapa con el módulo anterior. Todos los parámetros
  (tamaño de rollo/teja, traslapos, precios de referencia) se leen de
  la tabla `configuraciones`, no están *hardcodeados* — se pueden
  ajustar sin tocar código.
- **`CalculadoraController`**: `/calculadora-mantos` y
  `/calculadora-tejas`, cada una con GET (formulario) y POST (calcula
  y redibuja el resultado en la misma página).
- **Vistas**: formulario + panel de resultado con área a cubrir,
  franjas/hileras necesarias, porcentaje de desperdicio, cantidad
  recomendada y costo estimado.

⚠️ **Supuesto importante que debes confirmar**: como el enunciado no
especificó el tamaño comercial exacto del rollo de manto ni el módulo
de teja "genérico" para la calculadora, usé valores de referencia
configurables en `configuraciones`:
- Rollo de manto: 1.00 m x 10.00 m, traslapo 0.80 m (ya definido)
- Teja UPVC (módulo genérico): 5.90 m x 1.10 m, traslapos 10 cm / 20 cm (ya definidos)

Si tus rollos/tejas reales tienen otras medidas, solo hay que
actualizar esos registros en `configuraciones` (`MANTO_ANCHO_ROLLO_M`,
`TEJA_ANCHO_MODULO_M`, etc.) — no requiere tocar código ni recompilar.

**Cómo probarlo:**

1. Si tu base ya existía, corre solo los `INSERT` nuevos de
   `configuraciones` (las claves `MANTO_ANCHO_ROLLO_M`,
   `TEJA_LARGO_MODULO_M`, etc.) para no reintentar crear las tablas
2. `mvn clean compile` y levanta la app
3. Ve a `http://localhost:8080/calculadora-tejas`, ingresa por ejemplo
   largo `12` y ancho `6`, y confirma que el resultado tiene sentido
   (hileras, tejas por hilera, desperdicio, costo)
4. Repite en `/calculadora-mantos`

## Roles y permisos del sistema

Confirmando el reparto de permisos ya definido en `SecurityConfig`
desde la Entrega 1 (aplica también a lo que se construya en las
próximas entregas: gestión de productos, inventario, usuarios):

| Ruta | CLIENTE | EMPLEADO | JEFE_BODEGA | ADMINISTRADOR |
|---|---|---|---|---|
| Catálogo, calculadoras, contacto | ✅ | ✅ | ✅ | ✅ |
| `/cotizaciones/**` | ✅ | ✅ | ✅ | ✅ |
| `/inventario/**` (entradas, salidas, stock) | ❌ | ❌ | ✅ | ✅ |
| `/administracion/**` | ❌ | ❌ | ✅ | ✅ |
| `/usuarios/**`, `/configuracion/**`, `/reportes/**` | ❌ | ❌ | ❌ | ✅ |

Cuando construyamos el **CRUD de productos** (crear/editar/eliminar,
subir imágenes, fichas técnicas), lo voy a colocar bajo
`/administracion/productos/**` — es decir, **Administrador y Jefe de
Bodega** podrán gestionarlo, y **Empleado/Cliente** solo podrán
consultarlo desde el catálogo público. Avísame si prefieres que la
gestión de productos quede exclusiva para Administrador (sin Jefe de
Bodega) y ajusto la regla antes de construir ese módulo.

## Roadmap (próximas entregas)

- [x] Entidades JPA + Repositorios (18 entidades / 18 repositorios)
- [x] CustomUserDetailsService + integración con `usuarios`/`roles` (login autentica contra PostgreSQL)
- [x] Controllers y vistas JSP (layouts, fragments, páginas públicas)
- [ ] DTOs + mapeos
- [x] Catálogo de productos (listado, filtros, ficha de producto)
- [x] Calculadora de mantos y calculadora de tejas
- [ ] Módulo de inventario (entradas, salidas, alertas de stock mínimo)
- [x] Módulo de ventas y cotizaciones (falta PDF y envío por correo — dependencias comentadas temporalmente)
- [ ] Dashboard administrativo con gráficos
- [ ] SEO (meta tags, sitemap, robots.txt, Open Graph)
- [ ] Despliegue en Render

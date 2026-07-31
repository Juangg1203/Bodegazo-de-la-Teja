# =====================================================================
# Dockerfile - Bodegazo de la Teja (Sistema Empresarial)
# Build multi-stage: compila con Maven + JDK 21, corre con JRE 21
# =====================================================================

# ---------- ETAPA 1: BUILD ----------
FROM maven:3.9.9-eclipse-temurin-21 AS build

WORKDIR /app

# Copiamos primero solo el pom.xml para aprovechar la caché de capas de
# Docker: si no cambian las dependencias, no se vuelven a descargar
# en cada build.
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Ahora copiamos el resto del código fuente
COPY src ./src

# Empaquetamos (genera el .war en target/, definido por <finalName> en pom.xml)
RUN mvn clean package -DskipTests -B

# ---------- ETAPA 2: RUNTIME ----------
FROM eclipse-temurin:21-jre-jammy

WORKDIR /app

# Usuario no privilegiado (buena práctica de seguridad en producción)
RUN groupadd -r bodegazo && useradd -r -g bodegazo bodegazo

# Copiamos únicamente el artefacto compilado desde la etapa de build
COPY --from=build /app/target/ferreteria-sistema.war app.war

# Carpeta de subida de archivos (imágenes de productos, fichas técnicas)
RUN mkdir -p /app/uploads && chown -R bodegazo:bodegazo /app

USER bodegazo

# Render inyecta la variable PORT; application.properties ya la respeta
# (server.port=${PORT:8080})
EXPOSE 8080

# Perfil de producción activo por defecto; Render lo puede sobreescribir
# TEMPORAL: perfil "render" (H2 en memoria) mientras PostgreSQL tarde
# demasiado en arrancar dentro del limite de Render. Para volver a
# PostgreSQL real, cambiar esto a "prod" (y configurar DB_URL, etc.).
ENV SPRING_PROFILES_ACTIVE=render
ENV UPLOADS_DIR=/app/uploads

# Banderas de arranque rápido para el CPU compartido/limitado del plan
# gratuito de Render: se salta la compilación JIT avanzada (C2) y usa un
# recolector de basura más liviano, a cambio de un poco de rendimiento
# en régimen permanente — vale la pena para que el arranque no exceda
# el tiempo límite de detección de puerto de Render.
ENTRYPOINT ["java", \
    "-XX:TieredStopAtLevel=1", \
    "-XX:+UseSerialGC", \
    "-Xss512k", \
    "-Xmx400m", \
    "-jar", "/app/app.war"]

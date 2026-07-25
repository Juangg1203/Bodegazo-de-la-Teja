package com.bodegazo.ferreteria;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;

/**
 * Punto de entrada de la aplicación.
 *
 * Extiende SpringBootServletInitializer para permitir el empaquetado como
 * WAR (requerido por el soporte de JSP) y su despliegue tanto en un
 * contenedor Servlet externo como con el servidor embebido de Spring Boot
 * (Render ejecuta el WAR con el Tomcat embebido, no requiere contenedor externo).
 */
@SpringBootApplication
public class FerreteriaApplication extends SpringBootServletInitializer {

    public static void main(String[] args) {
        SpringApplication.run(FerreteriaApplication.class, args);
    }

    @Override
    protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
        return application.sources(FerreteriaApplication.class);
    }
}

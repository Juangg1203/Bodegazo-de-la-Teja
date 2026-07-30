package com.bodegazo.ferreteria.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.ViewResolver;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
import org.springframework.web.servlet.view.InternalResourceViewResolver;
import org.springframework.web.servlet.view.JstlView;

/**
 * Configuración de la capa de vistas (JSP + JSTL) y de los recursos
 * estáticos servidos desde /src/main/webapp y /src/main/resources/static.
 *
 * IMPORTANTE: las rutas SIN prefijo ("/css/", "/js/", etc., sin "file:"
 * ni "classpath:") apuntan a la raíz del WAR (src/main/webapp/...) — así
 * es como se sirven en este proyecto los archivos reales del sitio
 * (style.css, main.js, los logos). Se agrega "classpath:/static/..."
 * solo como respaldo adicional. Si esta ruta se cambia por SOLO
 * "classpath:/static/...", los archivos de /webapp dejan de encontrarse
 * (eso rompió el CSS y los logos en el primer despliegue a Render).
 */
@Configuration
public class WebMvcConfig implements WebMvcConfigurer {

    @Value("${app.uploads.dir}")
    private String uploadsDir;

    @Bean
    public ViewResolver viewResolver() {
        InternalResourceViewResolver resolver = new InternalResourceViewResolver();
        resolver.setViewClass(JstlView.class);
        resolver.setPrefix("/WEB-INF/jsp/");
        resolver.setSuffix(".jsp");
        resolver.setOrder(0);
        return resolver;
    }

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        registry.addResourceHandler("/css/**")
                .addResourceLocations("/css/", "classpath:/static/css/");

        registry.addResourceHandler("/js/**")
                .addResourceLocations("/js/", "classpath:/static/js/");

        registry.addResourceHandler("/images/**")
                .addResourceLocations("/images/", "classpath:/static/images/");

        registry.addResourceHandler("/icons/**")
                .addResourceLocations("/icons/", "classpath:/static/icons/");

        registry.addResourceHandler("/fonts/**")
                .addResourceLocations("/fonts/", "classpath:/static/fonts/");

        // Carpeta de imágenes subidas por el panel de administración.
        // uploadsDir viene de app.uploads.dir (application.properties):
        // en local es una ruta relativa al proyecto, en Render es
        // /app/uploads (definida por el Dockerfile).
        registry.addResourceHandler("/uploads/**")
                .addResourceLocations("file:" + uploadsDir + "/");
    }
}

package com.bodegazo.ferreteria.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
import org.springframework.web.servlet.view.InternalResourceViewResolver;
import org.springframework.web.servlet.view.JstlView;

/**
 * Configuración de la capa de vistas (JSP + JSTL) y de los recursos
 * estáticos servidos desde /src/main/webapp y /src/main/resources/static.
 */
@Configuration
public class WebMvcConfig implements WebMvcConfigurer {

    @Bean
    public InternalResourceViewResolver viewResolver() {
        InternalResourceViewResolver resolver = new InternalResourceViewResolver();
        resolver.setViewClass(JstlView.class);
        resolver.setPrefix("/WEB-INF/jsp/");
        resolver.setSuffix(".jsp");
        resolver.setOrder(1);
        return resolver;
    }

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        registry.addResourceHandler("/css/**").addResourceLocations("/css/", "classpath:/static/css/");
        registry.addResourceHandler("/js/**").addResourceLocations("/js/", "classpath:/static/js/");
        registry.addResourceHandler("/images/**").addResourceLocations("/images/", "classpath:/static/images/");
        registry.addResourceHandler("/icons/**").addResourceLocations("classpath:/static/icons/");
        registry.addResourceHandler("/fonts/**").addResourceLocations("classpath:/static/fonts/");
        registry.addResourceHandler("/uploads/**").addResourceLocations("file:src/main/webapp/uploads/");
    }
}

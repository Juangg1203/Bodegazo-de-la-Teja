package com.bodegazo.ferreteria.controller;

import com.bodegazo.ferreteria.repository.ConfiguracionRepository;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

/**
 * Agrega automáticamente los datos de contacto de la empresa (teléfono,
 * WhatsApp, correo, dirección) al modelo de TODAS las vistas — así el
 * footer y la página de contacto los pueden usar sin que cada controller
 * tenga que consultarlos por su cuenta.
 */
@ControllerAdvice
public class GlobalModelAttributesAdvice {

    private final ConfiguracionRepository configuracionRepository;

    public GlobalModelAttributesAdvice(ConfiguracionRepository configuracionRepository) {
        this.configuracionRepository = configuracionRepository;
    }

    @ModelAttribute("empresaTelefono")
    public String empresaTelefono() {
        return obtenerConfig("EMPRESA_TELEFONO");
    }

    @ModelAttribute("empresaWhatsapp")
    public String empresaWhatsapp() {
        return obtenerConfig("EMPRESA_WHATSAPP");
    }

    @ModelAttribute("empresaCorreo")
    public String empresaCorreo() {
        return obtenerConfig("EMPRESA_CORREO");
    }

    @ModelAttribute("empresaDireccion")
    public String empresaDireccion() {
        return obtenerConfig("EMPRESA_DIRECCION");
    }

    @ModelAttribute("empresaDireccionUrl")
    public String empresaDireccionUrl() {
        String direccion = obtenerConfig("EMPRESA_DIRECCION");
        try {
            return java.net.URLEncoder.encode(direccion, java.nio.charset.StandardCharsets.UTF_8);
        } catch (Exception e) {
            return direccion;
        }
    }

    private String obtenerConfig(String clave) {
        return configuracionRepository.findByClave(clave)
                .map(c -> c.getValor())
                .orElse("");
    }
}

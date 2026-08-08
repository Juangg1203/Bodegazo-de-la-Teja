package com.bodegazo.ferreteria.dto;

import java.util.List;

public class UsuarioResumenDTO {
    private Long id;
    private String nombre;
    private String apellido;
    private String correo;
    private boolean activo;
    private List<String> roles;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getApellido() { return apellido; }
    public void setApellido(String apellido) { this.apellido = apellido; }

    public String getCorreo() { return correo; }
    public void setCorreo(String correo) { this.correo = correo; }

    public boolean isActivo() { return activo; }
    public void setActivo(boolean activo) { this.activo = activo; }

    public List<String> getRoles() { return roles; }
    public void setRoles(List<String> roles) { this.roles = roles; }

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private final UsuarioResumenDTO dto = new UsuarioResumenDTO();
        public Builder id(Long v) { dto.id = v; return this; }
        public Builder nombre(String v) { dto.nombre = v; return this; }
        public Builder apellido(String v) { dto.apellido = v; return this; }
        public Builder correo(String v) { dto.correo = v; return this; }
        public Builder activo(boolean v) { dto.activo = v; return this; }
        public Builder roles(List<String> v) { dto.roles = v; return this; }
        public UsuarioResumenDTO build() { return dto; }
    }
}

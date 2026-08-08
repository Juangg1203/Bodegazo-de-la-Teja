package com.bodegazo.ferreteria.dto;

import java.util.List;

public class UsuarioFormDTO {
    private Long id;
    private String nombre;
    private String apellido;
    private String correo;
    private String password;      // vacío al editar = no cambiar la contraseña
    private String telefono;
    private List<Long> rolesIds;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getApellido() { return apellido; }
    public void setApellido(String apellido) { this.apellido = apellido; }

    public String getCorreo() { return correo; }
    public void setCorreo(String correo) { this.correo = correo; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getTelefono() { return telefono; }
    public void setTelefono(String telefono) { this.telefono = telefono; }

    public List<Long> getRolesIds() { return rolesIds; }
    public void setRolesIds(List<Long> rolesIds) { this.rolesIds = rolesIds; }
}

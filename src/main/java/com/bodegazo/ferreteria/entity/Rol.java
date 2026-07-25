package com.bodegazo.ferreteria.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "roles")
public class Rol {

    public static final String CLIENTE = "CLIENTE";
    public static final String EMPLEADO = "EMPLEADO";
    public static final String JEFE_BODEGA = "JEFE_BODEGA";
    public static final String ADMINISTRADOR = "ADMINISTRADOR";

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 30)
    private String nombre;

    @Column(length = 150)
    private String descripcion;

    public Rol() {
    }

    public Rol(Long id, String nombre, String descripcion) {
        this.id = id;
        this.nombre = nombre;
        this.descripcion = descripcion;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Rol)) return false;
        Rol rol = (Rol) o;
        return id != null && id.equals(rol.id);
    }

    @Override
    public int hashCode() {
        return getClass().hashCode();
    }
}

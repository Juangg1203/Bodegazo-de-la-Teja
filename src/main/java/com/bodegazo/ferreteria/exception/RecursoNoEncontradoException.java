package com.bodegazo.ferreteria.exception;

/**
 * Excepción de negocio para cuando se busca una entidad (producto,
 * cliente, etc.) que no existe. GlobalErrorController la traduce a
 * la vista 404 personalizada.
 */
public class RecursoNoEncontradoException extends RuntimeException {
    public RecursoNoEncontradoException(String mensaje) {
        super(mensaje);
    }
}

// Bodegazo de la Teja - script principal del sitio

document.addEventListener('DOMContentLoaded', function () {

    // ============ 1. Cierra las alertas automáticamente ============
    document.querySelectorAll('.alert-dismissible').forEach(function (alertEl) {
        setTimeout(function () {
            const alert = bootstrap.Alert.getOrCreateInstance(alertEl);
            alert.close();
        }, 5000);
    });

    // ============ 2. Barra de carga al navegar o enviar formularios ============
    const barra = document.createElement('div');
    barra.id = 'barra-carga';
    document.body.appendChild(barra);

    function mostrarBarraCarga() {
        barra.classList.add('activa');
    }

    // Se activa al hacer clic en cualquier enlace interno normal
    document.addEventListener('click', function (e) {
        const link = e.target.closest('a');
        if (!link) return;
        const href = link.getAttribute('href');
        if (!href || href.startsWith('#') || href.startsWith('javascript:')) return;
        if (link.target === '_blank' || link.hasAttribute('download')) return;
        if (e.ctrlKey || e.metaKey || e.shiftKey) return; // abrir en pestaña nueva, no interceptar
        mostrarBarraCarga();
    });

    // Se activa al enviar cualquier formulario
    document.addEventListener('submit', function () {
        mostrarBarraCarga();
    });

    // ============ 3. Botones que muestran "Procesando..." al enviar un formulario ============
    document.querySelectorAll('form').forEach(function (form) {
        form.addEventListener('submit', function (e) {
            const boton = form.querySelector('button[type="submit"]');
            if (!boton || boton.disabled) return;

            // Si el formulario es inválido (validación HTML5), no bloqueamos el botón
            if (form.checkValidity && !form.checkValidity()) return;

            const textoOriginal = boton.innerHTML;
            boton.dataset.textoOriginal = textoOriginal;
            boton.disabled = true;
            boton.innerHTML = '<span class="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true"></span>Procesando...';
        });
    });
});

// Bodegazo de la Teja - script principal del sitio
// (los módulos de calculadoras y catálogo se agregan en sus respectivas entregas)

document.addEventListener('DOMContentLoaded', function () {
    // Cierra automáticamente las alertas de Bootstrap después de 5 segundos
    document.querySelectorAll('.alert-dismissible').forEach(function (alertEl) {
        setTimeout(function () {
            const alert = bootstrap.Alert.getOrCreateInstance(alertEl);
            alert.close();
        }, 5000);
    });
});

# WP Setup

*Este repositorio es un clon de [WP Setup](https://github.com/harryfinn/wp-setup) de [@harryfinn](https://github.com/harryfinn).*

## Descripción

Este repositorio contiene un pequeño script de `bash` diseñado para ayudar a acelerar el desarrollo local de WordPress aprovechando [WP-CLI](https://wp-cli.org) para realizar instrucciones de configuración comunes, como la creación de bases de datos, descarga, instalación y configuración de WordPress. , listo para el desarrollo.

## Modo de uso
Descargue el archivo `script.sh`, otorgue permisos ejecutables y muévalo a la ruta adecuada:

```bash
curl -O https://raw.githubusercontent.com/rogertm/wp-setup/main/script.sh
chmod +x script.sh
sudo mv script.sh /usr/local/bin/wp-setup
```

Ahora puede usar esta herramienta ejecutando el siguiente comando `wp-setup` dentro del directorio en el que desea generar una instalación de WordPress, lista para el desarrollo.

## Cambios fundamentales con respecto al repositorio original

* Opciones de configuración adicionales como:
  * *Admin user name*
  * *Admin password*
  * *Database table prefix*
  * *Debug mode*
* Si el modo debug es activado se instalarán los plugins [Query Monitor](https://wordpress.org/plugins/query-monitor/) y [Debug Bar](https://wordpress.org/plugins/debug-bar/).

## TODO

* [ ] Agregar manejo de errores para comandos WP-CLI

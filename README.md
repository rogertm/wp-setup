# WP Setup

*Este repositorio es un clon de [WP Setup](https://github.com/harryfinn/wp-setup) de [@harryfinn](https://github.com/harryfinn).*

## Descripción

Este repositorio contiene un pequeño script de `bash` diseñado para ayudar a acelerar el desarrollo local de WordPress aprovechando [WP-CLI](https://wp-cli.org) para realizar instrucciones de configuración comunes, como la creación de bases de datos, descarga, instalación y configuración de WordPress. , listo para el desarrollo.

## Modo de uso
Descargue el archivo `wp-setup.sh`, otorgue permisos ejecutables y muévalo a la ruta adecuada:

```bash
curl -O https://raw.githubusercontent.com/rogertm/wp-setup/main/wp-setup.sh
chmod +x wp-setup.sh
sudo mv wp-setup.sh /usr/local/bin/wp-setup
```

Ahora puede usar esta herramienta ejecutando el siguiente comando `wp-setup` dentro del directorio en el que desea generar una instalación de WordPress, lista para el desarrollo.

## Cambios fundamentales con respecto al repositorio original

* Opciones de configuración adicionales como:
  * *Nombre de usuario*
  * *Contraseña de usuario*
  * *Prefijo de tablas de la base de datos*
  * *Modo Debug*
  * *Instalación de los plugins [Query Monitor](https://wordpress.org/plugins/query-monitor/) y [Debug Bar](https://wordpress.org/plugins/debug-bar/) en modo Debug*
  * *Interactividad mejorada para la eliminación de contenido predeterminado*
* Mejoras generales
  * *Uso de colores robusto y portable*
  * *Verificación eficiente del WP-CLI*
  * *Validación rigurosa de la entrada de datos*
  * *Manejo detallado de errores y mensajes claros*
  * *Gestión segura de la base de datos*
  * *Actualización de plugins y temas tras la instalación*
  * *Seguridad en la presentación de la información final*

Este plugin ha sido mejorado con la ayuda de *ChatGPT*.

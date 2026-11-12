# Laboratorio local de triaje SSH

**Autor** Daniel Abanto  
**Fecha** 2026-11-12

## Objetivo

Obtener registros auténticos de OpenSSH 8.5p1 con tres secuencias de inicio de sesión y explicar qué señales justifican investigar un posible acceso no autorizado.

## Revisión previa del diseño

Se completaron siete revisiones independientes del diseño. Recomendaron comprobar el alcance del puerto desde el host, verificar la versión que anuncia el servidor y separar los casos en ventanas UTC con recuentos esperados. También señalaron que Docker puede traducir la IP de origen y que los eventos de autenticación por sí solos no identifican a la persona que accedió.

## Decisiones

- Un servidor y un cliente local bastan para practicar la investigación. La opción de registros sintéticos facilita el análisis, pero pierde la práctica de recolectarlos. El servidor en contenedor permite recrear el entorno y retirar el servicio al terminar.
- La versión histórica solicitada se compila desde código fuente con la suma oficial y se restringe a loopback. La cuenta de práctica recibe su contraseña después de crear el contenedor.
- Se comparte una muestra saneada con los resultados de los tres casos. El ejercicio no incluye explotación de CVE ni actividad contra servidores externos.

La [especificación](spec.md) recoge los criterios de aceptación y la [guía](README.md) describe el ejercicio.

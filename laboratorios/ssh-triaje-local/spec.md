# Especificación del laboratorio de triaje SSH

Alcance aprobado por Daniel Abanto el 12 de noviembre de 2026. El ejercicio genera registros reales de autenticación y documenta cómo priorizar tres secuencias de eventos. El servidor será OpenSSH Portable 8.5p1 en un contenedor Linux desechable en Windows con Docker Desktop.

## Alcance y controles

- Compilar la versión exacta desde la distribución oficial y comprobar su SHA-256 antes de extraerla.
- Publicar el puerto únicamente en `127.0.0.1:2222`. Usar un motor Docker 28 o posterior por el comportamiento de los puertos de loopback en versiones anteriores.
- Admitir una cuenta de práctica sin privilegios, deshabilitar el acceso de root y el reenvío SSH. Definir una contraseña desechable después de crear el contenedor. Generar la clave de host dentro del contenedor.
- Registrar la actividad de `sshd` en la salida de error del contenedor. Separar las ventanas de observación de los tres casos y sanear orígenes y huellas antes de publicar cualquier evidencia.
- Mantener el ejercicio en el equipo local. Para revertir, retirar el contenedor con `docker compose down`. Las evidencias que se exporten se conservan fuera del contenedor.

## Aceptación

| Criterio | Comprobación |
| --- | --- |
| Versión 8.5p1 e integridad de la fuente | Construir la imagen, comprobar la suma publicada y leer la identificación de versión del servidor. |
| Alcance local | Revisar el puerto publicado e intentar conectar por loopback. Confirmar que Docker solo lo enlaza a `127.0.0.1`. |
| Autenticación y trazabilidad | Ejecutar un fallo seguido de éxito, una ráfaga sin éxito y una ráfaga seguida de éxito. Verificar rechazos, sesión con usuario de práctica y eventos correspondientes. |
| Reversión | Bajar el contenedor y comprobar que se libera el puerto. |

## Tareas

- [x] Preparar imagen, configuración, inicio y controles de aislamiento. (delicada)
- [x] Documentar la ejecución, los intentos y la captura de evidencias. (mecánica)
- [x] Verificar versión, aislamiento, autenticación, registros y reversión. (delicada)

Consulta la [matriz de aceptación](evidencia.md).

Riesgo: punto 2 (autenticación por contraseña en un servidor histórico) y punto 5 (imagen Linux y dependencias de compilación).

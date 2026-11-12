# Revisión DevSecOps del laboratorio SSH

## Encargo

Revisión completa proporcional de la imagen Linux amd64 `ssh-triaje-local:8.5p1`, ID `sha256:837b30309d7e39b11e7847f72b1348b71f81dfb90744612388cc12dd8c6b3382`, y los archivos locales asociados sin revisión Git. Entorno comprobado por el implementador con Windows y Docker Engine Linux 29.9.2. Se aplicaron las skills `devsecops-review` y `secure-code-review` a la configuración, la compilación, los registros y la retirada del contenedor. Se usaron la [spec y sus tareas](../spec.md) y la evidencia inicial de etapa 4 (no publicada; la versión final está en [evidencia.md](../evidencia.md)).

Los activos pertinentes son el puerto publicado, la contraseña de práctica, la clave de host y los registros. Los límites de confianza son el acceso desde Windows al puerto loopback, el proceso de SSH frente a la cuenta de práctica y la transferencia de extractos a GitHub. La cuenta recibe su contraseña en el contenedor durante la práctica.

## Comprobaciones

| Área | Estado | Evidencia |
| --- | --- | --- |
| Exposición | Cumplido | Etapa 4 verificó el enlace a `127.0.0.1:2222` y el rechazo de las tres direcciones IPv4 no-loopback del host. `compose.yaml:8` fija el enlace y `README.md:15` comprueba la versión mínima del motor. [Docker](https://docs.docker.com/engine/network/port-publishing/) |
| Autenticación y cuenta | Cumplido | Etapa 4 verificó la cuenta inicial bloqueada, los rechazos y el acceso como `labssh`. `sshd_config:4` deniega root y limita usuarios. |
| Reenvío SSH | Fallido | Inspección de `sshd_config:10` y del código de la versión 8.5p1. Véase DSO-01. |
| Credenciales y clave de host | Cumplido | Inspección de `Dockerfile:25`, `start-sshd.sh:4`, `README.md:23` y archivos de exclusión. La clave se genera al iniciar y la contraseña se configura interactivamente. La búsqueda local dirigida de claves privadas, credenciales codificadas y tokens reconocibles no encontró coincidencias. |
| Procedencia y compilación | Cumplido | La base Debian fija un digest y el tarball upstream se valida por SHA-256 antes de extraer. Etapa 4 confirmó el checksum y el banner. Las versiones APT dependen del estado del repositorio en la fecha del build. |
| Dependencias y mitigación | Cumplido | Comparación con avisos oficiales aplicables a OpenSSH histórico. `LoginGraceTime 0` evita la condición de carrera de CVE-2024-6387 y deja posible la saturación de `MaxStartups`. El error de reenvío se registra como control independiente. [Avisos de OpenSSH](https://www.openssh.org/security.html) |
| Registros y evidencia | Cumplido | Etapa 4 mostró fallos y éxitos con fecha UTC, cuenta de práctica, IP sustituida y puertos redactados. `compose.yaml:13` utiliza el controlador local. Los originales se excluyen del contexto de build y del árbol Git previsto. |
| Retirada | Cumplido | Etapa 4 verificó el cierre del puerto tras `docker compose down` y el estado inicial de la cuenta tras recrear el contenedor. |
| Producción, alertas, restauración e IAM | No aplica | Ejercicio efímero en Docker local, con recreación documentada, sin infraestructura remota ni datos que requieran restauración. |
| Auditoría integral de paquetes Debian | No ejecutado | Se revisaron la procedencia, la fijación de la base y la versión solicitada. No se generó un inventario ni se ejecutó un escáner sobre la imagen. |

## Hallazgos

| ID | Título | Severidad | Prioridad | Confianza | Ubicación y evidencia |
| --- | --- | --- | --- | --- | --- |
| DSO-01 | La opción general deja permitido el reenvío de agente | Media | P1 | Confirmado en código | `sshd_config:10`. OpenSSH 7.4 a 9.9 interpreta `DisableForwarding` sin bloquear el reenvío de agente o X11. La versión 8.5p1 permite agente por defecto y X11 queda deshabilitado por su valor predeterminado. Un cliente autenticado que solicite reenvío de agente puede exponer a la sesión el acceso de firma de su agente. El cliente del README no lo solicita, lo que acota el impacto. La prioridad responde al compromiso explícito de desactivar reenvío en la spec. [Aviso de OpenSSH](https://www.openssh.org/security.html) · [Configuración predeterminada en 8.5p1](https://raw.githubusercontent.com/openssh/openssh-portable/V_8_5_P1/servconf.c) |

**Corrección y verificación de DSO-01.** Fijar `AllowAgentForwarding no` y `X11Forwarding no`. Comprobar los dos valores en `sshd -T` y, si se dispone de un cliente con agente efímero de prueba, solicitar el reenvío y comprobar que la sesión carece de `SSH_AUTH_SOCK`. Repetir una autenticación correcta para validar el recorrido.

## Veredicto

**No aprobado para esta versión.** DSO-01 incumple el criterio acordado de desactivar reenvío. La corrección conserva la versión 8.5p1 solicitada. El resto de las comprobaciones sostiene el uso efímero en el host y con la configuración evaluados.

## Límites

La revisión contrastó configuración y fuentes upstream con la evidencia de etapa 4. No se modificó la instancia ni se repitieron las comprobaciones dinámicas. No se probó desde otro equipo de la red, con un agente reenviado ni con un daemon Docker distinto del evaluado. La configuración deliberada mantiene una versión histórica y un riesgo de saturación de conexiones pendientes. El alcance comprende la práctica local y la preparación de evidencias saneadas para revisión.

Consultas de herramientas de revisión y registro: 6 llamadas.

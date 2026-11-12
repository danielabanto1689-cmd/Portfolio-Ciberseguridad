# Retest DevSecOps del reenvío SSH

## Encargo

Revisión dirigida del hallazgo DSO-01 del [informe inicial](devsecops-2026-11-12.md), según `devsecops-review` y `secure-code-review`. Se evaluó la imagen Linux amd64 `sha256:99e247eccec3839faa73e2fef507decadf8b8bb385cc7da747934918db379799` en Docker Engine Linux 29.9.2 sobre Windows, con los archivos locales del laboratorio.

## Comprobaciones

| Caso | Estado | Evidencia |
| --- | --- | --- |
| Desactivar de forma explícita el reenvío de agente y X11 | Cumplido | `sshd_config:11` fija `AllowAgentForwarding no` y `sshd_config:12` fija `X11Forwarding no`. La [verificación del implementador](../evidencia.md) confirmó ambos valores efectivos mediante `sshd -T`. |
| Rechazar la solicitud de reenvío de agente durante una sesión válida | Cumplido | Se solicitó el reenvío y `SSH_AUTH_SOCK` quedó vacío en los dos accesos correctos registrados en la evidencia de la versión evaluada. |
| Conservar el recorrido de autenticación y registros | Cumplido | La evidencia de la misma imagen confirma dos accesos válidos como `labssh`, once fallos registrados y la retirada del contenedor. |
| Aclarar el riesgo residual | Cumplido | El README enlaza el aviso de OpenSSH y explica que `LoginGraceTime 0` facilita la saturación de conexiones pendientes. [Aviso de OpenSSH](https://www.openssh.org/security.html) |

## Hallazgos

DSO-01 queda corregido. La configuración deja de depender exclusivamente de `DisableForwarding` para los controles afectados en la versión 8.5p1. La revisión dirigida no produjo hallazgos adicionales.

## Veredicto

**Aprobado** en el alcance DevSecOps del laboratorio local y efímero en la versión identificada.

## Límites

Se revisaron la configuración y la evidencia dinámica de etapa 4 sin volver a ejecutar la instancia. X11 se verificó mediante configuración efectiva. Sigue aplicando el alcance local del informe inicial, incluida la falta de una prueba desde otro equipo de la red y el riesgo residual de saturación del puerto.

Consultas de herramientas de revisión y registro: 2 llamadas.

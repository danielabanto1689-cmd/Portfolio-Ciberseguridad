# Verificación local del laboratorio SSH

Ejecución del 12 de noviembre de 2026 en Windows con Docker Engine Linux 29.9.2 y una imagen Linux amd64 `ssh-triaje-local:8.5p1` (`sha256:99e247eccec3839faa73e2fef507decadf8b8bb385cc7da747934918db379799`).

| Criterio | Comprobación | Entorno y versión | Resultado | Evidencia o límite |
| --- | --- | --- | --- | --- |
| Versión e integridad | Build con `sha256sum --check` y lectura del banner TCP | Docker Engine 29.9.2, OpenSSH Portable 8.5p1 | Cumplido | El tarball dio `OK`. El banner anuncia `SSH-2.0-OpenSSH_8.5`, tal como define el código de esa versión. |
| Alcance local | `docker compose port ssh 22` y conexiones TCP desde el host | Windows, Docker Engine 29.9.2 | Cumplido | Se conectó por `127.0.0.1:2222`. Fallaron las conexiones a las tres direcciones IPv4 del host fuera de loopback. No se probó desde otro equipo de la red. |
| Configuración efectiva | `sshd -T` y `passwd -S labssh` | OpenSSH Portable 8.5p1 | Cumplido | Usuario inicial bloqueado, acceso de root denegado, solo `labssh` admitido y reenvío general, de agente y de X11 desactivados según la configuración efectiva. Una solicitud real de reenvío de agente dejó `SSH_AUTH_SOCK` vacío en ambos accesos correctos. X11 se comprobó por configuración. |
| Autenticación y registro | Negociación con cliente OpenSSH de Windows, autenticaciones con Paramiko y `docker compose logs` | OpenSSH para Windows 9.5p2, servidor 8.5p1 | Cumplido | El cliente Windows negoció con la clave Ed25519 verificada. Paramiko comprobó los rechazos y los dos éxitos, que devolvieron `labssh` mediante `id -un`. La [prueba manual posterior](#prueba-manual-con-openssh-para-windows) verificó la entrada interactiva de la contraseña. |
| Reversión | `docker compose down` y conexión TCP posterior | Docker Engine 29.9.2 | Cumplido | El puerto se cerró. Se recreó el laboratorio y se comprobó que `labssh` volvió a quedar bloqueado hasta definir la contraseña. |

## Extractos de los registros

Proceden de la ejecución automatizada con Paramiko, por eso los intentos de cada caso están separados por 50 a 100 ms. Se conservan los timestamps UTC y el orden de los eventos. La IP de origen se sustituyó por `192.0.2.10` y los puertos de origen se redactaron. Los intentos de cada caso se delimitaron con ventanas independientes.

### Caso A

```text
2026-11-12T15:38:44.603596701Z Failed password for labssh from 192.0.2.10 port <redactado> ssh2
2026-11-12T15:38:44.659250618Z Accepted password for labssh from 192.0.2.10 port <redactado> ssh2
```

### Caso B

```text
2026-11-12T15:38:45.503219819Z Failed password for labssh from 192.0.2.10 port <redactado> ssh2
2026-11-12T15:38:45.590342697Z Failed password for labssh from 192.0.2.10 port <redactado> ssh2
2026-11-12T15:38:45.663441141Z Failed password for labssh from 192.0.2.10 port <redactado> ssh2
2026-11-12T15:38:45.761144495Z Failed password for labssh from 192.0.2.10 port <redactado> ssh2
2026-11-12T15:38:45.845958405Z Failed password for labssh from 192.0.2.10 port <redactado> ssh2
```

### Caso C

```text
2026-11-12T15:38:46.553139260Z Failed password for labssh from 192.0.2.10 port <redactado> ssh2
2026-11-12T15:38:46.609634047Z Failed password for labssh from 192.0.2.10 port <redactado> ssh2
2026-11-12T15:38:46.679041257Z Failed password for labssh from 192.0.2.10 port <redactado> ssh2
2026-11-12T15:38:46.728208622Z Failed password for labssh from 192.0.2.10 port <redactado> ssh2
2026-11-12T15:38:46.780466189Z Failed password for labssh from 192.0.2.10 port <redactado> ssh2
2026-11-12T15:38:46.855521273Z Accepted password for labssh from 192.0.2.10 port <redactado> ssh2
```

En A hubo un fallo y un acceso correcto. En B se registraron cinco rechazos. En C hubo cinco rechazos y un acceso correcto, la secuencia que conviene priorizar en un triaje. Los accesos exitosos estaban autorizados y los registros no permiten determinar por sí solos quién usó la cuenta.

## Prueba manual con OpenSSH para Windows

Repetí el ejercicio a mano desde PowerShell. Los accesos válidos devolvieron `labssh` al ejecutar `id -un`. La comprobación manual del cliente de Windows quedó completada con la salida de terminal y los eventos de autenticación del servidor.

| Caso | Resultado observado | Ventana UTC del 12 de noviembre de 2026 |
| --- | --- | --- |
| A | Dos fallos y luego un acceso correcto. | `21:13:33` a `21:15:47` |
| B | Cinco fallos y cero accesos correctos en la ráfaga. | `21:18:11` a `21:18:18` |
| C | Cinco fallos y luego un acceso correcto para `labssh`, todos desde el mismo origen observado. | `21:19:59` a `21:20:14` (15,3 segundos) |

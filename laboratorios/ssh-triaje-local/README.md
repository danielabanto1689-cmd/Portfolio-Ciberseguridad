# Triaje SOC de intentos de acceso SSH

Laboratorio local para generar eventos reales de OpenSSH Portable **8.5p1** e investigar tres secuencias de autenticación. El servidor escucha en `127.0.0.1:2222` y el cliente se ejecuta en Windows.

## En resumen

- **Objetivo:** generar registros reales de autenticación con tres secuencias y distinguir cuál justifica investigar un posible acceso no autorizado.
- **Resultado:** A, un fallo y un acceso correcto; B, cinco fallos sin acceso; C, cinco fallos seguidos de un acceso correcto para la misma cuenta y desde el mismo origen, la secuencia que conviene priorizar. Los registros no permiten determinar por sí solos quién usó la cuenta.
- **Hallazgo durante el montaje:** la revisión de seguridad del laboratorio detectó que `DisableForwarding yes` no bloqueaba el reenvío de agente en OpenSSH 8.5p1. Se corrigió fijando `AllowAgentForwarding no` y `X11Forwarding no`, y se verificó con una solicitud real de reenvío: las sesiones válidas quedaron sin `SSH_AUTH_SOCK`. Detalle en el [informe DevSecOps](reportes/devsecops-2026-11-12.md) y su [retest](reportes/devsecops-2026-11-12-retest.md).
- **Triaje:** [ficha del caso C](triaje.md), con hechos, hipótesis, prioridad P2, clasificación como verdadero positivo benigno, criterios de escalado y regla de detección.
- **Evidencia:** [matriz de verificación y extractos saneados](evidencia.md).

## Preparación

Requisitos: Docker Desktop con motor Linux 28 o posterior, Docker Compose, PowerShell 7 y un cliente `ssh` compatible con Ed25519. El build verifica el SHA-256 oficial y compila con `--without-openssl`. OpenSSH 8.5p1 es una versión histórica afectada por CVE-2024-6387. El laboratorio aplica la mitigación `LoginGraceTime 0`, que facilita la saturación de conexiones pendientes, y deshabilita explícitamente el reenvío del agente y de X11. Mantén el ejercicio en loopback. [Notas de OpenSSH 8.5](https://www.openssh.org/txt/release-8.5) · [Avisos de seguridad de OpenSSH](https://www.openssh.org/security.html) · [Puertos publicados de Docker](https://docs.docker.com/engine/network/port-publishing/)

Desde esta carpeta:

```powershell
if ((docker context show) -ne 'desktop-linux' -or $env:DOCKER_HOST) {
    throw 'Usa el contexto Linux local de Docker Desktop sin sobrescribir DOCKER_HOST.'
}
$engineVersion = docker version --format '{{.Server.Version}}'
if ($LASTEXITCODE -ne 0) { throw 'Inicia primero el motor Linux de Docker Desktop.' }
if ([int]($engineVersion.Split('.')[0]) -lt 28) { throw 'Se requiere Docker Engine 28 o posterior.' }
docker compose up -d --build
docker compose port ssh 22
docker compose exec ssh ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub
```

Verifica que `docker compose port` muestre `127.0.0.1:2222`. Define una contraseña desechable con caracteres ASCII para `labssh`. `passwd` te la pedirá de forma interactiva.

```powershell
docker compose exec ssh passwd labssh
```

## Generar y observar eventos

En la primera conexión, acepta la clave solo si la huella presentada por `ssh` coincide con la salida de `ssh-keygen` obtenida arriba. El comando usa un archivo `known_hosts` exclusivo del laboratorio. Al recrear el contenedor, comprueba la huella nueva y elimina la entrada anterior con `ssh-keygen -R '[127.0.0.1]:2222' -f ./.known_hosts`.

```powershell
function Invoke-LabSsh {
    ssh -F none -p 2222 -o UserKnownHostsFile=./.known_hosts `
        -o PreferredAuthentications=password -o NumberOfPasswordPrompts=1 `
        labssh@127.0.0.1 id
}
```

Antes de cada caso, toma el inicio UTC desde el contenedor para usar el mismo reloj que los registros. Ejecuta `Invoke-LabSsh` una vez por intento y escribe la contraseña en el prompt. Cada acceso correcto ejecuta `id`, que debe mostrar la cuenta `labssh`. Consulta la ventana de cada caso antes de iniciar el siguiente.

```powershell
$inicio = (docker compose exec -T ssh date -u +%Y-%m-%dT%H:%M:%S.%NZ).Trim()
```

| Caso | Intentos en orden | Evidencia esperada |
| --- | --- | --- |
| A. Error legítimo simulado | Un fallo y un éxito | `Failed password` y después `Accepted password` para `labssh`. |
| B. Ráfaga sin acceso | Cinco fallos en menos de un minuto | Cinco `Failed password`. Ningún `Accepted password` en esa ventana. |
| C. Ráfaga seguida de acceso | Cinco fallos y un éxito en menos de un minuto | Cinco `Failed password` y después `Accepted password` para la misma cuenta. |

```powershell
docker compose logs --timestamps --since $inicio ssh
```

Cuenta solo `Failed password` y `Accepted password`. Un error de conexión o de huella ocurre antes de la autenticación. Correlaciona por servidor, cuenta, origen y tiempo. Docker Desktop puede mostrar la IP del intermediario de red en los registros del contenedor. Los casos A y C son sesiones autorizadas en este ejercicio. En un caso real, la secuencia C justifica comprobar quién accedió y qué hizo después. [Estrategia de detección de MITRE ATT&CK](https://attack.mitre.org/detectionstrategies/DET0551/)

## Evidencia y cierre

Consulta la [verificación y los extractos saneados](evidencia.md) de una ejecución local. La carpeta `reportes/` incluye la revisión DevSecOps del propio laboratorio y su retest.

Antes de compartir resultados, conserva los timestamps y resultados necesarios para reconstruir cada caso. Sustituye IP de origen y huellas por valores ficticios de forma consistente. Guarda los registros sin sanear en `evidencia-local/`, que Git ignora.

```powershell
docker compose down
```

Para comprobar el cierre, intenta conectar otra vez a `127.0.0.1:2222`. El contenedor se recrea con una clave de host nueva y la cuenta bloqueada hasta volver a definir su contraseña.

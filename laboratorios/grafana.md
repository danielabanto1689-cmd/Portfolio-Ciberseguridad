# Grafana: exposición de métricas y retest

**HomeNet · 28–31 de octubre de 2026 · Evaluación externa documentada**

Evaluación de rutas HTTP de Grafana sin credenciales en un laboratorio autorizado. El ejercicio recorre descubrimiento, comunicación al administrador y comprobación posterior de la corrección.

## Objetivo y método

Comprobar qué recursos respondían sin sesión a través de un proxy inverso. Se compararon códigos HTTP y tamaños de respuesta mediante curl. Las comprobaciones de red complementarias se limitaron al origen de prueba. No se ejecutó explotación de CVE, fuerza bruta ni cambios administrativos.

## Resultados documentados

| Comprobación | Resultado inicial | Comprobación posterior |
| --- | --- | --- |
| `GET /metrics`, sin sesión | HTTP 200; 1.318.774 bytes, 28 de octubre | HTTP 404; 162 bytes, 31 de octubre |
| `GET /api/health` | HTTP 200; versión y estado básico | HTTP 200 en el retest |
| APIs privadas consultadas | HTTP 401 | Sin bypass documentado |
| Ruta raíz | Redirección al login | HTTP 302 |

La ruta de métricas dejó de estar accesible desde el punto de prueba tras la corrección comunicada por el administrador. No se verificó el mecanismo interno ni el acceso desde otras redes.

## Evidencia disponible

Esta tabla transcribe los resultados del informe del operador. **No se adjuntan respuestas HTTP originales ni capturas del ejercicio.** Los tamaños y estados no fueron medidos nuevamente durante la preparación del portfolio. No se conserva ni publica el cuerpo de las métricas.

El informe también registra respuestas 401 para `/api/frontend/settings`, `/api/plugins`, `/api/search`, `/api/dashboards/home`, `/api/user` y `/api/v1/provisioning/contact-points`. Son controles observados para esas solicitudes anónimas, sin evaluación de roles autenticados.

## Interpretación y límites

El acceso a métricas puede divulgar información operativa. Su contenido no se analizó exhaustivamente: **no se confirmó exposición de contraseñas, tokens ni datos personales**. La respuesta de salud se clasificó como informativa. Un HTTP 200 ante un encabezado Origin externo no demuestra por sí mismo una política CORS insegura.

No se confirmó acceso a paneles internos, bypass de autenticación, ejecución remota de código ni explotación de vulnerabilidades conocidas. La mitigación está documentada únicamente desde el acceso utilizado.

## Reproducción en un entorno propio

Ejemplo para un servidor de pruebas bajo control del lector. Sustituir la URL por un destino autorizado; no dirige tráfico a HomeNet.

```bash
curl --silent --show-error --connect-timeout 5 --max-time 15 \
  --output /dev/null \
  --write-out 'HTTP: %{http_code}\nBytes: %{size_download}\n' \
  https://grafana.example.invalid/metrics
```

## Aprendizajes y seguimiento

Separar exposición potencial de impacto confirmado; registrar antes y después; verificar una remediación desde el mismo origen. Como seguimiento, revisar restricciones de métricas y repetir controles desde otras ubicaciones autorizadas.

**Procedencia:** versión pública saneada del informe de Grafana aportado por Daniel. Se omiten direcciones, hosts y arquitectura interna. Evidencia original pendiente de incorporación tras revisión de privacidad.

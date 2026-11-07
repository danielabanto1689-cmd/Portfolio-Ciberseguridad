# OpenSearch Dashboards: autenticación y superficie HTTP

**HomeNet · 1 de noviembre de 2026, según reloj de Kali (UTC+01:00) · Evaluación de caja negra**

Revisión sin credenciales del Dashboard Wazuh basado en OpenSearch Dashboards: rutas privadas, estadísticas públicas, cabeceras y redirecciones.

## Objetivo y método

Determinar qué información era visible sin sesión y comprobar los controles de autenticación de las rutas seleccionadas. Se utilizaron solicitudes GET/HEAD, lectura de HTML público y comprobaciones TCP acotadas. No se realizaron escrituras, fuerza bruta ni pruebas de interrupción.

## Evidencia documental

| Recurso o prueba | Respuesta registrada | Interpretación |
| --- | --- | --- |
| `/app/login` | HTTP 200; 114.197 bytes de HTML | Página pública de acceso |
| `/app/wazuh`, `/app/management`, `/app/discover` | HTTP 302 hacia login | Autenticación exigida en esas rutas |
| `/api/status` y consultas de objetos guardados | HTTP 401 | Sin lectura anónima demostrada |
| `/api/reporting/stats` | HTTP 200; 1.252 bytes | Contadores; ruta declarada como excepción pública |
| Estadísticas con Origin externo | Sin cabeceras `Access-Control-Allow-*` en la respuesta examinada | CORS inseguro no demostrado |
| Dos rutas malformadas | HTTP 401; sin redirección externa | Open redirect no observado en esas variantes |

**Procedencia:** transcripción resumida del informe de Dashboard aportado por Daniel y contrastada con su consolidado. Los archivos originales de curl, HTML y Nmap permanecen referenciados por el operador, pero **no están adjuntos al portfolio**. No se repitieron solicitudes para redactar esta ficha.

## Cabeceras y configuración

En las respuestas examinadas, la CSP incluía `unsafe-eval` para scripts y `unsafe-inline` para estilos. No apareció HSTS en los GET/HEAD comprobados. Son observaciones de endurecimiento, **sin XSS ni compromiso demostrado**. Las cookies observadas correspondían a instrucciones de eliminación; no permiten evaluar una sesión válida.

El HTML identificó plugins de seguridad y gestión de fuentes de datos. La configuración `manageableBy: "all"` no acredita permisos anónimos: las búsquedas de objetos privados consultadas devolvieron 401. La funcionalidad efectiva y los permisos requieren evaluación autenticada.

## Conclusión y límites

No se logró acceso administrativo anónimo ni extracción de datos privados. Las estadísticas accesibles contenían contadores, sin credenciales ni registros individuales detectados en la estructura descrita.

Los controles funcionaron en las rutas comprobadas; esto no acredita toda la aplicación. No se evaluaron RBAC, sesiones autenticadas ni configuración efectiva del backend. La identificación de versiones no equivale a explotación de una CVE. Las conexiones directas al backend probado resultaron filtradas desde el origen del ejercicio, sin demostrar qué dispositivo aplicaba el filtro.

## Recomendaciones y aprendizajes

Revisar CSP y HSTS con pruebas de compatibilidad, conservar la segmentación y los controles 401/302, revisar la necesidad de estadísticas públicas y evaluar RBAC con cuentas autorizadas. Distinguir metadatos visibles, excepciones intencionales y vulnerabilidades demostradas evita sobrevalorar un hallazgo.

**Versión pública saneada:** omite direcciones, hosts, topología y datos de acceso. No incluye PoC de disponibilidad ni afirmaciones de CVE explotadas. Evidencia original pendiente de incorporación tras revisión de privacidad.

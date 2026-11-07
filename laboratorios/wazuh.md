# Wazuh: enrolamiento de agentes y límites de confianza

**HomeNet · 1 de noviembre de 2026, según reloj de Kali (UTC+01:00) · Resultado documentado, política de admisión pendiente de validar**

Evaluación del registro de agentes desde una ubicación de pruebas autorizada. Dos solicitudes obtuvieron material de enrolamiento sin aportar contraseña adicional; una identidad estableció después comunicación por el canal de agentes.

## Objetivo y alcance

Comprobar el comportamiento del enrolamiento y distinguir alta de identidad, comunicación con el servidor y procesamiento de eventos. El cliente utilizado fue un agente Wazuh ejecutado en Kali. No se contó con acceso administrativo al manager ni al Dashboard.

## Evidencia disponible

| ID | Observación recogida en el consolidado | Qué permite concluir |
| --- | --- | --- |
| E-01 | Dos solicitudes sin contraseña adicional recibieron una clave | Entrega de material de enrolamiento desde el origen probado |
| E-02 | Un agente registró conexión al servidor y recarga por cambios compartidos | Comunicación y procesamiento local de una indicación de configuración |
| E-03 | Comparación local de 23 nombres y tamaños frente al índice compartido: 23 coincidencias, 0 errores | Consistencia de nombres/tamaños; no igualdad byte a byte ni procedencia remota acreditada |
| E-04 | Canal de agentes y registro accesibles en el frontal; API administrativa directa filtrada | Alcance de red limitado a las conexiones comprobadas |

El consolidado contiene extractos de logs normalizados, no líneas originales íntegras. Esta ficha los resume como **evidencia documental del operador**, sin presentarlos como una nueva captura. Los logs completos y archivos compartidos de Kali no se adjuntaron; sus hashes declarados no se pudieron verificar sobre los archivos originales y no se reproducen como prueba independiente.

## Interpretación

El resultado demuestra enrolamiento sin contraseña adicional desde una ubicación concreta; **no demuestra ausencia de todos los controles ni una vulnerabilidad de producto**. Para determinar si existe un fallo de configuración debe comprobarse si ese origen estaba autorizado a registrar agentes y qué controles compensatorios existían.

Si clientes no previstos alcanzan el servicio y pueden registrarse, podrían incorporar identidades o telemetría no confiable. Ese impacto sigue condicionado a la política efectiva y a la recepción de eventos en el manager.

## Lo que no se demostró

- Dos agentes activos simultáneamente o estado Active confirmado en Dashboard.
- Eventos de seguridad procesados e indexados por el manager; un keepalive no lo prueba.
- Lectura de datos de otros agentes, acceso SSH/API administrativa o ejecución remota de código.
- Interrupción del servicio o explotación de CVE.

El informe propone prioridad media condicionada a la política de admisión. No se asigna CVSS definitivo ni se presenta ese nivel como una vulnerabilidad confirmada del fabricante.

## Seguimiento recomendado

Confirmar política y configuración de enrolamiento del manager; restringir orígenes o usar autenticación adicional cuando el diseño lo requiera. Validar con el administrador el estado de las identidades de prueba y su limpieza, y obtener una exportación saneada del manager que acredite recepción de eventos si se amplía el ejercicio.

No se incluyen comandos de alta: repetir el registro crearía nuevas identidades y no es necesario para revisar esta evidencia. La preparación del portfolio no ejecutó operaciones sobre HomeNet.

## Aprendizajes

Separar registro, conexión y telemetría evita inferencias de impacto sin respaldo. La evaluación de una configuración depende del modelo de confianza, no solo de que una opción permita conexión.

**Procedencia:** versión pública saneada del informe consolidado Wazuh aportado por Daniel. Se omiten claves, nombres/ID de agentes, direcciones, hosts, rutas personales y arquitectura interna. Evidencia original pendiente de incorporación tras revisión de privacidad.

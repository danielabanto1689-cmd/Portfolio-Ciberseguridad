# Portfolio de Ciberseguridad · Daniel Abanto

Documentación de mis laboratorios de ciberseguridad: análisis de exposición, controles de autenticación y límites de confianza, con enfoque en detección, análisis y respuesta para operaciones SOC.

Cada caso presenta el objetivo, el método, los resultados documentados, su interpretación y los aprendizajes. Los ejercicios se realizaron en un entorno de laboratorio autorizado; no representan incidentes de clientes ni experiencia laboral.

## Laboratorios documentados

| Laboratorio | Enfoque | Resultado y alcance |
| --- | --- | --- |
| [Grafana: exposición de métricas y retest](laboratorios/grafana.md) | Acceso HTTP sin sesión y comprobación posterior | `/metrics` pasó de HTTP 200 a 404 desde el origen de prueba. No se verificó el mecanismo interno de la corrección. |
| [OpenSearch Dashboards: autenticación y superficie HTTP](laboratorios/opensearch.md) | Rutas privadas, estadísticas públicas y cabeceras | Las rutas privadas comprobadas exigieron autenticación mediante 401/302; se documentaron excepciones públicas y oportunidades de endurecimiento. |
| [Wazuh: enrolamiento de agentes y límites de confianza](laboratorios/wazuh.md) | Registro, comunicación y política de admisión | Se documentó entrega de material de enrolamiento y comunicación de una identidad. La política de admisión y la recepción de eventos en el manager siguen pendientes de validar. |

## Herramientas y prácticas

- Grafana, OpenSearch Dashboards y Wazuh como tecnologías evaluadas.
- Kali Linux, curl y Nmap como herramientas descritas en los informes.
- Comparación de respuestas HTTP, revisión de autenticación y análisis de evidencia documental.
- Distinción entre exposición potencial, impacto confirmado y verificaciones pendientes.

## Evidencia y limitaciones

Los informes publicados son versiones saneadas de la documentación aportada por el operador del laboratorio. **Los archivos originales de las pruebas —capturas, respuestas HTTP, logs y anexos de Kali— no están adjuntos a este repositorio.**

Los resultados se presentan como evidencia documental; no se repitieron las pruebas para preparar esta publicación. La ausencia de un hallazgo en las solicitudes examinadas no acredita la seguridad de todo el sistema. El enrolamiento de un agente no demuestra por sí solo recepción ni indexación de eventos, ni una vulnerabilidad del producto.

## Privacidad y uso responsable

Se omiten direcciones, hosts internos, topología concreta, identidades de agentes, rutas personales y material de acceso. No se publican claves, cookies, cuerpos de métricas ni originales privados.

Los ejemplos solo deben utilizarse en sistemas propios o con autorización expresa. El ejemplo de Grafana usa un dominio reservado `.invalid`; no apunta al entorno del ejercicio. El informe Wazuh no incluye comandos de alta porque crearían nuevas identidades.

## Organización

```text
laboratorios/
├── grafana.md
├── opensearch.md
└── wazuh.md
```

Este repositorio reúne el material técnico de los laboratorios. El código de la página web del portfolio se mantiene por separado.

## Próximos pasos

- Incorporar anexos originales únicamente después de revisar su privacidad y procedencia.
- Ampliar cada caso con las verificaciones pendientes indicadas en su informe.
- Añadir nuevos laboratorios cuando cuenten con documentación propia y resultados comprobables.

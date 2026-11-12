# Triaje del caso C: ráfaga de fallos seguida de un acceso

Ficha de triaje escrita como lo haría un analista SOC L1 al recibir la alerta. Se basa en los registros de [evidencia.md](evidencia.md#caso-c).

## 1. Hechos observados

- Se registraron 5 `Failed password` y 1 `Accepted password`.
- Todos los eventos corresponden a la misma cuenta, `labssh`, y al mismo origen.
- El acceso correcto ocurrió después de los 5 fallos.
- La secuencia completa duró 0,3 segundos.

## 2. Hipótesis

Seis intentos en 0,3 segundos no los teclea una persona: la secuencia fue automatizada. Descarto que un usuario se equivocara al escribir.

- **Maliciosa:** fuerza bruta, adivinación de contraseñas contra la cuenta `labssh`, que terminó con éxito.
- **Benigna:** una prueba autorizada con una herramienta de automatización; el script probó varias claves guardadas hasta dar con la correcta.

## 3. Veredicto y prioridad

**Prioridad al abrir el caso: P2 (alta)**, porque hubo un acceso exitoso sin confirmar. El caso B, con fallos y sin acceso, quedaría en P3.

Escala usada: P1, compromiso confirmado o acceso no autorizado en curso; P2, acceso exitoso sospechoso sin confirmar; P3, intentos fallidos sin acceso; P4, evento aislado o informativo.

**Resolución (escenario simulado):** el responsable de la cuenta confirma que el acceso formaba parte de una prueba autorizada, y la IP de origen pertenece al rango asignado a su VLAN. En este laboratorio no hay VLAN ni inventario de IP: el origen real es el intermediario de red de Docker Desktop, sustituido por `192.0.2.10` al sanear. La resolución ilustra cómo se cerraría el caso; no es una comprobación ejecutada.

**Clasificación: verdadero positivo benigno.** El patrón de ráfaga seguida de acceso sí ocurrió, pero la actividad estaba autorizada. La regla funcionó como se esperaba y no necesita corrección.

## 4. Siguientes pasos

1. Confirmar con el responsable de la cuenta si autorizó la prueba.
2. Comprobar si la IP de origen pertenece a un equipo conocido, de prueba o de administración.
3. Revisar qué se hizo en la sesión tras el acceso: comandos, conexiones salientes y cambios en la cuenta.

**Escalar a nivel 2** si ocurre cualquiera de estas condiciones:

- El responsable niega la prueba o no responde dentro del plazo acordado.
- El origen es desconocido o externo a los rangos permitidos.
- La sesión muestra actividad distinta de la prueba: descarga de herramientas, cambios de credenciales, persistencia o movimiento hacia otros equipos.

Si se escala, el caso pasa a P1 y se recomienda contener: bloquear la cuenta o el origen y rotar la contraseña.

## 5. Regla de detección

```text
SI en una ventana de 60 segundos, para la misma cuenta y el mismo origen:
   hay 5 o más eventos «Failed password»
   Y a continuación un «Accepted password»
ENTONCES alerta P2: posible acceso tras fuerza bruta (MITRE ATT&CK T1110.001)
```

| Caso | Eventos | ¿Dispara? | Motivo |
| --- | --- | --- | --- |
| A | 1 fallo y 1 acceso | No | No llega a 5 fallos |
| B | 5 fallos, sin acceso | No | Falta el acceso posterior; otra regla de umbral podría registrarlo como P3 |
| C | 5 fallos y 1 acceso en 0,3 s | Sí | Cumple umbral, ventana, cuenta, origen y orden |

**Señal adicional:** si los intentos están separados por menos de un segundo, la secuencia es automatizada. No cambia la prioridad, pero orienta las hipótesis.

---

*Nota de elaboración: las secciones 1 a 3 recogen mi análisis durante una sesión guiada. Los criterios de escalado y la regla de detección se redactaron con asistencia de IA a partir de esas conclusiones.*

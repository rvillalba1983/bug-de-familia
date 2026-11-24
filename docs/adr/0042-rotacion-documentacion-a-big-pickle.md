# ADR 0042: rotación de `documentacion` a `big-pickle` por cuota mensual de Go (23-nov)

Estado: aplicado el 23-nov-2026 durante la fase
`fase/cierre-consistencia-mundo-completo`. Tarea relanzada desde cero.

## Contexto

El primer intento de esta tarea de documentación falló con este error literal:

> OpenCode Go monthly usage limit reached. Switch to a free model, or turn on
> Extra Usage on the Go page in OpenCode Console to keep going.

El modelo configurado para `documentacion` era `opencode-go/glm-5.3-flash`
(alternativo 1 desde el 19-nov, cuando se retiró `opencode/glm-5.3-flash-free`).
Como en el ADR 0040, el mensaje indica agotamiento de la cuota mensual global
de la suscripción Go, no de la ventana de un modelo concreto. Por tanto, el
siguiente alternativo de la cadena, `opencode-go/gpt-6-luna`, también es de Go
y habría fallado igual. Extra Usage sigue desactivado por decisión del
director, para no pasar de 10 $/mes.

## Decisión

Aplicar el paso 2 del procedimiento de fallback de `FALLBACK_MODELS.md`: antes
de tocar otro modelo de pago, usar los gratuitos que queden en la cadena:

1. `opencode/glm-5.3-flash-free` (retirado el 19-nov).
2. `opencode-go/glm-5.3-flash` (agotado el 23-nov).
3. `opencode/big-pickle` (elegido).
4. `opencode-go/gpt-6-luna` (no probado: también de Go).

Comando ejecutado:

```
python tools/cambiar_modelo.py --rotar documentacion
```

Salida literal:

```
ROTADO documentacion: opencode-go/glm-5.3-flash -> opencode/big-pickle
```

El script edita solo la línea `model` de `opencode.jsonc`. La tarea fallida se
relanzó desde cero con el modelo nuevo: OpenCode V2 no reintenta la petición
que murió (ADR 0020).

## Consecuencias

- `documentacion` trabaja temporalmente con `big-pickle`. Al renovarse la cuota
  de Go se puede volver con
  `python tools/cambiar_modelo.py --restaurar documentacion`, que recupera el
  principal de la cadena (`opencode/glm-5.3-flash-free`).
- `big-pickle` puede usar las conversaciones para mejorar el modelo durante el
  periodo gratuito. Esta tarea solo edita documentación del repositorio; no se
  envían recursos nuevos a servicios externos.
- No se activa Extra Usage.
- No se cambia la cadena de `tools/modelos_agentes.json`: sigue siendo la
  fuente única de verdad y el estado se consulta con `--estado`.
- Se actualizan `FALLBACK_MODELS.md` y `CONFIG_AGENTS.md`. No se ejecutó
  `--validar` en este turno (alcance solo de documentación).

## Referencias

- `FALLBACK_MODELS.md`, procedimiento de cambio, pasos 2 a 5.
- `docs/adr/0040-rotacion-ingeniero-godot-a-big-pickle.md`: misma causa, otro
  agente, 22-nov.
- `docs/adr/0020-tres-modelos-por-agente.md`: tres modelos por agente y
  relanzamiento de la tarea.
- `docs/adr/0022-rotacion-explore-a-go.md`: rotación anterior por decisión del
  director.
- `docs/adr/0036-culling-rigs-fuera-de-camara.md`: rotación del 19-nov de
  `documentacion` por modelo retirado.

# ADR 0040: rotación de `ingeniero-godot` a `big-pickle` por agotamiento de la cuota mensual de Go (22-nov)

Estado: aplicado el 22-nov-2026 durante la fase «Mundo completo: mapa y consecuencias».
Tarea relanzada con el modelo nuevo.

## Contexto

Al lanzar la implementación del ADR 0039, el subagente `ingeniero-godot` devolvió
este error literal:

> OpenCode Go monthly usage limit reached. Switch to a free model, or turn on
> Extra Usage on the Go page in OpenCode Console to keep going.

El modelo configurado era `opencode-go/deepseek-v4.1-flash` (confirmado con
`python tools/cambiar_modelo.py --estado`). El mensaje indica agotamiento de la
**cuota mensual global de la suscripción Go**, no de la ventana de un modelo
concreto. Por tanto, el siguiente alternativo de la cadena,
`opencode-go/kimi-k2.7-code`, también es de Go y habría fallado igual. Extra
Usage sigue desactivado por decisión del director, para no pasar de 10 $/mes.

## Decisión

Aplicar el paso 2 del procedimiento de fallback de `FALLBACK_MODELS.md`: antes
de tocar otro modelo de pago, probar los gratuitos que queden. Se eligió
`opencode/big-pickle`, el primer modelo gratuito de la cadena del agente en
`tools/modelos_agentes.json` (fuente única de verdad):

```
deepseek-v4.1-flash > kimi-k2.7-code > big-pickle > glm-5.3
```

Comandos ejecutados:

```
python tools/cambiar_modelo.py --usar ingeniero-godot opencode/big-pickle
python tools/cambiar_modelo.py --validar
```

El segundo devolvió `OK: 11 agentes, 1 principal + 3 alternativos, 0 errores`.
La tarea fallida **se relanzó desde cero** con el modelo nuevo: OpenCode V2 no
reintenta la petición que murió (ADR 0020).

## Consecuencias

- `ingeniero-godot` trabaja temporalmente con `big-pickle`. Al renovarse la
  cuota de Go se puede volver con
  `python tools/cambiar_modelo.py --restaurar ingeniero-godot`, que recupera el
  principal de la cadena (`deepseek-v4.1-flash`).
- `big-pickle` puede usar las conversaciones para mejorar el modelo durante el
  periodo gratuito. La tarea en curso es código GDScript del propio repositorio;
  no se envían recursos nuevos a servicios externos.
- Se actualizan `FALLBACK_MODELS.md` y `CONFIG_AGENTS.md`.
- No se activa Extra Usage y no se cambia la cadena de
  `tools/modelos_agentes.json`.

## Referencias

- `FALLBACK_MODELS.md`, procedimiento de cambio, pasos 2 a 5.
- `adr/0020-tres-modelos-por-agente.md`.
- `adr/0022-rotacion-explore-a-go.md` (rotación anterior, por decisión del
  director y por retirada de un modelo, no por cuota).

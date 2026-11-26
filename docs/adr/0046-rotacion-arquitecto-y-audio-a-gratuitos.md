# ADR 0046: rotación de `arquitecto` y `audio` a modelos gratuitos por agotamiento de Go (26-nov)

Addendum 26-nov: `opencode/glm-5.3-flash-free` devolvió `Model unavailable:
opencode/glm-5.3-flash-free`, así que `audio` se rotó una segunda vez a
`opencode/big-pickle` y la tarea se relanzó de nuevo.

Estado: aplicado el 26-nov-2026 durante la fase «Música en las 24 zonas».
Tareas relanzadas con los modelos nuevos.

## Contexto

Al lanzar el diseño de la integración de `MusicDirector` en las 24 zonas, el
subagente `arquitecto` devolvió este error literal:

> OpenCode Go monthly usage limit reached. Switch to a free model, or turn on
> Extra Usage on the Go page in OpenCode Console to keep going.

`python tools/cambiar_modelo.py --estado` confirmó que su modelo activo era
`opencode-go/glm-5.3` y que el de `audio` era `opencode-go/glm-5.3-flash`.
Como en ADR 0040 y 0042, el mensaje indica agotamiento de la **cuota mensual
global de la suscripción Go**, no de la ventana de un modelo concreto: saltar
al siguiente alternativo de Go habría fallado igual. Extra Usage sigue
desactivado por decisión del director, para no pasar de 10 $/mes.

## Decisión

Aplicar el procedimiento de `FALLBACK_MODELS.md`: antes de tocar otro modelo de
pago, usar los gratuitos de la cadena de cada agente en
`tools/modelos_agentes.json` (fuente única de verdad).

```
arquitecto: glm-5.3 > big-pickle > kimi-k2.7-code > glm-5.3-flash-free
audio:      glm-5.3-flash > glm-5.3-flash-free > big-pickle > beam-free
```

Comandos ejecutados:

```
python tools/cambiar_modelo.py --rotar arquitecto
python tools/cambiar_modelo.py --rotar audio
python tools/cambiar_modelo.py --validar
python tools/cambiar_modelo.py --rotar audio
python tools/cambiar_modelo.py --validar
```

El primer modelo gratuito de `audio` (`glm-5.3-flash-free`) estaba retirado;
se aplicó `--rotar` una segunda vez para pasar a `big-pickle`.

El último devolvió `OK: 11 agentes, 1 principal + 3 alternativos, 0 errores`.
Las tareas fallidas **se relanzaron desde cero** con los modelos nuevos:
OpenCode V2 no reintenta la petición que murió (ADR 0020).

## Consecuencias

- `arquitecto` trabaja temporalmente con `opencode/big-pickle` y `audio` con
  `opencode/glm-5.3-flash-free`. Al renovarse la cuota de Go se pueden
  restaurar con `python tools/cambiar_modelo.py --restaurar <agente>`.
- Los modelos gratuitos pueden usar las conversaciones para mejorar el modelo.
  El trabajo de esta fase es código y audio generado en local del propio
  repositorio; no se envían recursos nuevos a servicios externos.
- Se actualizan `FALLBACK_MODELS.md` y la tabla de asignación vigente.
- No se activa Extra Usage y no se cambia la cadena de
  `tools/modelos_agentes.json`.

## Referencias

- `FALLBACK_MODELS.md`, procedimiento de cambio.
- `adr/0020-tres-modelos-por-agente.md`.
- `adr/0040-rotacion-ingeniero-godot-a-big-pickle.md` y
  `adr/0042-rotacion-documentacion-a-big-pickle.md` (casos anteriores).

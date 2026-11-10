# ADR 0022: rotación de `explore` a un modelo de pago (10-nov)

Estado: aplicado por decisión del director el 10-nov-2026.

## Contexto
Al lanzar una exploración de código con el subagente `explore`, la petición falló con el error
literal: `Free usage limit reached. Free models work in OpenCode (https://opencode.ai);
subscribe to OpenCode Go to keep going: https://opencode.ai/go`.
El principal de `explore` era `opencode/big-pickle` (gratuito de la consola), el mismo modelo
que ya había dado el aviso de cuota el 10-nov (`HERRAMIENTAS.md` §11).

## Decisión
El director pidió «rota a modelo de pago». Se ejecutó
`python tools/cambiar_modelo.py --rotar explore`, que pasa al alternativo 1 de la cadena:
`opencode-go/gpt-6-luna` (plan Go, 0,10 $/M de entrada y 0,50 $/M de salida, 15 $/mes).
No se tocó la cadena de `tools/modelos_agentes.json` (fuente única), solo la línea `model`
de `agents.explore` en `opencode.jsonc`.

- `--validar`: OK (11 agentes, 1 principal + 3 alternativos, 0 errores).
- `--estado`: `explore` → alternativo 1 `opencode-go/gpt-6-luna`.
- Se **relanzó** la tarea: V2 no reintenta la petición fallida con el modelo nuevo
  (ADR 0020). El subagente completó el informe con el modelo de pago.

## Consecuencias
- `explore` deja de consumir la cuota gratuita de `big-pickle` y pasa a la ventana de Go
  de `gpt-6-luna`. El modelo por defecto de `build`/`plan`/`general` sigue siendo `big-pickle`.
- Se vuelve al principal con `python tools/cambiar_modelo.py --restaurar explore` cuando
  se renueve la ventana o lo pida el director.
- Documentación sincronizada: `FALLBACK_MODELS.md` y `CONFIG_AGENTS.md`.

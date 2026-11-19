# ADR 0036: culling de rigs fuera de cámara (P-30) y medición completa del 19-nov

Estado: **aceptado por el director el 19-nov-2026**. Implementado en la rama
`fase/p30-culling-rigs` (sin fusionar). Pendiente de medición posterior del
ahorro real y de validación manual en partida. Complementa a
`adr/0032-rendimiento-workerthreadpool-y-culling.md` (física condicionada a
`seen` desde el 9-nov): esta decisión cubre la parte que allí quedó pendiente,
el ocultado del renderizado de los guards fuera de pantalla.

## Contexto

### Medición completa en gráfica real (19-nov 18:22)

El director ejecutó `MEDIR.bat` en su Intel HD 520 y produjo una medición
**completa** en `build/medicion/medicion.txt`: 84 líneas `RESULTADO`, con 36
rondas base y 48 con `quitar=`. Con esa medición, `python tools/verificar.py`
(que compara contra `tools/medir_windows/referencia.txt`, la referencia del
15-nov) da:

| Caso | Referencia (15-nov) | Medición (19-nov) | Variación |
|---|---|---|---|
| ciudad | 34,08 ms | 35,27 ms | +3,5 % |
| caminando | 153,11 ms | 148,58 ms | −3,0 % |
| pelea | 51,36 ms | 71,34 ms | **+38,9 % (REGRESIÓN)** |
| pausa | 52,82 ms | 62,10 ms | +17,6 % |

`verificar.py` falla **solo por la mediana de pelea**; el resto queda dentro
del umbral.

### Análisis del medidor

- **Deriva de entorno:** los bloques `r`/`p1` corrieron un 30-45 % más lentos
  que `p2`/`t` sin cambio de guion. El caso de pelea solo corrió en el bloque
  lento, así que su mediana está sesgada.
- **Por driver:** en `opengl3` la pelea sube un +11,5 % (bajo el umbral); la
  bandera de regresión la dispara **ANGLE**. No hay medición comparable del
  15-nov por driver, así que no se puede separar deriva de driver y deriva de
  entorno con los datos actuales.
- **p99 dentro de referencia** en todos los casos.
- **Desglose `quitar=personajes`:** en caminando solo baja 8-16 ms de ~150
  (6-10 %) y en ciudad 0-2 ms. Por tanto, **el coste no está en los sprites de
  los personajes**.
- `entities/enemies/guard.gd:93-149` ya condicionaba animación, cono, detector
  y redibujo a `seen` desde el 9-nov (ADR 0032), así que lo que quedaba visible
  fuera de cámara era solo el subárbol de esqueletos (`rig_root`).

## Decisión

### 1. Decisión del director (19-nov)

1. **Implementar igualmente el ocultado de rigs fuera de cámara**, pese al
   desglose que indica que el ahorro será pequeño: es el cierre de lo que el
   ADR 0032 dejó pendiente y el coste de la pieza es ínfimo.
2. **Documentar y seguir con la regresión de pelea**: no se actualiza
   `tools/medir_windows/referencia.txt`, no se suben umbrales y no se toca
   código de rendimiento a ciegas. La regresión queda registrada como **no
   confirmada** (la evidencia apunta a deriva de entorno y a ANGLE, no a un
   cambio de código).

### 2. Implementación (ingeniero-godot)

- `entities/enemies/guard_visual.gd` añade `set_visible(value: bool) -> void`
  que **solo** escribe `rig_root.visible` (no toca los flags de vista ni el
  `AnimationPlayer`), y es seguro con `rig_root == null` (especies sin
  esqueleto o guardia que aún no ha montado ninguno): no crea nada.
- `entities/enemies/guard.gd:_physics_process()` llama
  `visual.set_visible(seen)` justo tras `update_rig()`, antes del `return` de
  `State.DOWN`, así que también cubre al guardia caído.
- **Invariante:** tras cada tick, `rig_root` es `null` o su `visible` vale
  `seen`. El caso límite del primer rig creado fuera de cámara queda cubierto:
  se oculta en el mismo tick.

## Alternativas descartadas

- **Actualizar `tools/medir_windows/referencia.txt` con la medición del
  19-nov:** descartada por el director; normalizaría una medición sesgada por
  deriva de entorno.
- **Subir los umbrales de `verificar.py`:** descartada; escondería la
  regresión de pelea en vez de dejarla visible y documentada.
- **Tocar código de rendimiento a ciegas** (atlas de rigs, batching, etc.)
  para «arreglar» la pelea: descartado; sin medición que confirme la regresión
  no hay objetivo definido.
- **No aplicar el culling de rigs:** descartada por el director pese al
  desglose; la pieza es pequeña y cierra el pendiente del ADR 0032.

## Consecuencias y limitaciones

- **Ahorro de rendimiento NO medido tras este cambio.** El desglose de
  `quitar=personajes` del 19-nov anticipa un ahorro pequeño (el coste no está
  en los sprites de personajes). La medición de confirmación se hará después,
  en una medición nueva en gráfica real, comparando también por driver para
  aislar ANGLE.
- **Efectos colaterales:** el efecto de muerte (`combat/death_effect.gd`) y
  los impactos (`guard_impacts.gd`) usan `rig_root` y quedarán ocultos si el
  guardia muere **fuera de cámara**. Validación manual en partida.
- **El cono y el `_draw()` del Guard no se ocultan** con este cambio, pero
  `queue_redraw()` ya solo se llama con `seen` (ADR 0032), así que el coste
  está condicionado igualmente.
- **Regresión de pelea:** no corregida, no confirmada. La referencia del
  15-nov no se cambia; `verificar.py` seguirá dando la bandera mientras la
  medición se haga en las condiciones actuales. Si una medición nueva con
  desglose por driver y bloques reproducible la confirma, se abre corrección
  con objetivo definido.
- **Recuento de pruebas:** 491/491 en verde (69 suites, informe JUnit
  validado): 485 casos previos y 6 nuevos en
  `tests/entities/guard_rig_culling_test.gd`. Los 4 primeros fallan al revertir
  el cambio, así que comprueban el comportamiento nuevo.
- Cambio de modelo del agente `documentacion` registrado en la sección
  siguiente y en `FALLBACK_MODELS.md`.

## Cambio de modelo del agente `documentacion` (19-nov-2026)

La tarea de documentación falló porque `opencode/glm-5.3-flash-free` (su
principal gratuito) estaba **retirado/indisponible**. Siguiendo
`FALLBACK_MODELS.md` y el ADR 0020, se ejecutó
`python tools/cambiar_modelo.py --rotar documentacion`, que movió la
configuración de `opencode.jsonc` al primer alternativo:
**`opencode-go/glm-5.3-flash`** (de pago, plan Go). La tarea se **relanzó**
con el modelo nuevo (V2 no reintenta la petición fallida). La cadena de
`tools/modelos_agentes.json` no cambia. Para volver al principal cuando el
gratuito vuelva: `python tools/cambiar_modelo.py --restaurar documentacion`.

## Referencias

- P-30 en `docs/01_CONFLICTOS_Y_PENDIENTES.md`.
- `adr/0032-rendimiento-workerthreadpool-y-culling.md` (primera parte de P-30).
- Medición del 15-nov (referencia vigente): `tools/medir_windows/referencia.txt`.
- Medición del 19-nov: `build/medicion/medicion.txt` (no va a git).
- `docs/03_ESTADO.md`, sección «Medición en gráfica real del 19-nov (P-30)».
- Implementación: `entities/enemies/guard_visual.gd`, `entities/enemies/guard.gd`.
- Rotación de modelos: `FALLBACK_MODELS.md` y `adr/0020-tres-modelos-por-agente.md`.

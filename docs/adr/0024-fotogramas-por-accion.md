# ADR 0024: fotogramas por arma/acción en el atlas (P-25)

Estado: implementado de forma provisional el 10-nov-2026. Pendiente de validación visual en partida.

## Contexto
P-25, decidido y validado por el director el 10-nov: animación por arma y acción con
fotogramas dibujados y optimizados para Godot, dentro del atlas SVG→PNG del pipeline
actual (`36_pipeline_graficos.md`, `adr/0016-revision-codigo.md`). El director aprobó la
forma de hacer plantillas: SVG por código con la paleta «Cuñado Radiactivo» y el rig
actual, sin generador de imágenes de pago. Hasta hoy el atlas solo tenía piezas sueltas
por vista y la sombra; no existían fotogramas de acción.

## Decisión
Se añaden tres acciones (`idle`, `ataque`, `recarga`) con 2, 3 y 2 fotogramas. El frame
actual se expone en el dibujo del protagonista y de los enemigos:

| Pieza | Dónde |
|---|---|
| `data/art/action_frames.json` | Catálogo de acciones, claves de atlas y fps (provisionales) |
| `core/data/action_frame_catalog.gd` | Lectura del catálogo (`has_action`, `actions`, `frames`, `fps`) |
| `entities/art/action_frame.gd` | Estado de la acción y `current_key()` según el reloj del motor |
| `tools/art/piece_atlas_gen.gd` | Dibuja los 7 fotogramas por código y los mete en el atlas |
| `entities/player/player.gd` | `action_frames`, `set_action()`, `tick_action()`, `_draw()` pasa `frame_key` |
| `entities/art/protagonist_art.gd` | `draw(..., frame_key)` y `_draw_action_frame()` |
| `entities/enemies/guard_visual.gd` | `action_for()`, `_update_action_frame()`, `_draw_action_frame()` |
| `combat/combat_system.gd`, `conversion/action_system.gd` | Marcan «ataque» y «recarga» |

Decisiones técnicas:
- **Claves sin `/`** (`accion_ataque_0`, no `accion/ataque/0`): `validar_datos.py` exige
  que toda clave con `/` corresponda a un SVG del rig. Así se mantiene esa comprobación
  intacta, sin debilitarla, y se añade una nueva para el catálogo.
- **Sin RNG global**: `ActionFrame` usa `Time.get_ticks_usec()` y `CorruptoEffect` usa
  ruido determinista; la animación no consume la semilla de la partida.
- **Coste**: un `draw_texture_rect_region()` por personaje y fotograma, sobre la textura
  compartida `PieceAtlas`. `frame_key` tiene valor por defecto `""` para no romper las
  llamadas existentes a `ProtagonistArt.draw`.
- La selección de acción en el jugador es **cosmética y provisional** (0,5 s y vuelta a
  `idle`); no cambia controles, combate ni conversión. P-37 (ataque automático) sigue
  abierto y no se toca.

## Origen y herramienta de los recursos generados
Registro exigido por `AGENTS.md`:

| Recurso | Origen | Herramienta | Fecha |
|---|---|---|---|
| `art/beta/atlas/piezas.png` | SVG propios de `art/beta/rig/` + 7 fotogramas dibujados por código con `Palette` («Cuñado Radiactivo») | `tools/art/piece_atlas_gen.gd`, Godot 4.7.2 estable (consola) | 10-nov-2026 |
| `data/art/atlas_piezas.json` | Índice del atlas anterior | `tools/art/piece_atlas_gen.gd`, Godot 4.7.2 | 10-nov-2026 |
| `data/art/action_frames.json` | Catálogo escrito a mano, datos provisionales | Editor de texto | 10-nov-2026 |

Tras regenerar se ejecutó `godot --headless --import`. Resultado: **55 piezas, 170 de
2048 px de altura**. `validar_datos.py --actualizar` solo cambió `atlas_piezas: 55` y
`action_frames: 3` en `tools/referencia_datos.json`.

## Valores provisionales
fps: idle 2, ataque 10, recarga 4. Fotogramas en pantalla: 26 px × `CharacterScale`.
`ACTION_SHOW_TIME = 0,5 s`. Ángulos y poses del brazo/armas dibujados por código.
Mapeo de IAs a efectos de texto (P-28) aprobado por el director el 10-nov.

## Consecuencias y limitaciones
- El aspecto final de los fotogramas **no se ha validado en partida**: son siluetas
  provisionales, no arte final.
- No hay medición en gráfica real; el coste se estima por número de llamadas de dibujo.
- `tests/art/action_frame_test.gd` (5 casos) comprueba catálogo, atlas, avance de frames,
  selección de acción y vuelta a `idle`.
- P-26 sigue bloqueado hasta el gestor multi-zona (opción 1a). La duda de si el tiempo
  del mundo avanza durante el viaje rápido sigue sin resolver.

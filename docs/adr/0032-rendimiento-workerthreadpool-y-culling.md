# ADR 0032: WorkerThreadPool para la física del mundo vivo y culling de guards fuera de pantalla

Estado: **en revisión** (15-nov-2026). Rama `fase/p30-rendimiento`.

## Contexto

La medición en gráfica real (`MEDIR.bat`, Intel HD 520, 15-nov) mostró que el caso
«caminando» consume **153,11 ms por fotograma** (6,5 fps). El desglose por partes reveló
que el coste está distribuido: quitar personajes baja un 28 % y quitar el protagonista un
24 %, pero la física (`fisica_media`) solo consume ~35 ms (23 % del fotograma); el resto
es renderizado (~118 ms, 130-158 draw_calls).

La decisión original de P-30 (9-nov) era «no aplicar `WorkerThreadPool`, solo cuando haga
falta». La medición del 15-nov justifica aplicarlo.

## Decisión

### 1. Paralelizar el `calm_down` de cada NPC en `WorldSim._step()`

`WorldSim._step()` recorría `npc_ids` y llamaba a `calm_down()` de cada NPC de forma
secuencial. Ahora se lanza una tarea por NPC con `WorkerThreadPool.add_task()` y se espera
a todas con `wait_for_task_completion()`. El resto del paso (`rumors.step`, `events.step`,
`missions.step`, `festivals.update`, `population.step`, `forget_step`) sigue secuencial
porque hay dependencias entre sistemas.

Razón: `calm_down` es independiente por NPC (no depende de otros NPCs), así que es seguro
paralelizarlo. Los subsistemas tienen dependencias entre sí, así que quedan secuenciales.

### 2. Culling de guards fuera de pantalla

En `Guard._physics_process()`, el `detector.update()` (que hace un rayo de física por
fotograma) solo se ejecuta si el guard está visible en pantalla. Un guard fuera de
pantalla no puede ver al jugador, así que no necesita actualizar su detector. El
`visual.update_rig()` y `queue_redraw()` ya estaban condicionados a `seen`.

### 3. `ensure_buses()` en `FootstepAudio` y `BlablaVoice`

Se añadió `AudioMixer.ensure_buses()` en `FootstepAudio._ready()` y `BlablaVoice._ready()`
para que los buses de audio (incluidos los de P-29) existan antes de asignarles un bus.

## Consecuencias y limitaciones

- **El `WorkerThreadPool` solo paraleliza el `calm_down`.** Los subsistemas siguen
  secuenciales por dependencias. Si la medición muestra que los subsistemas son el cuello
  de botella, habrá que paralelizarlos también (más trabajo, más riesgo).
- **El renderizado sigue siendo el cuello de botella principal** (~118 ms). El culling de
  guards fuera de pantalla ayuda, pero no resuelve el coste de los rigs animados y los
  draw_calls de los guards en pantalla. Para eso hace falta atlas de rigs y batching.
- **`WorkerThreadPool` en Godot 4 es un singleton global.** Funciona en headless y en
  exportado. Las pruebas unitarias de `WorldSim` también lo usan (sin problemas).
- **La medición posterior** (con `MEDIR.bat`) dirá si la mejora es real. Si no mejora,
  se revierte y se busca otra causa.

## Referencias

- P-30 en `docs/01_CONFLICTOS_Y_PENDIENTES.md`.
- Medición del 15-nov en `docs/03_ESTADO.md` y `tools/medir_windows/referencia.txt`.
- `docs/adr/0017-optimizacion-integrada.md` (medición original).
- Implementación: `simulation/world_sim.gd`, `entities/enemies/guard.gd`.

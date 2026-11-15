# Prompt para la siguiente sesión (15-nov-2026)

Copia de este bloque al empezar la conversación siguiente. `docs/03_ESTADO.md` es la
fuente de verdad; esto es solo el arranque rápido.

---

## Contexto

**Fase anterior cerrada y fusionada en `main`:** tareas críticas post-beta
(`fase/p09-p29-p30-p32-p36-p39-p41`, PR #11, merge `70ce93e`, 15-nov, aprobada por el
director). Cerró: **P-09** (88 preguntas de conversión), **P-29** (sonido direccional con
oclusión por muro y timbre por IA), **P-30** (decidido: no se aplica `WorkerThreadPool`),
**P-32** (el chat solo enseña los retos conocidos y no completados), **P-36** (maximizado),
**P-39** (diagnóstico y fin del fallo intermitente) y **P-41** (carteles de entrada a las
zonas).

**Medición en gráfica real (15-nov):** el director ejecutó `MEDIR.bat` en la Intel HD 520.
Ciudad 34,08 ms, caminando 153,11 ms, pelea 51,36 ms, pausa 52,82 ms (medianas). El
caminando es el cuello de botella (6,5 fps). El desglose por partes muestra que el coste
está distribuido: quitar personajes baja un 28 %, quitar el protagonista un 24 %, pero la
física solo consume ~35 ms (23 % del fotograma); el resto es renderizado (~118 ms,
draw_calls ~130-158).

**Mini-fase de rendimiento (en curso):** `fase/p30-rendimiento`. P-30 se reactivó tras la
medición. Implementado: (1) `WorldSim._step()` paraleliza el `calm_down` de cada NPC con
`WorkerThreadPool`; (2) `Guard._physics_process()` solo actualiza el detector si el guard
está en pantalla. Pruebas: 31/31 simulación, 83/83 core+stealth. Pendiente: medición con
`MEDIR.bat` para verificar la mejora y fusión en `main`.

**Estado del código:** `main` en verde, **405/405 pruebas** en Windows y en el CI de Linux
(core 52, combate 59, simulación 120, despliegue_cero 174). `verificar.py` OK, `.exe`
exportado y prueba de humo OK.

## Objetivo de esta fase: P-42 y P-43

Las dos peticiones del director del 14-nov (`docs/01_CONFLICTOS_Y_PENDIENTES.md` y
`docs/02_DECISIONES.md`):

### P-42 — Contenido conversacional masivo
- Cada raza debe tener **al menos 150 conversaciones**.
- Alternando: conversaciones de **una sola pregunta**; de **3-4 preguntas** que llevan a
  información interesante; y con **bifurcaciones** (si respondes distinto, vas por otro
  flujo).
- El juego debe parecer que **cada NPC de cada zona sabe cosas distintas** y habla de sus
  propias cosas.
- Deben existir conversaciones que acaben en un **regalo al protagonista en forma de pieza**
  o en que el NPC se **enfada** y: (1) se pega con el protagonista, o (2) se forma pelea con
  otra raza.
- El sistema de `LiveDialogue` debe soportar nodos de diálogo por raza/estado, no solo menú
  plano.

### P-43 — Pantalla de inicio y «Conoce la historia»
- En el **menú principal** (además de «Nueva partida» y «Continuar»), un botón
  **«Conoce la historia»** que muestre el lore del juego en modo gracioso de videojuego, con
  las **imágenes que ya existen de los hechos históricos**.
- Relacionado con **P-41**: la pantalla de carga inicial del juego con el protagonista en
  pose gamberra rodeado de 2-3 NPCs de cada especie (jubilado, mohocrata, plegado, eco,
  grux, manada).

## Reglas que no se negocian

- **Una fase del plan por conversación.** La conversación termina al fusionar esa fase en
  `main`.
- **Rama por fase y siempre Pull Request a `main`.** Nada de fusión directa en local.
  Commitear, pushear y abrir el PR **requieren confirmación del director**; la fusión también.
- **En cada fusión:** generar `build/bug_de_familia.exe` con el preset «Windows», actualizar
  `docs/03_ESTADO.md` y avisar al director de que hay que cambiar de conversación.
- **Una versión ejecutable siempre.** Entregas pequeñas.
- **No inventes lo que falta:** los parámetros provisionales se marcan como tales.
- **No afirmes que algo funciona sin ejecutarlo:** separa lo ejecutado de lo no ejecutado.
- **Pruebas:** nunca desactives ni debilites una prueba para conseguir verde; semilla 1234 en
  las pruebas de simulación; prohibido marcar flaky o subir tolerancias.
- **Código:** GDScript tipado, tabuladores, LF, UTF-8 sin BOM, líneas de menos de 100
  caracteres.
- **Documentación:** `docs/02_DECISIONES.md` manda; las decisiones técnicas nuevas van como ADR
  en `docs/adr/`; lo pendiente, en `docs/01_CONFLICTOS_Y_PENDIENTES.md`.
- **Herramientas:** `python tools/verificar.py` antes de cada commit; el CI valida el informe
  JUnit de verdad (`tools/validar_informes.py`); el arranque del juego se comprueba con
  `tools/verificar_humo.py`.
- **Habla siempre en español.**

## Arranque

1. `git status` y `git log --oneline -5` en la raíz: la rama debe ser `main` y estar limpia.
2. Lee `docs/03_ESTADO.md` (traspaso) y `docs/01_CONFLICTOS_Y_PENDIENTES.md` (P-42, P-43).
3. `godot --headless --import` si hace falta (crea `.godot/`, que no va a git).
4. Decide el reparto de la fase y **pregunta al director** lo que sea decisión de producto
   (qué coches, qué temas, cuántas conversaciones por raza y de qué tipo). Las decisiones
   técnicas son tuyas.

## Pendiente de la fase anterior (ACTUALIZADO con la medición)

- **Medición en gráfica real (15-nov, HECHA):** el director ejecutó `MEDIR.bat` en la Intel
  HD 520. 0 regresiones contra la nueva referencia: **ciudad 34,08 ms, caminando 153,11 ms,
  pelea 51,36 ms, pausa 52,82 ms** (medianas, 12/12/6/6 rondas). La referencia anterior
  (7,20 / 18,60 / 11,20 / 16,40) era de la beta con una sola zona y no era comparable.
  La nueva referencia es esta medición (`tools/medir_windows/referencia.txt`).
- **Consecuencia importante:** la decisión de **P-30 (`WorkerThreadPool`) se reactiva**. La
  medición muestra que el caminando consume 153 ms/fotograma (6,5 fps) y que la física
  consume ~35 ms (23 %). Repartir la física entre núcleos es el primer candidato para bajar
  el caminando por debajo de 60 fps. **Mini-fase de rendimiento en curso**
  (`fase/p30-rendimiento`): implementado `WorkerThreadPool` en `WorldSim._step()` y culling
  del detector fuera de pantalla en `Guard`. Pruebas 31/31 simulación, 83/83 core+stealth.
  Pendiente: medición con `MEDIR.bat` para verificar la mejora y fusión en `main`.
- **Desglose por partes (bloque 2 del MEDIR.bat):** el coste está distribuido. Quitar
  personajes baja un 28 % y quitar el protagonista un 24 %, pero quitar ambiente, fachadas,
  paredes o partículas solo baja un ~12 %. La física (`fisica_media`) es ~35 ms del fotograma
  de 153 ms; el resto es renderizado (~118 ms, draw_calls ~130-158).
- **Validación manual en partida** (el director dijo que sus pruebas en local fueron bien): el
  timbre de cada IA, que el paso tapado se distinga del claro, la lista de retos del chat y
  los carteles de entrada de las zonas.

## Cosas que ya se saben del código (te ahorra tiempo)

- `LiveDialogue` (`simulation/live_dialogue.gd`) es el menú de conversación con habitantes;
  `AiChatter` (`ai/ai_chatter.gd`) es el de las IAs del canal. Los dos speak de texto plano:
  P-42 necesita ramificación en ambos, y el de las IAs con diálogo por raza/estado.
- El texto de las especies está en `data/world/species.json` (claves `greet`, `opener`,
  `nothing`, `angry`, `praised`, `weird`, `sad`, `role_lines`, `lore`).
- Las piezas convertibles y las recompensas están en `core/data/` y `conversion/`.
- El menú principal está en `scenes/sandbox/sandbox.gd` (`_show_start_menu`, `MessageScreen`).
- Las imágenes de los hechos históricos: mira `art/` y `data/art/` antes de decidir si hay que
  generarlas.
- `docs/50_lore.md` es la fuente del lore; `docs/16_razas_facciones.md`, la de las razas.

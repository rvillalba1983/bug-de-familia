# Borrador de diseño — P-42 y P-43 (post-beta, fase siguiente)

Borrador preparatorio. Se escribe mientras el director mide con `MEDIR.bat`.
La fuente de verdad sigue siendo `docs/03_ESTADO.md` y `docs/02_DECISIONES.md`.

## P-42 — Contenido conversacional masivo

### Objetivo
- Al menos **150 conversaciones por raza** (6 razas → ~900 en total).
- Alternando tres tipos:
  1. **Una sola pregunta** (pregunta rápida, respuesta corta).
  2. **3-4 preguntas** que llevan a información interesante.
  3. **Bifurcaciones** (si respondes distinto, vas por otro flujo).
- Cada NPC de cada zona debe parecer que **sabe cosas distintas** y habla de sus propias
  cosas.
- Conversaciones que acaben en un **regalo al protagonista en forma de pieza** o en que el
  NPC se **enfada** y: (1) se pega con el protagonista, o (2) se forma pelea con otra raza.

### Estado actual del sistema de diálogo
- `simulation/live_dialogue.gd` abre un menú de opciones con `_refresh()`; ya tiene un
  `_branch` con el caso `"news"` (preguntas de lore, fuente y vuelta al menú).
- Las opciones se generan en `_refresh()` con las preguntas de `species_data` (greet, opener,
  nothing, angry, praised, weird, sad, role_lines, lore) y `world.extra_options(npc)`.
- Cada opción se agota tras `rng.randi_range(2, 5)` usos (`_register_option_use`); al
  agotarse salta `_exhaust_option()` que provoca pelea o cierra.
- El saludo depende del oficio (`role_lines`), lo que ya da variedad por habitante.
- `InvestigationDirector` tiene ramificación por nodos y flags; `LiveDialogue` no.

### Propuesta técnica (a validar con el director)
1. **Conversaciones por especie, no por habitante.** El contenido sale de un fichero nuevo
   `data/conversation/live_<especie>.json` con entradas de la forma
   `{ "id", "greeting?", "questions": [...], "branches": {...}, "reward?", "anger?" }`.
   El número de conversaciones por raza se consigue con el catálogo, no con código.
2. **Ramificación en `LiveDialogue`:** añadir `_branch` como estado de máquina con más de un
   valor (`"root"`, `"news"`, `"tree:<id>"`, `"reward"`, `"fight"`). `_refresh()` mira el
   branch activo y pinta las opciones correspondientes; cada opción cambia el branch.
3. **El NPC se identifica por `id + role + zone`** para elegir qué conversación ofrece (sin
   repetir la misma conversación a dos habitantes de la misma zona).
4. **Regalo de pieza:** al llegar a un nodo final con `reward`, llamar a
   `level.reward_piece()` o añadir una pieza concreta al cuerpo del protagonista. Requiere
   decidir qué pieza y cuándo (probablemente una por conversación, con límite diario).
5. **Enfado → pelea:** reutilizar `_hit()` y el sistema de `FightDirector`; si el NPC es
   pasivo o de noche, huir en vez de pegar.
6. **Enfado → pelea entre razas:** llamar a `battles.begin()` con los grupos cercanos, o
   provocar un ruido que atraiga a la raza rival.
7. **Memoria:** `npc.memories` y `npc.beliefs` ya existen; la conversación puede leerlos para
   variar. Persistir el progreso de conversación en el guardado (hoy `_option_uses` y
   `_option_limits` viven en memoria, no en `SaveSystem`).

### Lo que no se puede inventar (directivas del director)
- Las 150 conversaciones son **contenido**, no código. Se escriben en lotes y el director las
  critica, igual que P-09 y P-23/P-27.
- El sistema debe soportar ramificación real, no un menú plano con más opciones.

### Tamaño estimado
- Infraestructura de ramificación: una fase.
- Contenido: varias fases de lotes, como P-09.

## P-43 — Pantalla de inicio y «Conoce la historia»

### Objetivo
- En el **menú principal** (además de «Nueva partida» y «Continuar»), un botón
  **«Conoce la historia»** que muestre el lore del juego en modo gracioso de videojuego, con
  las **imágenes que ya existen de los hechos históricos**.
- Relacionado con **P-41**: la pantalla de carga inicial del juego con el protagonista en
  pose gamberra rodeado de 2-3 NPCs de cada especie (jubilado, mohocrata, plegado, eco,
  grux, manada).

### Estado actual
- El menú principal está en `scenes/sandbox/sandbox.gd::_show_start_menu()` y usa
  `MessageScreen` con las entradas `UI_MENU_CONTINUE` y `UI_MENU_NEW`.
- Las imágenes de los hechos históricos: mirar `art/` y `data/art/` (no se han generado
  todavía; puede hacer falta generarlas con `tools/art/` o con encargo de arte).
- El lore está en `docs/50_lore.md` (13 secciones: las 6 especies, la historia compartida,
  la infraestructura anterior, etc.).

### Propuesta técnica (a validar con el director)
1. Añadir la entrada `UI_MENU_LORE` al `MessageScreen` del menú principal.
2. Crear `scenes/ui/lore_screen.gd` (o reutilizar `MessageScreen`) que muestre el lore en
   páginas, con las imágenes de los hechos históricos, y un botón «Cerrar».
3. Las imágenes se generan (o se seleccionan) por lote, como en P-09: el equipo propone,
   el director tacha o aprueba.
4. La pantalla de carga inicial (con el protagonista y los NPCs de cada especie) se monta
   como una escena aparte (`scenes/ui/loading_screen.tscn`) que se muestra antes del menú;
   requiere arte del protagonista en pose gamberra y de 2-3 NPCs por especie.

## P-30 — Reparto del cálculo del mundo entre núcleos (REACTIVADO el 15-nov)

La medición en gráfica real (`MEDIR.bat`, Intel HD 520) muestra que el caminando consume
**153,11 ms por fotograma** (6,5 fps) y que la física consume ~35 ms (23 % del fotograma).
El resto es renderizado (~118 ms, draw_calls ~130-158). Repartir la física del mundo vivo
entre núcleos con `WorkerThreadPool` es el primer candidato para bajar el caminando por
debajo de 60 fps.

**Pero ojo: el cuello de botella principal es el renderizado, no la física.** Quitar
personajes baja un 28 % y quitar el protagonista un 24 %, pero la física solo consume ~35 ms
del fotograma de 153 ms. Así que la mini-fase de rendimiento debería tener **dos frentes**:

1. **Culling de guards fuera de pantalla** (renderizado): los 36 guards se animan y dibujan
   aunque estén fuera de la cámara. Reducir draw_calls con atlas y occlusion culling.
2. **WorkerThreadPool para la física** (P-30): repartir el recorrido de los 36 NPCs en
   `_step()` y el `move_and_slide` de los guards entre núcleos.

**Decisión pendiente:** mini-fase de rendimiento antes de P-42, o dentro de la fase de P-42.
Si se hace antes, P-42 se construye sobre un juego que va a 60 fps en vez de 6,5 fps.

Ver `docs/adr/0017-optimizacion-integrada.md` y `tools/medir_windows/referencia.txt`.

## Decisiones pendientes del director (no bloquean)

- ¿Las 150 conversaciones son por raza o por NPC? El director dijo «cada raza al menos 150»,
  pero luego «cada NPC de cada zona sabe cosas distintas». Lo más coherente: un catálogo de
  ~150 por raza, con variantes por oficio y por zona.
- ¿El regalo de pieza es aleatorio o fijo por conversación? Mejor fijo, para que sea
  predecible y testeable.
- ¿El enfado que provoca pelea entre razas debe ser siempre con el rival natural, o puede ser
  con cualquiera? Con el rival natural (jubilado↔mohocrata, eco↔manada, grux↔plegado).
- ¿La pantalla de carga inicial reemplaza al menú o es anterior? Anterior: carga → menú.
- ¿Las imágenes del lore las genera el equipo con el pipeline actual (SVG→PNG) o el director
  las trae hechas? El director dijo «las imágenes que hemos creado», así que ya existen o se
  crean con el pipeline actual.

## Cosas que ya se saben del código (te ahorra tiempo)

- `LiveDialogue` (`simulation/live_dialogue.gd`) es el menú de conversación con habitantes;
  `AiChatter` (`ai/ai_chatter.gd`) es el de las IAs del canal. Los dos speak de texto plano:
  P-42 necesita ramificación en ambos.
- El texto de las especies está en `data/world/species.json` (claves `greet`, `opener`,
  `nothing`, `angry`, `praised`, `weird`, `sad`, `role_lines`, `lore`).
- Las piezas convertibles y las recompensas están en `core/data/` y `conversion/`.
- El menú principal está en `scenes/sandbox/sandbox.gd` (`_show_start_menu`, `MessageScreen`).
- Las imágenes de los hechos históricos: mira `art/` y `data/art/` antes de decidir si hay
  que generarlas.
- `docs/50_lore.md` es la fuente del lore; `docs/16_razas_facciones.md`, la de las razas.
- `docs/adr/0029-contenido-y-ui-conversion.md` tiene el precedente de cómo se amplió el
  contenido conversacional de las especies.
- El director ha pedido **150 conversaciones por raza**, con **bifurcaciones** y
  **ramificación real** (no menú plano con más opciones).

## Reglas que no se negocian (resumen)

- Una fase del plan por conversación; la conversación termina al fusionar en `main`.
- Rama por fase y siempre Pull Request a `main`; nada de fusión directa en local.
- Commitear, pushear y abrir el PR **requieren confirmación del director**; la fusión también.
- En cada fusión: generar `build/bug_de_familia.exe` con el preset «Windows», actualizar
  `docs/03_ESTADO.md` y avisar al director de que hay que cambiar de conversación.
- Una versión ejecutable siempre. Entregas pequeñas.
- No inventes lo que falta: los parámetros provisionales se marcan como tales.
- No afirmes que algo funciona sin ejecutarlo: separa lo ejecutado de lo no ejecutado.
- Pruebas: nunca desactives ni debilites una prueba para conseguir verde; semilla 1234 en las
  pruebas de simulación; prohibido marcar flaky o subir tolerancias.
- Código: GDScript tipado, tabuladores, LF, UTF-8 sin BOM, líneas de menos de 100 caracteres.
- Documentación: `docs/02_DECISIONES.md` manda; las decisiones técnicas nuevas van como ADR en
  `docs/adr/`; lo pendiente, en `docs/01_CONFLICTOS_Y_PENDIENTES.md`.
- Herramientas: `python tools/verificar.py` antes de cada commit; el CI valida el informe JUnit
  de verdad (`tools/validar_informes.py`); el arranque del juego se comprueba con
  `tools/verificar_humo.py`.
- Habla siempre en español.

## Pendiente de la fase anterior (esta fase)

- **Medición en gráfica real:** el director tiene el kit en `build/medicion.zip` (`MEDIR.bat` +
  `BugDeFamilia_medir.exe`, ~56 MB). Tarda unos 20 minutos y deja un `medicion.txt` en la
  misma carpeta. Cuando llegue: cópialo a la raíz y ejecuta
  `python tools/comparar_medicion.py medicion.txt`; si muestra regresiones, míralas antes de
  tocar nada. La referencia está en `tools/medir_windows/referencia.txt`. Con ese resultado se
  revisa la decisión de **P-30** (`WorkerThreadPool`), que está en «no se aplica» mientras no
  haya medición que lo justifique.
- **Validación manual en partida** (el director dijo que sus pruebas en local fueron bien): el
  timbre de cada IA, que el paso tapado se distinga del claro, la lista de retos del chat y los
  carteles de entrada de las zonas.

## Arranque sugerido de la conversación

1. `git status` y `git log --oneline -5` en la raíz: la rama debe ser `main` y estar limpia.
2. Lee `docs/03_ESTADO.md` (traspaso) y `docs/01_CONFLICTOS_Y_PENDIENTES.md` (P-42, P-43).
3. `godot --headless --import` si hace falta (crea `.godot/`, que no va a git).
4. Decide el reparto de la fase y **pregunta al director** lo que sea decisión de producto
   (qué temas, cuántas conversaciones por raza y de qué tipo, qué imágenes del lore). Las
   decisiones técnicas son tuyas.
5. Si el director envía `medicion.txt`, analízalo antes de empezar con el código de la fase.

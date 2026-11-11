# Estado del desarrollo

Se actualiza cada vez que una fase se fusiona en `main`.

| Fase | Estado |
|---|---|
| 0 a 7 | Fusionadas en `main` y probadas por el usuario |
| Arte | Estilo de la beta fusionado en `main`, ejecutado en Godot 4.7.2 el 9-nov: 187 pruebas pasan y el director aprobó capturas y vídeo reales. Ver `adr/0008-estilo-visual-beta.md` |
| 7b. Pulido visual e interfaz | Fusionada en `main` y aprobada por el director el 9-nov, con los cuatro puntos del primer minuto (animación de enemigos, impacto, convertir y silueta). 203 pruebas pasan. Ver `adr/0009-pulido-primer-minuto.md`. El resto de la lista pasa a la fase 9, incluidas las opciones de reducir temblores y destellos |
| 8. Mundo vivo (zona beta) | Fusionada en `main` el 9-nov y aprobada por el director. 229 pruebas pasan. Ver `adr/0010-mundo-vivo-beta.md` |
| 9. Contenido y pulido | Fusionada en `main` el 9-nov y aprobada por el director. 255 pruebas pasan. Ver `adr/0011-ias-y-controles.md`, `adr/0012-batallas.md` y `adr/0013-audio-y-rendimiento.md` |
| Cierre de la beta | Fusionada en `main` el 9-nov con aprobación del director. 261 pruebas pasan. Ver `adr/0014-cierre-beta.md` |
| Arreglos tras probar la beta | Fusionada en `main` el 9-nov con aprobación del director. 266 pruebas pasan. Ver `adr/0015-arreglos-beta.md` |
| Revisión de código, pruebas y rendimiento (P-24) | Fusionada en `main` el 9-nov con aprobación del director. 293 pruebas pasan. Ver `adr/0016-revision-codigo.md` |
| Optimización en gráfica integrada | Fusionada en `main` el 9-nov con aprobación del director. 308 pruebas pasan. Ver `adr/0017-optimizacion-integrada.md` |
| Pruebas finales de la beta y dudas | Fusionada en `main` el 9-nov con aprobación del director. 311 pruebas pasan. Las pruebas del director en Windows siguen pendientes: hará lista de lo raro durante la semana |
| Configuración de OpenCode, herramientas y CI | **Fusionada en `main` el 10-nov con aprobación del director.** Equipo de 10 agentes con tres modelos cada uno, entorno local gratuito, scripts deterministas, formatter propio y GitHub Actions (pruebas + exportación). 311 pruebas en verde en Windows y en el CI de Linux. Ver `adr/0018-agentes-y-modelos.md`, `adr/0019-herramientas-ci-y-mcp.md` y `adr/0020-tres-modelos-por-agente.md`. Queda P-39 (fallo intermitente preexistente) para la post-beta |
| Post-beta (mejoras gráficas/UI/audio/sim) | **Fusionada en `main` el 10-nov por el PR #3** (HEAD `fd9366e1`), con 329 pruebas y 0 fallos. La fase visual (P-25, P-26, P-28, P-31 y P-33) quedó cerrada; implementado: P-36 (maximizado), P-38 (centrado conversión), P-26 (fantasmas en conversación), P-33 (destello en chat), P-14 (límite rumores), P-23/P-27/P-09 (lotes propuestos). Pendiente: ajustes provisionales de la fusión y validación manual en partida; para la post-beta: P-29 (timbres) y P-39 (fallo intermitente en Linux). Ver `adr/0024-fotogramas-por-accion.md`, `adr/0025-alejazo-vista-estrategia.md` y `borradores/P-23_P-27_P-09_lotes.md`. |

## Pendiente de respuesta del usuario (no bloquea)
- Textos provisionales del caso y de las IAs.

## Tras la fase 6
- Los valores de daño, alcance y recarga del combate son provisionales (`docs/adr/0005-combate.md`).
- Los disparos solo afectan a guardias y tiradores, no a drones ni cámaras.

## Tras la fase 7
- Valores provisionales de la beta: `docs/adr/0006-zona-beta.md`.
- Las rutas de sigilo con enemigos activos tienen prueba automática en `tests/flows/beta_routes_test.gd`; el usuario además las ha probado en partida.
- Sin hacer: viaje entre puntos de guardado y consecuencias al salir de la zona. La pieza que suelda Don Ramón y la huella visible al morir un aliado único ya están implementadas (`scenes/beta/beta_challenges.gd`, `tests/beta/beta_robustness_test.gd`). Lo decidido está en `02_DECISIONES.md`.

## Tras P-09 (lotes 1 y 2)
- 76 preguntas de conversión, motes y comentarios del protagonista integrados. Valores provisionales: `docs/adr/0007-motes-y-comentarios.md`.
- Los comentarios solo salen en la zona beta y nadie los ha probado aún en partida.
- Esperan a su sistema: comentarios de Cupido_Beta enamorada y del viaje rápido, motes de las 14 IAs no jugables y las 12 preguntas reservadas de las otras cuatro razas (`docs/borradores/P-09_lote_2.md`).

## Tras la fase 7b
- Tiempos, temblor, zancada, deformación y colores de desgaste son provisionales. Los 12 textos de burla de las IAs están pendientes de la crítica del director (P-09).
- Rendimiento sin medir en una gráfica real: las pruebas dibujan por software.
- Sin revisar: cuadrado gris a los pies de Don Ramón.

## Tras la fase 8
- Toda la población, los sucesos, las misiones y los textos de `data/world/` son provisionales. El director puede tachar festividades.
- Sin medir en una gráfica real. Terminar una misión y reventar una fiesta tienen prueba automática en `tests/flows/beta_routes_test.gd`; falta probarlos a mano en partida.
- Los personajes con nombre siguen con diálogos escritos, fuera del motor social.
- P-19: proponer opciones para mostrar los controles, que ahora salen en el chat de las IAs.
- Capturas de partida real con `tools/captura_partida.gd` (variables CAPTURAS, SALIDA, FECHA, ACCION y SUCESO).

## Tras la fase 9
- 20 IAs, batallas, vista de estrategia, 100 melodías y 40 perfiles de voz sintéticos. Las voces no son acentos reales. Valores y textos provisionales.
- Sin medir en una gráfica real. Una batalla en curso no se guarda.
- Pruebas de rendimiento con `tools/medir_rendimiento.gd` (variables CASO y EXTRA). Audio con `tools/audio/gen_audio.py`.

## Tras el cierre de la beta
- P-02 implementado y provisional, a revisar jugando. Población, catálogo y textos son provisionales.
- El director no ha jugado aún la beta entera con estos cambios. Sin medir en una gráfica real.
- Recorridos reales con `tools/recorrido_beta.gd` (variables RUTA, SEMILLA y FECHA).
- Siguiente fase: P-24, revisión de código y más pruebas funcionales. Ideas post-beta: P-23, P-25, P-26 y P-27.

## Tras los arreglos de la beta
- Rendimiento medido solo con gráfica por software: falta confirmarlo en el ordenador del director. Medir con `tools/medir_por_partes.gd` (variables NOCHE, EXTRA y CAPAS).
- La pelea contra grupos no la ha probado el director a mano. Radio de reacción (250) y hueco alrededor del jugador (34), provisionales.
- Clics reales de pelea con `tools/probar_pelea.gd`.

## Tras la revisión de código (P-24)
- Razas, zona, progenitores, armas, animaciones y muertes viven en datos: ver `adr/0016-revision-codigo.md`.
- Medido en la gráfica del director (Intel HD 520): ciudad de 84 a unos 30 ms, batalla de 250 a 16-28 ms. Para 60 imágenes por segundo aún faltan protagonista en textura, paredes en bloques y atlas de personajes.
- Medir el juego exportado con `tools/medir_exportado.tscn` y el preajuste «Medicion Windows».
- Al ejecutar dos Godot a la vez, usar un `XDG_DATA_HOME` distinto: comparten `user://`.

## Tras la optimización en gráfica integrada
- En la Intel HD 520 del director, con OpenGL directo: ciudad 7 ms, caminando 19, pelea 11 y pausa 16 (medido antes de los últimos ajustes). La física al caminar, unos 21 ms por paso, es el siguiente cuello de botella.
- Sin probar en Windows por Claude. Plugins de estilo IRCap confirmados por el director el 10-nov: los quiere, con fase de revisión estética después. Sin confirmar todavía: provocar peleas y autocolocación de piezas.
- El director vio personajes desaparecer al hablar mal de la otra raza; no se ha reproducido. Queda por vigilar.
- Provisionales: retroceso de 80 unidades, tres frases para provocar batalla, y tamaño de personajes al 50 %.

## Tras las pruebas finales de la beta
- Grupos engañados (respuestas «chatarra al norte» y «sombreros en el sur»): antes se esfumaban; ahora se van andando y desaparecen al llegar. Salida y velocidad provisionales.
- Investigado: tras un rumor, casi toda una raza puede irse andando a contárselo a la otra. Es P-14 exagerado: el director decide si se limita.
- De noche, los Jubilados apagados no se defienden en una batalla (8 caídos sin devolver un golpe en la prueba): decisión pendiente.
- Ejecutado aquí con capturas: provocar por malmeter, autocolocación, aviso al recoger, retroceso y chat. Sin confirmar por el director, igual que OpenGL directo y el `.exe` en Windows. Sin probar en partida: batalla por recado insultante.
- Herramientas: `tools/seguir_personajes.gd`, `tools/probar_pendientes.gd` y `tools/probar_desvio.gd`.
- Preguntas abiertas de la post-beta: P-23, P-25 a P-31, mapa, orden de razas, guardar batallas, rendimiento objetivo y textos provisionales.

## Herramientas y CI (fusionado en `main` el 10-nov)

- Entorno local gratuito en `opencode_projects`: Godot 4.7.2, Python 3.12.10, ffmpeg, Inkscape 1.4.4 y plantillas de exportación; todos en el PATH de usuario. Audacity ya estaba instalado.
- Scripts deterministas: `tools/verificar.py` (entrada única), `tools/validar_datos.py` (46 comprobaciones), `tools/formatear.py`, `tools/comparar_medicion.py`. Estado hoy: 0 errores en datos y en 255 archivos de texto; 64 avisos de líneas largas, deuda anterior.
- Al crear el formateador se corrigieron 12 archivos que incumplían la norma de línea final (9 JSON de `data/` y 3 pruebas). No se debilitó ninguna comprobación.
- GitHub Actions: `pruebas.yml` (verificaciones deterministas + 311 pruebas gdUnit4, con `timeout` y `</dev/null`) y `exportar.yml` (`.exe` y `.pck` como artefactos). Ambos YAML validados con parser real.
- **Primer run de `pruebas.yml` en Linux: 311/311 ejecutadas, 3 fallos**, mientras que en Windows la suite local dio 311/311 y 0 fallos (22 min 28 s). Causa: estado global (`get_tree().paused` e `InputMap`) que las suites no aíslan y gdUnit4 ordena distinto en Linux. Se corrigió con `before_test()` en `tests/ui/ajustes_prueba_test.gd`, `tests/ui/controls_panel_test.gd` y `tests/flows/beta_routes_test.gd`, sin tocar ningún `assert` (24/24 en esas suites, en local).
- El **segundo run no falló: fue cancelado** (`conclusion: cancelled`) a los 7 min 12 s por un push nuestro con `cancel-in-progress: true`; no había ningún `FAILED`. Diagnosticado contra la API con un subagente de solo lectura. Se ajustó `pruebas.yml` (`paths-ignore` para docs, sin run duplicado de PR, `timeout -k 30 1200`, job a 30 min y procedimiento de no empujar durante la verificación).
- **Run del HEAD final `3aed01f`: verde**, `311 test cases | 0 errors | 0 failures`, 7 min 46 s. Confirma los 3 `before_test()` en Linux. Además, sobre `f1f2297` el run de `push` dio 311/311 y el de PR dio 1 fallo en `test_ruta_fuerza_completa_los_cuatro_retos`: es intermitente, preexistente y ajeno a esta rama. Queda registrado como **P-39** para la post-beta, sin debilitar la prueba.
- Exportación local verificada: `godot --headless --export-release "Windows"` genera `bug_de_familia.exe` (109 MB) y `.pck` (20 MB) en `build/`. El workflow de exportación corre al fusionar en `main`.
- Capturas y vídeo reales de la zona beta generados con `tools/captura_partida.gd` sobre la Intel HD 520 (26 PNG + MP4). Sirven para validar que el entorno puede producirlas.
- Estudiado y descartado: servidores MCP (coste de contexto y dependencias), LSP (sin servidor para GDScript), plugins de marketplace de terceros, y el generador de imágenes de OpenCode (de pago, sin fondos). Ver `adr/0019-herramientas-ci-y-mcp.md`.
- Plantillas de mohócrata: SVG por código con la paleta y el rig actual, no integradas aún en el juego (ejemplo para el director).

## Herramientas de sesión (fusionado en `main` el 10-nov)

- `HERRAMIENTAS.md` reúne rutas, versiones, comandos y limitaciones. OpenCode lo carga al empezar cada sesión (`instructions` en `opencode.jsonc`). Decisión: `adr/0021-herramientas-al-iniciar-sesion.md`.
- Instalado el 10-nov: Playwright 1.65.0 con Chromium 158 (lo usa `tools/art/ground_gen.py`), Krita 5.3.4.1 y Audacity 4.0.2. Inventario y licencias en `DEPENDENCIAS.md`.
- Pendiente de probar en una sesión nueva. Antes hay que reiniciar la aplicación de OpenCode: el PATH nuevo solo llega a los procesos que arrancan después.
- Cuota: el 10-nov, `big-pickle` (modelo por defecto) respondió «Free usage limit reached». Si vuelve a pasar, aplica `FALLBACK_MODELS.md` y `adr/0020-tres-modelos-por-agente.md`.

## Post-beta (en curso en `main`, sin fusionar)

Trabajo de la fase acordada para P-1, P-2, P-3, P-4, P-5, P-6, P-10 y P-15 (P-16 descartado). Todo provisional y pendiente de revisión/validación manual en partida; sin commit, fusión ni push.

- **P-10:** ventana de propagación de rumores reducida a 7 s en `simulation/rumor_engine.gd`. Prueba actualizada: `res://tests/simulation/rumor_test.gd` (7/7) ejecutada en Windows (Godot 4.7.2 headless).
- **P-2:** los grupos engañados van a la zona indicada en el diálogo (`indicated`, centro del hogar contrario) sin salirse del mapa. Prueba: `res://tests/beta/group_diversion_test.gd` (2/2) ejecutada.
- **P-3:** de noche los Jubilados huyen/se esconden en su hogar sin devolver golpes y no atacan (`no_attack`, pasivos/investigando al hogar). Se ajustó `res://tests/beta/beta_zone_test.gd::test_power_off_at_night_is_only_an_advantage` al comportamiento decidido; suite `res://tests/beta/beta_zone_test.gd` (31/31) ejecutada. Pendiente validación manual.
- **P-4:** límite aleatorio y determinista (2-5, por `rng.randi_range`) de repeticiones por opción de conversación en PNJ/habitantes (`investigation/investigation_director.gd`, `simulation/live_dialogue.gd`); al agotarse la opción se oculta y provoca enfado/pelea inmediata. Conteos en memoria, no persistidos en guardado. Pruebas ejecutadas: `res://tests/investigation` (9/9) y `res://tests/simulation` (27/27). Pendiente afinar alcance/reaperturas y validación manual.
- **P-5:** duelo ~20 s reales junto a los muertos (`NpcState.mourn_until/mourn_at`, `LiveWorld` dirige al lugar y muestra reacción). Pendiente comprobar visibilidad al pasar cerca en partida y añadir/ajustar pruebas específicas si hace falta.
- **P-6:** habitantes con tamaño visual variable (30 %-80 %), mayoría adultos al nacer (~80 %) y niños que crecen a adulto a los 5 min reales (300 s de `sim.elapsed`, cambio único fijo). Aplica a nacimientos/recién llegados por el mismo camino de creación; solo visual (sin alterar colisiones, detección ni alcances). Pendiente revisión visual/rigs y pruebas específicas.
- **P-15/P-29 (parcial):** sonidos de pasos generados con `tools/audio/gen_audio.py --solo-sfx` (`audio/sfx/paso_01..06.ogg`), registrados en `data/audio/library.json`; reproducción posicional integrada (`audio/footstep_audio.gd`) en jugador y guardias. Sin voces nuevas. Pendiente validación manual de posicionalidad, volumen, bus y cobertura.
- **P-30:** analizado; no se aplica `WorkerThreadPool`. La simulación lógica avanza por pasos (`WorldSim` recorre habitantes, rumores, sucesos, misiones y festividades) sobre una población pequeña en la beta, sin medición en gráfica real que justifique paralelizar; repartirla complicaría el código y puede introducir fallos difíciles de reproducir. Pendiente medir en gráfica real si aparece necesidad.
- **P-25 (provisional):** 7 fotogramas por acción (idle/ataque/recarga) dibujados por código en el atlas SVG→PNG; `ActionFrameCatalog`/`ActionFrame` exponen el frame actual en protagonista y enemigos. La conexión con el combate es cosmética. Ver `adr/0024-fotogramas-por-accion.md`.
- **P-28 (provisional):** 4 `RichTextEffect` registrados en `IrcChat.log_view` con el mapeo aprobado por el director; la tartamuda repite letras; `reduce_motion` deja el texto plano; sin RNG global.
- **P-31 (provisional):** siluetas de edificios en `StrategyView._draw_map` con los rectángulos reales de `BetaLayout`, 5 llamadas de dibujo antes de los luchadores.
- **P-33 (provisional):** el aviso del chat pasa a ser un marco con relleno transparente, en vez de un relleno blanco que restaba contraste; respeta `reduce_motion`.
- **P-26 (opción 1a, aprobada por el director):** los fantasmas siguen solo en la pausa táctica y en la conversión. Se documenta el punto de enganche en `ui/ai_spectres.gd`: el futuro `ZoneLoader`/pantalla de viaje rápido creará el nodo con `AiTeam` y llamará a `set_shown(true)` mientras el juego esté parado. Queda **bloqueado** hasta que exista el gestor multi-zona (infraestructura post-beta, aún sin implementar). Duda abierta, sin resolver: si el tiempo del mundo avanza durante el viaje. No se ha creado ninguna pantalla de carga nueva.
- **P-26 (diseño del viaje, decidido por el director el 11-nov):** las IAs activas del destino se muestran como fantasmas durante la carga; tiempo mínimo de carga de **5 segundos**; si la apertura tarda más, se respeta ese tiempo. Sigue bloqueado hasta el gestor multi-zona.
- **P-37 (implementado el 11-nov):** al empezar la pelea el protagonista ataca solo. Al confirmar la pre-pausa (`FightDirector.confirm_pre_fight` arranca el combate con el nuevo `start_combat`) el combate se auto-engancha al guardia objetivo (`CombatSystem.engage`) sin orden del jugador (clic o conversación); el auto-ataque sale del propio `CombatSystem` (acercamiento + golpes en rango). Prueba nueva: `tests/sandbox/game_flow_test.gd::test_fight_starts_engaging_the_guard_without_player_order` (1/1). Suites `tests/sandbox` (28/28) y `tests/combat` (24/24) en verde. Pendiente: validación manual en partida y las dudas de diseño de P-37 (sustitución del ataque manual, alcance de armas, desactivación en opciones, sigilo).
- **P-37 (patrullas, implementado el 11-nov):** las patrullas desviadas ya no desaparecen para siempre. Al llegar al punto indicado se quedan allí (visibles e interactuables); en partida cargada se colocan directamente en ese punto. Pruebas: `tests/beta/group_diversion_test.gd` (2/2).\n- **P-1/P-39:** en `tools/beta_walker.gd` y `tests/flows/beta_routes_test.gd` se fijó/aisló estado y se añadió diagnóstico; además, durante las rutas se desactivan sucesos aleatorios del mundo (`EventSystem.timer` alto y colas vacías) para evitar muertes ajenas al recorrido por no determinismo de cadencia (posible causa de la intermitencia en Linux, run `42858970637`), sin relajar aserciones. Se corrigió el parseo de la prueba y se preserva `WorldCalendar.forced_local_unix` cuando un caso lo fuerza (fiesta). **Ejecutado en Windows:** `res://tests/flows/beta_routes_test.gd` con estabilización aplicada: rutas sigilo, palabra y fuerza (la intermitente en CI) y los casos de misión/fiesta/otra semilla pasaron en la ejecución final (6/6) tras corregir el manejo del día forzado. **No ejecutado:** confirmación determinista en Linux (10-20 repeticiones) ni identificación/reproducción del caído original si reaparece; P-39 sigue abierto para cierre definitivo.

**Pruebas ejecutadas (Windows, Godot 4.7.2 headless):** `tests/simulation/rumor_test.gd` 7/7, `tests/investigation` 9/9, `tests/simulation` 27/27, `tests/beta/group_diversion_test.gd` 2/2, `tests/beta/beta_robustness_test.gd` 11/11, `tests/beta/beta_zone_test.gd` 31/31, `tests/beta/music_test.gd` 5/5, `tests/beta/fight_groups_test.gd` 5/5, `tests/beta/battle_test.gd` 6/6, `tests/flows/input_flows_test.gd` 13/13, `tests/flows/beta_routes_test.gd` 6/6 (ejecución final, con estabilización y corrección de día forzado). `python tools/verificar.py`: OK. **No ejecutado:** suite completa en esta sesión tras todos los cambios, medición en gráfica real, ni validación manual en partida.

## Pasada correctiva visual (10-nov, fusionada en `main` por el PR #3)

Trabajo provisional de P-25, P-26, P-28, P-31 y P-33, más la regla del `.exe` en cada fusión (`adr/0023-exe-en-cada-fusion.md`) y la rotación de `explore` a Go (`adr/0022-rotacion-explore-a-go.md`). Fase cerrada administrativamente: PR #3 fusionado en `main` el 10-nov (HEAD `fd9366e1`, 329 pruebas, 0 fallos).

**Recursos generados (origen y herramienta):** `art/beta/atlas/piezas.png` y `data/art/atlas_piezas.json` se regeneraron con `tools/art/piece_atlas_gen.gd` (Godot 4.7.2 consola) el 10-nov, desde los SVG propios de `art/beta/rig/` más 7 fotogramas dibujados por código con `Palette`: 55 piezas, 170 de 2048 px. `data/art/action_frames.json` es catálogo escrito a mano. Detalle en `adr/0024-fotogramas-por-accion.md`. Se añadió `tools/verificar_apis_godot.gd` para comprobar las APIs contra el motor instalado.

**Pruebas ejecutadas (Windows, Godot 4.7.2 headless):** `python tools/verificar.py` OK (48 comprobaciones, 24 archivos; 274 archivos de texto sin errores); `tools/verificar_apis_godot.gd` 0 errores; `validar_datos.py --actualizar` OK; **329 pruebas GdUnit por carpetas, 0 fallos y 0 errores** (ui 28, art 17, data 7, core 20, entities 5, combat 24, conversion 25, ai 37, body 14, investigation 9, simulation 27, stealth 7, sandbox 27, beta 63, flows 19). Incluyen 18 pruebas nuevas; no se desactivó ni debilitó ninguna. Semilla 1234 en simulación. Un fallo inicial por precisión de `lerpf` y un warning de shadowing se corrigieron en el código (parámetro `strength`) y en el comparador (`is_equal_approx` con tolerancia), sin relajar ninguna aserción.

**Exportación local:** preset «Windows». Regenerada el **11-nov 00:14** tras la corrección de «Esc: salir» y la opción C: `build/bug_de_familia.exe` (109 MB) y `build/bug_de_familia.pck` (20,9 MB). Incluye los cambios de esta fase y se generó antes de la fusión del PR #3; conforme a `adr/0023-exe-en-cada-fusion.md` se regenera antes de cada fusión posterior.

**Observación del director (10-nov, a ojo, sin medición):** el `.exe` local «de velocidad va perfecto». No sustituye a la medición formal con `MEDIR.bat` en gráfica real, que sigue sin hacerse.

**Corrección tras la revisión del director (10-nov):** al elegir «solo mirar» la vista de estrategia se abre sola y M no hace nada, porque M **solo abre** (`02_DECISIONES.md:148`). La ayuda de la vista decía «M: salir», contradiciendo esa decisión: se corrige a «Esc: salir» y se aclara en `docs/controles.md`. Se añaden pruebas de M/Esc y del texto de ayuda.

**P-31, opción C aprobada por el director (10-nov):** los edificios no se veían porque el encuadre a zoom 1,9 los reducía a franjas de 84–152 px. Cálculo estimado con `brawl_patrol` (**no** medido en partida): con zoom 0,6 entran como bloques de 264–320 px y la ciudad completa (hace falta un zoom de 0,659 o menos). Se baja `ZOOM_MIN` de 0,7 a **0,6** y se añade un **alejazo puntual y rápido** al abrir la vista y al caer un luchador, solo en la vista de estrategia, respetando `reduce_motion` y con decaimiento en tiempo real (no se acelera a x4). Ver `adr/0025-alejazo-vista-estrategia.md`. Los edificios **no** se ven de forma permanente, solo durante el alejazo; el minimapa fijo (opción A) queda sin hacer. El diagnóstico con Godot sobre la escena real se colgó en `debug>` y se canceló; las cifras son analíticas.

**Ajuste provisional (11-nov):** al criticar el director que el alejazo «va muy rápido», `PULSE_DECAY` sube de **2,5** a **1,2** en `ui/strategy_view.gd` (decaimiento ~0,83 s de tiempo real frente a 0,4 s); la prueba `test_el_pulso_aleja_el_zoom_y_decae_en_tiempo_real` se ajustó a ese nuevo valor y sigue verde. `ZOOM_MIN = 0,6` (aprobado), `ZOOM_MAX = 1,9` y `ACTION_SHOW_TIME = 0,5 s` siguen provisionales.

**Reducción de movimiento (11-nov):** se cierra el hueco detectado en la validación: el temblor del veredicto de conversión (`ConversionScreen.show_verdict`) respeta ahora `GameSettings.reduce_motion`; con la opción activa no tiembla. Pruebas: `tests/conversion/conversion_test.gd` (12/12, con 2 casos nuevos sobre el veredicto). Con esto, «Reducir temblores y destellos» desactiva el pulso de la vista de estrategia, los efectos de texto, el flash/impacto y el grano.

**No ejecutado:** suite completa en un solo comando (cubierta por carpetas), validación manual en partida, medición en gráfica real y arranque del `.exe` exportado. P-39 sigue abierto para cierre definitivo en Linux.

**Pendiente de validación manual:** aspecto de los fotogramas, efectos de texto por IA, marco del chat y siluetas de edificios en la vista de estrategia.

## P-40 (fusionado en `main`)
- Grupos desviados al hablar con ellos ahora siguen la ruta de `NavGrid` (sin atravesar edificios): `scenes/beta/beta_challenges.gd`. Prueba: `tests/beta/group_diversion_test.gd` 2/2. Otros movimientos ordenados (habitantes/guardias) ya usaban `nav` y no se vieron afectados.

## Preparar el entorno en una conversación nueva

En Windows, rutas y comandos: `HERRAMIENTAS.md`. Los pasos siguientes son de Linux.

1. Clonar `rvillalba1983/bug-de-familia`. Si la copia es superficial, usar `git fetch origin main` y `FETCH_HEAD`.
2. Descargar `Godot_v4.7.2-stable_linux.x86_64.zip` de `github.com/godotengine/godot-builds/releases/download/4.7.2-stable/`.
3. Importar: `godot --headless --import`. Plantillas de exportación: `Godot_v4.7.2-stable_export_templates.tpz`, en `~/.local/share/godot/export_templates/4.7.2.stable/`.
4. Probar siempre con `timeout` y `</dev/null`, porque un error de script abre un `debug>` que se queda colgado:
   `timeout 300 godot --headless -s -d res://addons/gdUnit4/bin/GdUnitCmdTool.gd --ignoreHeadlessMode -a res://tests -c 2>&1 </dev/null`
5. Capturas: `LIBGL_ALWAYS_SOFTWARE=1 xvfb-run -a -s "-screen 0 1920x1080x24" godot --rendering-driver opengl3 --path . -s script.gd`

## Forma de trabajar con Git
- Una rama por fase y **siempre Pull Request** a `main` (decisión del director del 10-nov); nada de fusión directa en local. `merge --ff-only` solo en el caso excepcional autorizado. Ver `adr/0023-exe-en-cada-fusion.md`.
- Antes de pedir la fusión del PR: generar el `.exe` en `build/` (preset «Windows»), actualizar este archivo y dejar el CI verde. El director aprueba la fusión; después se avisa del cambio de conversación.
- Las ramas remotas las borra el usuario.
- Los documentos cambiados se copian al proyecto de Claude, en `Videojuego/Desarrollo/`. El repositorio manda.

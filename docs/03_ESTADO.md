# Estado del desarrollo

> **TRASPASO (actualizar en cada sesiÃ³n):**
> - **Estado (23-nov, fase EN CURSO):** `fase/cierre-consistencia-mundo-completo`
>   (sin fusionar todavía). Cierre documental de P-58, rotación de
>   `documentacion` a `big-pickle` (ADR 0042), P-26 y P-32, y pruebas de
>   integridad del arte. Sin arte nuevo, sin cambios en datos ni herramientas.
>   **Verificación final (24-nov, ejecutada):** `verificar.py` OK (105
>   comprobaciones), import sin errores, **suite completa 539/539** (79 suites,
>   informe JUnit validado: 0 fallos, 0 errores, 0 omitidos), `.exe` regenerado
>   (109 MB, `.pck` 34,9 MB) con **prueba de humo OK** (`despliegue_cero`,
>   36 habitantes). Sin ejecutar: medición en gráfica real y validación manual.
>   **Decisión del director (23-nov, P-61, ADR 0043):** los progenitores deben
>   seguir visibles tras morir; se conservan insulto, pelea, flag y frase de
>   lore. NO implementada aquí: va en la fase nueva de zonas.
>   **Fase siguiente pedida por el director (23-nov):** poblar e interactuar
>   con NPCs en las 24 zonas y añadir cosas que hacer en `despliegue_cero`;
>   se empieza por interacción y actividades, y el arte visual de todas las
>   zonas queda para otra fase. Abrir en conversación nueva.
> - **Estado (23-nov, cierre de fase):** «P-58: arte de los 15 progenitores»
>   **fusionado en `main`** (PR #43, merge `1867e68`, aprobado por el director;
>   CI verde 6/6). **Cambiar de conversación.** Hecho: los 75 SVG geométricos
>   de los 15 progenitores se han sustituido por arte artístico (5 vistas).
>   15 bases generadas con Recraft, 17 direccionales con MAI/Seedream y 43
>   derivadas con el fallback determinista aprobado por el director al
>   agotarse los créditos de los modelos. Formato intacto: 256 × 280,
>   `viewBox 0 0 512 560`, PNG embebido y fondo transparente; sin tocar lógica
>   ni datos. Añadidos `tools/art/progenitores_prompts.py`,
>   `progenitores_raster_a_svg.py` y `progenitores_derivar_vistas.py`,
>   `art/shared/progenitores/ORIGEN.md`, ADR 0041 y
>   `tests/art/art_progenitores_test.gd`. **Revisión visual aprobada por el
>   director (23-nov).** **Ejecutado:** 49/49 en `tests/art` (4 nuevos),
>   `verificar.py` OK, import sin errores y `.exe` regenerado (104,2 MB,
>   `.pck` 33,2 MB). CI del PR #43 verde 6/6: **530/530 pruebas** en 77 suites
>   (core 79, combate 69, simulación 164, despliegue_cero 218), arranque y
>   verificaciones deterministas OK. Ver `adr/0041`.
> - **Estado (23-nov, cierre de fase):** «P-60 + P-59: rutas y avisos de IA»
>   **fusionado en `main`** (PR #42, aprobado por el director; CI verde).
>   **Cambiar de conversación.** Hecho: P-60 (Don Ramón no se queda parado en
>   `despliegue_cero`: tramo norte de `ramon_route` termina en x=1650, antes de
>   la fachada del corredor; prueba de regresión `ramon_route_test.gd` con 2
>   casos). P-59 (avisos automáticos de las IAs en el chat cuando nace un rumor
>   y cuando un grupo migra entre zonas: señales `WorldSim.rumor_born` y
>   `ZoneManager.population_migrated` → `AiChatter`, conspi/matriz, sin tokens,
>   cadencia y anti-spam). **SUPERADA (23-nov): P-58 (arte definitivo de
>   progenitores) ya NO queda pendiente**; se completó el 23-nov en el PR #43
>   con 75 SVG artísticos (ADR 0041). La reversión a los 75 SVG originales
>   era el estado de aquel momento.
>   **Pruebas: 525/525 en verde** (75 suites), `verificar.py` OK, informe JUnit
>   validado. `.exe` regenerado en `main` (104,2 MB, `.pck` 29,9 MB).
>   Validación manual pendiente: ver los avisos de IA en partida y confirmar
>   que Don Ramón recorre su ruta sin pararse. Ver `adr/0038` y
>   `adr/0041`.
> - **Estado (22-nov, cierre de fase):** «Mundo completo: mapa y consecuencias»
>   **fusionado en `main`** (PR #41, merge `ac52ad0`, aprobado por el director;
>   CI verde 6/6). **Cambiar de conversación.** Hecho: mapa ratificado (24
>   zonas y grafo actual), viaje por rumor con avance del tiempo y escala
>   30-80 % para toda la población. **515/515 pruebas en verde** (73 suites,
>   informe JUnit validado), `verificar.py` OK. `.exe` regenerado en `main`
>   (104,2 MB, `.pck` 29,6 MB) y **validado por el director**.
>   **SUPERADA (23-nov):** P-58 (arte artístico con modelo para los 15,
>   recreando a Don Ramón y El Contestador) ya no queda para una fase posterior:
>   se completó en el PR #43. Ver ADR 0041 (arte) y 0040 (rotación de modelo).
> - **Estado (22-nov, esta fase):** `fase/p60-p59-p58-rutas-avisos-arte` (no fusionada todavía).
>   **P-60 corregido y commiteado:** Don Ramón rehace su ruta en `despliegue_cero`
>   (`data/zones/despliegue_cero.json`, tramo norte hasta x=1650 antes de la
>   fachada del corredor) con `tests/despliegue_cero/ramon_route_test.gd` (2
>   casos). **P-59 implementado y commiteado:** `WorldSim.rumor_born` +
>   `ZoneManager.population_migrated` → `AiChatter` (conspi/matriz, sin tokens,
>   cadencia y anti-spam), pruebas nuevas en verde. `verificar.py` OK.
>   **SUPERADA (23-nov): P-58 (arte definitivo de progenitores) ya no queda
>   pendiente**; se completó el 23-nov en el PR #43 con 75 SVG artísticos
>   (ADR 0041). La reversión a los 75 SVG originales era el estado de ese
>   momento. La rama estaba lista para PR con P-60 y P-59.
> - **Estado (22-nov, P-59):** las IAs deben avisar en el chat cuando se crea un
>   rumor y cuando un grupo de NPCs se mueve entre zonas.
> - **Estado (22-nov):** fase «Post-beta: progenitores y contenido»
>   **fusionada en `main`** (PR #40, merge `5a89df2`, aprobado por el director;
>   CI verde 6/6). **Cambiar de conversación.** Hecho: **75 SVG propios**
>   (15 progenitores × 5 vistas) con campo `art` conectado; **15 árboles de
>   diálogo** con saludo, versión, pista, seguir/insultar y consecuencia de
>   lore al morir (mortalidad aprobada); Don Ramón y El Contestador enganchados
>   en `despliegue_cero` sin romper la bobina; `fiador` convertido en actor
>   progenitor en `lonja`. Se incluyen además ADR 0037 (limpieza de logs) y la
>   rotación de `explore` a `beam-free`. `.exe` regenerado en `main`
>   (104,2 MB, `.pck` 29,4 MB). **Pruebas: 506/506 en verde** (72 suites;
>   9 nuevas de progenitores), `verificar.py` OK e informe JUnit validado.
>   Validación manual pendiente: ver los encuentros en partida, el insulto →
>   pelea y la bobina. Ver `adr/0038-encuentros-progenitores-y-arte.md`.
> - **Estado (21-nov):** fase «Progenitores en zonas»
>   **fusionada en `main`** (PR #39, merge `83f02a1`, aprobado por el director;
>   CI verde). **Cambiar de conversación.** Hecho: 13 progenitores restantes
>   asignados a sus zonas como actores pasivos con ruta; `guard_visual` tolera
>   vistas faltantes; `content_test` acepta progenitores. `.exe` regenerado
>   en `main` (104,2 MB, `.pck` 28,5 MB). Pruebas: 497/497. **Siguiente
>   fase:** arte dedicado de los progenitores y encuentros/diálogo.
> - **Estado (21-nov):** fase «P-37 solo autoataque + datos de progenitores»
>   **fusionada en `main`** (PR #38, merge `5a758ba`, aprobado por el director;
>   CI verde). **Cambiar de conversación.** Hecho: P-37 (solo autoataque),
>   P-35 (marcado hecho), P-39 (marcado hecho), datos de los 15 progenitores
>   (zona/color/art provisional). `.exe` regenerado en `main` (104,2 MB,
>   `.pck` 28,5 MB). Pruebas: 497/497. **Siguiente fase:** contenido de los
>   13 progenitores restantes y población de las 24 zonas.
> - **Estado (20-nov, noche):** fase «P-39 estabilización de rutas en Linux»
>   **fusionada en `main`** (PR #37, merge `783c4e3`, aprobado por el director;
>   CI verde). **Cambiar de conversación.** Hecho: `WorldSim.stabilized` para
>   omitir subsistemas aleatorios en las rutas; P-39 cerrado. `.exe`
>   regenerado en `main` (104,2 MB, `.pck` 29,3 MB). Pruebas: 6/6 rutas y
>   34/34 simulación. **Siguiente fase:** definir con el director.
> - **Estado (20-nov, noche):** fase «P-41 señalización de caminos»
>   **fusionada en `main`** (PR #36, merge `93a92f1`, aprobado por el director;
>   CI verde). **Cambiar de conversación.** Hecho: campo `distance` (metros) en
>   `geometry.corridors` de las 24 zonas, expuesto en `ZoneDefinition.corridors()`
>   y mostrado en los carteles de boca como «Destino → N m». `.exe`
>   regenerado en `main` (104,2 MB, `.pck` 29,3 MB). Pruebas: 497/497
>   (60/60 en `tests/zones`). **Siguiente fase:** definir con el director.
> - **Estado (20-nov, noche):** fase «P-42 lotes de conversaciones y P-43»
>   **fusionada en `main`** (PR #35, merge `3ee9ebc`, aprobado por el director;
>   CI verde). **Cambiar de conversación.** Hecho: P-42 completo (150
>   conversaciones por raza, 900 en total, catálogos en
>   `data/conversation/`, validador `tools/validar_conversaciones.py`,
>   pruebas en `tests/simulation/live_dialogue_test.gd`) y P-43 (pantalla
>   «Conoce la historia» con 20 carteles y textos corregidos). `.exe`
>   regenerado en `main` (104,2 MB, `.pck` 29,3 MB). Pruebas: 497/497
>   (70 suites, informe JUnit validado). **Siguiente fase:** definir con el
>   director. Ver `01_CONFLICTOS_Y_PENDIENTES.md`.
> - **Estado (20-nov, cierre de contenido):** rama `fase/p42-lotes-conversaciones`
>   **abierta, sin fusionar**. **P-42 completo:** 150 conversaciones por raza
>   (900 en total) generadas desde los bancos `tools/conversaciones/<especie>.py`
>   con `tools/gen_conversaciones.py`, guardadas en
>   `data/conversation/live_<especie>.json`. Validador nuevo
>   `tools/validar_conversaciones.py`, integrado en `verificar.py` (900
>   conversaciones, 0 fallos). Pruebas: 3 casos nuevos en
>   `tests/simulation/live_dialogue_test.gd` (150 por especie, formato y
>   acciones válidas, y reparto sin repetir entre habitantes de la misma zona)
>   más los 2 que ya había. **P-43:** la pantalla «Conoce la historia» pasa de
>   12 a 20 carteles (hechos compartidos 01-07, especies 08-19 y quince
>   progenitores) y corrige los textos que contradecían `50_lore.md`; 1 caso
>   nuevo en `tests/ui/history_screen_test.gd`. **Ejecutado en Windows:**
>   `verificar.py` OK, **suite completa 497/497** (70 suites, informe JUnit
>   validado) y 9/9 en las dos suites tocadas. **No ejecutado:** CI, `.exe` y
>   validación manual en partida. Ver `docs/50_lore.md` y
>   `tools/validar_conversaciones.py`.
> - **Estado (20-nov, noche):** fase «P-14, P-34, P-35, viaje rápido con coste,
>   nocturnos y lote P-42» **fusionada en `main`** (PR #34, merge `3aeb3f5`,
>   aprobado por el director; CI verde). **Cambiar de conversación.** Hecho:
>   P-14 (límite de rumores + espera), P-34 (duelo 20 s), P-35 (agotar pregunta
>   → pelea), coste de viaje rápido (piernas + tokens), jubilados nocturnos en
>   zonas genéricas, P-42 lote 1 (72 conversaciones + catálogo). `.exe`
>   regenerado (104,2 MB). Pruebas: 494/494.
> - **Estado (20-nov, tarde):** fase «Transiciones de zona (pantalla gris)»
>   **fusionada en `main`** (PR #33, merge `808c99e`, aprobado por el director;
>   CI 12/12). **Cambiar de conversación.** Hecho: `ZoneManager.process_mode`
>   forzado a `ALWAYS`, logging de fallos en `_complete_transition` y
>   `_on_transition_finished`, prueba `test_transition_hides_loading_when_zone_fails_to_load`.
>   `.exe` regenerado en `main` (104,2 MB). Pruebas: 493/493.
> - **Estado (20-nov):** fase «Robustez P-57» **fusionada en `main`** (PR #32,
>   merge `05a684e`, aprobado por el director; CI verde). **Cambiar de
>   conversación.** Hecho: corrección de `Guard._exit_tree()` (P-57) con
>   `is_instance_valid(_view)` y prueba `guard_exit_tree_test.gd` (1 caso).
>   `.exe` regenerado en `main` (104,2 MB) con humo OK. Pruebas: 492/492.
> - **Estado (19-nov):** fase «Culling de rigs y medición del 19-nov»
>   **fusionada en `main`** (PR #31, merge `68cc315`, aprobado por el director;
>   CI 6/6). **Cambiar de conversación.** **P-30 pasa a «implementado, con
>   medición posterior documentada»**: ocultado
>   de rigs fuera de cámara (`GuardVisual.set_visible`, llamado desde
>   `Guard._physics_process` tras `update_rig()`). Ver
>   `docs/adr/0036-culling-rigs-fuera-de-camara.md`.
>   **Medición completa del 19-nov 18:22 en gráfica real** (Intel HD 520,
>   `build/medicion/medicion.txt`, 84 líneas `RESULTADO`): ciudad 35,27 ms
>   (+3,5 %), caminando 148,58 ms (−3,0 %), pelea 71,34 ms (**+38,9 %,
>   REGRESIÓN**) y pausa 62,10 ms (+17,6 %) contra la referencia del 15-nov;
>   `verificar.py` falla solo por la mediana de pelea. La regresión queda
>   **documentada y no confirmada** (deriva de entorno y ANGLE; p99 dentro de
>   referencia). Decisión del director: documentar y seguir; **NO se actualizó
>   `tools/medir_windows/referencia.txt`**, no se subieron umbrales y no se
>   tocó código de rendimiento a ciegas. **Pruebas: 491/491 en verde** (69
>   suites, informe JUnit validado; 485 previas y 6 nuevas de
>   `tests/entities/guard_rig_culling_test.gd`, que fallan al revertir el
>   cambio). Rotación del agente `documentacion` por modelo retirado: ver
>   `FALLBACK_MODELS.md`. `.exe` regenerado en `main` con el preset «Windows»
>   (109 MB, `.pck` 29,5 MB) y **prueba de humo OK** (arranca, monta
>   `despliegue_cero`, 36 habitantes). CI del PR #31: **6/6 jobs en verde** en
>   las dos ejecuciones (runs 44597544363 y 44597589703; `despliegue_cero`
>   11m24s).
> - **Estado (18-nov):** Fase «Arte de personajes y delimitadores de caminos» **fusionada en `main`** (PR #29, merge `a8fd618`). Hecho: **P-52** (NPCs y dron a 8 direcciones: 14 SVG + 30 piezas de rig, joints medidos, atlas 90 piezas), **P-51** (17 gestos del protagonista: máquina de prioridades, rig por estado, 5 fotogramas nuevos, muerte propia, gestos sociales automáticos, cadena de fotograma por arma; cierra P-25), **P-53** (`corridors[].facades` con `CorridorFacade`, 4 fachadas SVG genéricas, 25 corredores de las 8 zonas + 5 de la zona cero convertidos de `walls`) y **P-54** (`despliegue_cero` ampliada a 4000×4000 con afueras de bosque y corredores nuevos). ADR 0035. **Pruebas: 485/485 en verde** (68 suites, informe JUnit validado), `verificar.py` OK, `.exe` (109 MB, `.pck` 29,3 MB) regenerado con humo OK (zona y 36 habitantes). Aviso: montar la zona cero pasa de ~0,23 s a ~1,0 s por NavGrid y `despliegue_cero_robustness_test` tarda 17-24 min (vigilar el CI). **Cambiar de conversación.**
> - **Rama en curso:** ninguna. La fase «Culling de rigs y medición del 19-nov»
>   **está fusionada en `main`** (PR #31, merge `68cc315`, 19-nov). Hecho:
>   **P-30** (ocultado de rigs de guardias fuera de cámara, `GuardVisual.set_visible`),
>   medición completa del 19-nov documentada en el ADR 0036 y **P-57** (fallo
>   latente en `Guard._exit_tree()`, detectado al medir, sin corregir).
>   **Pruebas:** 491/491, `verificar.py` OK, `.exe` regenerado con humo OK.
>   **Siguiente fase:** definir con el director. Ver `01_CONFLICTOS_Y_PENDIENTES.md`.
> - **QuÃ© se hizo en esa fase:** P-30 (mini-fase de rendimiento). `WorldSim._step()` paraleliza el `calm_down` de cada NPC con `WorkerThreadPool` (las tareas son independientes por NPC; los subsistemas siguen secuenciales por dependencias). `Guard._physics_process()` solo actualiza el detector si el guard estÃ¡ en pantalla (un guard fuera de pantalla no ve al jugador). ADR 0032.
> - **QuÃ© estÃ¡ probado (15-nov):** **405/405 en verde** en Windows y en el CI de Linux (core 52, combate 59, simulaciÃ³n 120, despliegue_cero 174). CI del PR #12: run 43726049209, 6 jobs en `success`. `verificar.py` OK. `.exe` exportado (109 MB) y **prueba de humo OK** (arranca, monta `despliegue_cero` con 36 habitantes). **Pendiente:** validaciÃ³n manual en partida y mediciÃ³n en grÃ¡fica real (para verificar la mejora de P-30). **Siguiente paso:** cambiar de conversaciÃ³n y abrir la fase de P-42 y P-43.
> - **QuÃ© se hizo en esa fase:** P-09 (12 preguntas nuevas para las 4 razas: 76 â†’ 88), P-29 (sonido direccional: oclusiÃ³n por muro en los pasos y timbre propio por IA, sin generar voces nuevas), P-30 (**decidido: no se aplica `WorkerThreadPool`**, falta mediciÃ³n en grÃ¡fica real que lo justifique), P-32 (el chat solo enseÃ±a los retos conocidos y no completados; el estado `known` persiste al guardar y recargar), P-36 (maximizado, ya estaba implementado: `project.godot` â†’ `window/size/mode=2`, commit `8559afc`), P-39 (logging del caÃ­do en el fallo de Linux, y `battle_test.gd` ya no depende de la cadencia de la mÃ¡quina, que era el origen del fallo intermitente) y P-41 (carteles de entrada a cada zona, estilo pueblos de EspaÃ±a). AdemÃ¡s, higiene del CI: los artefactos se conservan 1 dÃ­a y se borran los anteriores antes de subir el nuevo.
> - **QuÃ© estÃ¡ probado (15-nov):** **405/405 en verde** en Windows y en el CI de Linux, por los mismos grupos: core 52/52, combate 59/59, simulaciÃ³n 120/120 y despliegue_cero 174/174. CI del PR #11: run 43711223940, 6 jobs en `success` (incluye el arranque del binario exportado en Linux). `python tools/verificar.py` OK. `tools/verificar_apis_godot.gd`: 0 errores. `.exe` exportado (109 MB) y **prueba de humo OK** (arranca, monta `despliegue_cero` con 36 habitantes). Pruebas nuevas: `tests/despliegue_cero/chat_topics_test.gd` (9 casos, P-32) y `tests/core/audio_direccional_test.gd` (13 casos, P-29).
> - **QuÃ© no estÃ¡ probado:** validaciÃ³n manual en partida (el director la hizo en local y fue bien) y mediciÃ³n en grÃ¡fica real. Pendiente de revisar en partida: el timbre de cada IA, que el paso tapado se distinga del claro, la lista de retos del chat y los carteles de entrada. **Siguiente paso:** cambiar de conversaciÃ³n y abrir la fase de P-42 y P-43.
> - **Rama fusionada anterior:** `fase/conversaciones-ramificadas` â€” **fusionada en `main`** (PR #10, merge `5ad15b9`). Conversaciones ramificadas: ampliaciÃ³n de nodos del caso, paso APPROACH en conversiÃ³n, rama Â«newsÂ» en LiveDialogue. Pruebas: conversion 27/27, investigation 9/9, simulation 29/29, flows 13/13, verificar.py OK. `.exe` regenerado (109 MB). **Siguiente paso:** validaciÃ³n manual en partida o nueva fase.
> - **Rama anterior:** `estabilizacion/p39-y-datos` â€” **fusionada en `main`** (PR #9). Rivales aplicados (ecoâ†”manada, gruxâ†”plegado), nombre fijo Â«Despliegue CeroÂ», P-39 estabilizado (rutas 6/6 en verde, Linux incluido), aviso lambda corregido, anotaciones de diseÃ±o futuro (conversaciones, arte, audio). Pruebas: rutas 6/6, zona 31/31, CI verde (6 jobs). `.exe` regenerado (109 MB). **Siguiente paso:** validaciÃ³n manual en partida, mediciÃ³n en grÃ¡fica real, o nueva fase de contenido.
> - **QuÃ© se hizo:** renombrado de clases y rutas en 44 archivos `.gd`/`.tscn`, 20 literales `res://` rotos corregidos, 65 textos con mojibake restaurados en `species.json`, correcciÃ³n de la causa raÃ­z en `poblar_contenido.py`, 3 validadores nuevos (`validar_rutas.py`, `validar_informes.py`, `verificar_humo.py`) que cierran el falso verde de GdUnit, matriz del CI con suelos por grupo y job `arranque`. DecisiÃ³n tÃ©cnica validada en `adr/0028-validacion-arranque-y-ci.md`.
> - **QuÃ© estÃ¡ probado:** `verificar.py` OK; import limpio; 372/372 pruebas (53 suites) con informe JUnit validado; `.exe` exportado (104 MB) y prueba de humo OK (zona `despliegue_cero`, protagonista, 36 habitantes).
> - **QuÃ© no estÃ¡ probado:** validaciÃ³n manual en partida y mediciÃ³n en grÃ¡fica real. P-39 estabilizado en Windows (rutas 6/6); confirmaciÃ³n en Linux pendiente de CI. Rivales y nombre definitivo de la zona decididos en esta fase. **Siguiente paso:** validaciÃ³n manual en partida y mediciÃ³n en grÃ¡fica real, o nueva fase de contenido.
> - **ReanudaciÃ³n de modelos (13-nov):** en esta rama los encargos se lanzan por tarea con modelos de OpenRouter: **MiniMax M3.1 Flash para tareas de ingenierÃ­a** y **GLM Flash para el resto** (qa, documentaciÃ³n, datosâ€¦). Es una asignaciÃ³n por tarea/sesiÃ³n: **NO tocar `tools/modelos_agentes.json` ni `opencode.jsonc`**, que siguen siendo la fuente persistente (ADR 0020). Los identificadores exactos son los que muestra `opencode run` en la cabecera al relanzar cada tarea; si fallan (429/402/404), aplicar `FALLBACK_MODELS.md`.

Se actualiza cada vez que una fase se fusiona en `main`.

| Fase | Estado |
|---|---|
| 0 a 7 | Fusionadas en `main` y probadas por el usuario |
| Arte | Estilo de la beta fusionado en `main`, ejecutado en Godot 4.7.2 el 9-nov: 187 pruebas pasan y el director aprobÃ³ capturas y vÃ­deo reales. Ver `adr/0008-estilo-visual-beta.md` |
| 7b. Pulido visual e interfaz | Fusionada en `main` y aprobada por el director el 9-nov, con los cuatro puntos del primer minuto (animaciÃ³n de enemigos, impacto, convertir y silueta). 203 pruebas pasan. Ver `adr/0009-pulido-primer-minuto.md`. El resto de la lista pasa a la fase 9, incluidas las opciones de reducir temblores y destellos |
| 8. Mundo vivo (zona beta) | Fusionada en `main` el 9-nov y aprobada por el director. 229 pruebas pasan. Ver `adr/0010-mundo-vivo-beta.md` |
| 9. Contenido y pulido | Fusionada en `main` el 9-nov y aprobada por el director. 255 pruebas pasan. Ver `adr/0011-ias-y-controles.md`, `adr/0012-batallas.md` y `adr/0013-audio-y-rendimiento.md` |
| Cierre de la beta | Fusionada en `main` el 9-nov con aprobaciÃ³n del director. 261 pruebas pasan. Ver `adr/0014-cierre-beta.md` |
| Arreglos tras probar la beta | Fusionada en `main` el 9-nov con aprobaciÃ³n del director. 266 pruebas pasan. Ver `adr/0015-arreglos-beta.md` |
| RevisiÃ³n de cÃ³digo, pruebas y rendimiento (P-24) | Fusionada en `main` el 9-nov con aprobaciÃ³n del director. 293 pruebas pasan. Ver `adr/0016-revision-codigo.md` |
| OptimizaciÃ³n en grÃ¡fica integrada | Fusionada en `main` el 9-nov con aprobaciÃ³n del director. 308 pruebas pasan. Ver `adr/0017-optimizacion-integrada.md` |
| Pruebas finales de la beta y dudas | Fusionada en `main` el 9-nov con aprobaciÃ³n del director. 311 pruebas pasan. Las pruebas del director en Windows siguen pendientes: harÃ¡ lista de lo raro durante la semana |
| ConfiguraciÃ³n de OpenCode, herramientas y CI | **Fusionada en `main` el 10-nov con aprobaciÃ³n del director.** Equipo de 10 agentes con tres modelos cada uno, entorno local gratuito, scripts deterministas, formatter propio y GitHub Actions (pruebas + exportaciÃ³n). 311 pruebas en verde en Windows y en el CI de Linux. Ver `adr/0018-agentes-y-modelos.md`, `adr/0019-herramientas-ci-y-mcp.md` y `adr/0020-tres-modelos-por-agente.md`. Queda P-39 (fallo intermitente preexistente) para la post-beta |
| Post-beta (mejoras grÃ¡ficas/UI/audio/sim) | **Fusionada en `main` el 10-nov por el PR #3** (HEAD `fd9366e1`), con 329 pruebas y 0 fallos. La fase visual (P-25, P-26, P-28, P-31 y P-33) quedÃ³ cerrada; implementado: P-36 (maximizado), P-38 (centrado conversiÃ³n), P-26 (fantasmas en conversaciÃ³n), P-33 (destello en chat), P-14 (lÃ­mite rumores), P-23/P-27/P-09 (lotes propuestos). Pendiente: ajustes provisionales de la fusiÃ³n y validaciÃ³n manual en partida; para la post-beta: P-29 (timbres) y P-39 (fallo intermitente en Linux). Ver `adr/0024-fotogramas-por-accion.md`, `adr/0025-alejazo-vista-estrategia.md` y `borradores/P-23_P-27_P-09_lotes.md`. |
| Contenido multi-zona (post-infraestructura) | **Fusionada en `main` el 13-nov por el PR #7** (merge `9e4c0c9`; `c020fe5` es el Ãºltimo commit de la rama fusionada, no la fusiÃ³n). Implementado: 4 especies nuevas (plegado, eco, grux, manada), 21 zonas esqueleto pobladas, El Enchufe y Lonja con contenido completo, renombrado beta â†’ despliegue_cero, arte compartido (art/beta â†’ art/shared), 12 SVG sprites nuevos. P-26 verificado. Ver `docs/34_zonas_y_contenido.md`. **CorrecciÃ³n del 13-nov:** la cifra Â«367 pruebas y 0 fallosÂ» **no estaba verificada** en el momento de la fusiÃ³n (el CI saliÃ³ verde pero no prueba el arranque). El renombrado beta â†’ despliegue_cero quedÃ³ incompleto y el `.exe` no arrancaba (incidente mÃ¡s abajo). **Resuelto el 13-nov por el PR #8**: 372/372 pruebas en verde, `.exe` arranca y monta `despliegue_cero`. El mundo completo queda **confirmado en arranque**; falta validaciÃ³n manual en partida y mediciÃ³n en grÃ¡fica real. |
| Contenido conversacional y zonas (14-nov) | **Fusionada en `main` el 14-nov** (merge `e510924`; fix de aserciones GdUnit en `c3a4e90`). UI centrada en ConversionScreen; `sad`, `role_lines` y 8 hechos de lore por especie; 8 zonas esqueleto con props/items/actors; CI a v7/v6/v7. CI verde tras el fix (run 43622689433: core 27s, simulaciÃ³n 1m21s, combate 30s, despliegue_cero 10m7s; arranque Linux OK). Ver `adr/0029-contenido-y-ui-conversion.md`. |
| Tareas crÃ­ticas post-beta (15-nov) | **Fusionada en `main` el 15-nov** (PR #11, merge `70ce93e`, con aprobaciÃ³n del director). Hecho: **P-09** (12 preguntas nuevas para las 4 razas, 76 â†’ 88), **P-29** (los pasos de los guardias suenan tapados si hay un muro con el jugador; cada IA tiene un timbre â€” radio, eco o distorsiÃ³n â€” con su propio bus y filtro, sin generar voces nuevas), **P-30** (decidido: no se aplica `WorkerThreadPool`, falta mediciÃ³n en grÃ¡fica real), **P-32** (el chat solo enseÃ±a los retos conocidos y no completados, y el estado `known` se guarda y se recarga), **P-36** (maximizado; ya estaba implementado, `window/size/mode=2`, commit `8559afc`), **P-39** (el test de rutas vuelca el caÃ­do, su especie, su posiciÃ³n y el estado del mundo cuando falla en Linux, y `battle_test.gd` ya no depende de la cadencia de la mÃ¡quina) y **P-41** (cartel de entrada por corredor, con el nombre de la zona destino, flecha y distancia). AdemÃ¡s, el CI conserva los artefactos 1 dÃ­a y borra los anteriores antes de subir el nuevo. **405/405 pruebas en verde** en Windows y en Linux (run 43711223940, 6 jobs en `success`); `.exe` exportado (109 MB) con prueba de humo OK. Ver `adr/0030-retos-conocidos-en-el-chat.md` y `adr/0031-sonido-direccional-y-timbre-ia.md`. Pendiente para la siguiente fase: P-42 (150 conversaciones por raza) y P-43 (pantalla de inicio y Â«Conoce la historiaÂ»). Ver `01_CONFLICTOS_Y_PENDIENTES.md`. |
| Contenido conversacional y pantalla de inicio (15-nov) | **Fusionada en `main` el 15-nov** (PR #13). Implementado: **P-42** (nodos de diÃ¡logo ramificados, 8-10 por raza) y **P-43** (pantalla Â«Conoce la historiaÂ»). **Pruebas:** 405/405. CI verde. `.exe` regenerado. |
| Patrullas y NPCs conversables (15-nov) | **Fusionada en `main` el 15-nov** (PR #14). Implementado: patrullas desviadas vuelven a su ronda tras 30 s; los 4 NPCs conversables del caso son mÃ³viles. **Pruebas:** 405/405. CI verde (run 43759648312). `.exe` regenerado (109 MB). |
| Conversaciones ampliadas (15-nov) | **Fusionada en `main` el 15-nov** (PR #15). Implementado: **P-45** (ampliaciÃ³n de nodos de diÃ¡logo, 12-15 por raza, mezcla de humor + lore + ramificaciÃ³n). **Pruebas:** 405/405. CI verde (run 43764022042). `.exe` regenerado (109 MB). |
| Pantalla de carga, conversaciones y estrategia (16-nov) | **Fusionadas en `main` el 16-nov** (PRs #16 a #21; `main` = `f17f2ed`). Hecho: **P-46** (25 nodos jubilado/mohÃ³crata), **P-47** y **P-49** (contenido con lore de todas las razas, hasta 40-50 nodos por raza), **P-48** (pantalla de carga con el protagonista y 2-3 NPCs de cada especie), **P-50** (vista de estrategia con sombras y edificios) y **P-23** (catÃ¡logo de 50 objetos graciosos convertibles). **Incidencia corregida:** la pantalla de carga de P-48 retrasaba la creaciÃ³n del menÃº inicial (`zone.overlay` nulo) y dejaba una seÃ±al colgada que abortaba el proceso en Linux (exit 134); arreglado en `aa5f60b` **sin tocar ninguna prueba**. Las ramas estaban apiladas y se rebasaron sobre el arreglo. **Pruebas:** CI verde en #16 a #21; `verificar.py` OK; `.exe` (104 MB) con prueba de humo OK. |
| Muertes bestiales (16-nov) | **Fusionada en `main` el 16-nov** (PR #22, `main` = `d489d10`). Hecho: **P-27** (13 muertes: `caida` + 12 gamberras, con `effect/color/duration`; 6 genÃ©ricas + 1 propia por especie; `DeathEffect` visual sin alterar reglas ni `corpse_time`). Ver `adr/0033-muertes-bestiales-p27.md` y `docs/borradores/P-23_P-27_P-09_lotes.md`. **Pruebas:** CI del PR #22 verde (6 jobs); `verificar.py` OK; `tests/data` + `tests/combat` 40/40 en local. `.exe` regenerado (104 MB). Pendiente validaciÃ³n manual en partida. |
| P-28 y zonas (16-nov) | **Fusionada en main el 16-nov** (PR #23). Hecho: **P-28** (pulido de efectos de texto del chat: amplitudes reducidas; pruebas unitarias 	ests/ui/text_effects_test.gd, 3 casos) y poblado de las zonas rchivo y samblea con contenido (props, items, convertibles, actores). **Pruebas:** CI verde (6 jobs); 
| Contenido lote 1 (16-nov) | **Fusionada en `main` el 16-nov** (PR #27). Hecho: 3 zonas pobladas (colmena, atajo, cementerio), P-23 completo (50 objetos graciosos: 48 SVGs en `art/shared/props/`, 50 materiales en `data/conversion/catalog.json`, registro en `PropArt.BY_ID`), P-42 parcial (+10 nodos por raza) y el agente `arte` pasa a DeepSeek. **Pruebas:** CI verde; `verificar.py` OK; conversion 28/28 en local; content 9/9. `.exe` regenerado con humo OK. Pendiente: validacion manual en partida. |
| Contenido y diseño de zonas (17-nov) | **Fusionada en `main` el 17-nov** (PR #28, merge `942c5da`). Hecho: 8 zonas pobladas (cumbre, desguace, encrucijada, gran_cruce, gran_mercado, paso, poligono, taller); 10 SVG de señales; corredores físicos opt-in con muros de 200 u, fondo en bocas sur/este y cartel SVG + nombre de destino delante, con fallback para `despliegue_cero`; pantalla de carga con imagen del director a pantalla completa y carteles de menú compartidos con «Conoce la historia»; títulos de transición por encima de los fantasmas; referencias de datos actualizadas; P-51 a P-55 apuntados. **Pruebas:** 429/429 en verde, `verificar.py` OK, `.exe` (109 MB) con humo OK. Ver `adr/0034-corredores-fisicos.md`. Pendiente: validación manual en partida y medición en gráfica real. |
| Arte de personajes y delimitadores (18-nov) | **Fusionada en `main`** (PR #29, merge `a8fd618`, aprobado por el director; CI 6/6). Hecho: **P-52** (8 direcciones en NPCs y dron, 14 SVG + 30 piezas de rig, joints medidos, fallback retirado); **P-51** (17 gestos del protagonista, máquina de prioridades, rig por estado, 5 fotogramas nuevos, muerte propia, gestos sociales automáticos y cadena de arma; cierra P-25); **P-53** (`facades` en corredores con `CorridorFacade`, 4 fachadas SVG, 30 corredores convertidos); **P-54** (`despliegue_cero` a 4000×4000 con afueras de bosque). ADR 0035. **485/485 pruebas en verde** (68 suites, JUnit validado), `verificar.py` OK, `.exe` (109 MB) con humo OK. Aviso: montar la zona cero pasa de ~0,23 s a ~1,0 s y el test de robustez tarda 17-24 min (vigilar CI). |
| Fachadas por zona e identidad visual (18-nov) | **Fusionada en `main`** (PR #30, merge `81589a9`, aprobado por el director). Hecho: **P-56** (32 fachadas SVG propias para las 8 zonas del PR #28: cumbre, desguace, encrucijada, gran_cruce, gran_mercado, paso, poligono, taller; paleta por lore; sistema `CORRIDOR_FACADE_ART_BY_ZONE` en `ZoneBase` sin tocar datos ni lógica de montaje; generador `tools/gen_fachadas_zona.py`) y **P-31** (StrategyView dibuja las fachadas de corredor de la zona actual). P-30 no aplicado (sin medición). **Pruebas:** zones 59/59, `verificar.py` OK, `.exe` regenerado con humo OK. |
| Culling de rigs y medición del 19-nov (P-30) | **Fusionada en `main`** (PR #31, merge `68cc315`, aprobado por el director; CI 6/6). Hecho: ocultado de rigs fuera de cámara (`GuardVisual.set_visible` + llamada en `Guard._physics_process`); ver `adr/0036-culling-rigs-fuera-de-camara.md`. Medición completa del 19-nov en gráfica real: pelea +38,9 % **no confirmada** (deriva de entorno/ANGLE); la referencia del 15-nov **sin cambiar**. Pruebas: 491/491 en verde (69 suites, JUnit validado), `verificar.py` OK. `.exe` regenerado (109 MB, `.pck` 29,5 MB) con humo OK (zona y 36 habitantes). Ver «Medición en gráfica real del 19-nov» más abajo. |
| Robustez P-57 (20-nov) | **Fusionada en `main`** (PR #32, merge `05a684e`, aprobado por el director). Hecho: corrección de `Guard._exit_tree()` (P-57) con `is_instance_valid(_view)` para evitar el `SCRIPT ERROR` cuando el suelo se libera antes que el guardia; prueba `guard_exit_tree_test.gd` (1 caso). Pruebas: 492/492 en verde. `.exe` regenerado (104,2 MB) con humo OK. |
| Transiciones de zona (20-nov) | **Fusionada en `main`** (PR #33, merge `808c99e`, aprobado por el director; CI 12/12). Hecho: `ZoneManager.process_mode = ALWAYS` para que el temporizador de transición avance aunque el árbol esté pausado; logging de fallos en `_complete_transition` y `_on_transition_finished`; prueba `test_transition_hides_loading_when_zone_fails_to_load`. Pruebas: 493/493 en verde. `.exe` regenerado (104,2 MB) con humo OK. |
| P-14/P-34/P-35/viaje/nocturnos/P-42 (20-nov) | **Fusionada en `main`** (PR #34, merge `3aeb3f5`, aprobado por el director; CI verde). Hecho: P-14 (límite de rumores + espera 10 s), P-34 (duelo 20 s), P-35 (agotar pregunta → pelea), coste de viaje rápido (piernas + tokens), jubilados nocturnos en zonas genéricas, P-42 lote 1 (72 conversaciones + `ConversationCatalog`). Pruebas: 494/494 en verde. `.exe` regenerado (104,2 MB) con humo OK. |
erificar.py OK. .exe regenerado. Pendiente validación manual en partida. |

## Incidente de arranque tras el PR #7 (13-nov)

Tras fusionar el PR #7, el `.exe` local y el de GitHub no arrancan. ReproducciÃ³n documentada:

- **Comando:** `build/bug_de_familia.exe --headless --quit-after 60 --log-file C:/Users/usuario/AppData/Local/Temp/opencode/arranque-roto.log` (Godot 4.7.2). El log se conserva en esa ruta.
- **Errores literales del log:**
  - `Parse Error: Identifier "BetaLayout" not declared in the current scope.` â€” `res://scenes/zones/zone_base.gd:459`.
  - `Parse Error: Could not find type "BetaZone" in the current scope.` â€” `res://conversion/action_system.gd:178`, `180`, `267` y `271`.
  - Fallos de compilaciÃ³n en cascada por scripts dependientes: `res://scenes/sandbox/sandbox.gd`, `res://simulation/zone_manager.gd` y `res://scenes/world/world.gd` (Â«Failed to compile depended scriptsÂ»).
  - `ERROR: ZoneManager: la zona de inicio Â«betaÂ» no existe` y `ERROR: GameWorld: no se pudo montar la zona inicial`.
- **Causa raÃ­z:** el renombrado beta â†’ despliegue_cero quedÃ³ incompleto: siguen existiendo referencias a clases renombradas (`BetaLayout`, `BetaZone`) y la zona de inicio Â«betaÂ» ya no existe. El guardado heredado pide una zona que ya no existe.
- **LecciÃ³n:** el CI saliÃ³ verde, pero un CI verde aquÃ­ **no valida el arranque del `.exe` ni garantiza que las 367 pruebas se ejecutaran**; el conteo de pruebas y el arranque hay que verificarlos aparte. DecisiÃ³n tÃ©cnica validada en `adr/0028-validacion-arranque-y-ci.md`.
- **ResoluciÃ³n (13-nov, PR #8):** renombrado completado (0 referencias viejas), 372/372 pruebas en verde con informe JUnit validado, `.exe` exportado (104 MB) y prueba de humo OK (zona `despliegue_cero`, 36 habitantes). Los tres validadores nuevos (`validar_rutas.py`, `validar_informes.py`, `verificar_humo.py`) detectan el fallo real del `.exe` antiguo (9 errores) y el falso verde (0 casos). Pendiente: validaciÃ³n manual en partida y mediciÃ³n en grÃ¡fica real.

## Pendiente de respuesta del usuario (no bloquea)
- Textos provisionales del caso y de las IAs.
- ADR 0027 (infraestructura multi-zona) registrado el 11-nov: decisiones de arquitectura acordadas, pendiente de implementaciÃ³n en la fase de infraestructura post-beta. Ver `docs/adr/0027-multi-zona.md`.
- **DiseÃ±o futuro (validaciÃ³n 13-nov):** en todos los mapas debe haber NPCs conversables en un ~40 % de la poblaciÃ³n, y todas las razas (incluidas las nuevas: plegado, eco, grux, manada) deben tener lÃ­neas de conversaciÃ³n. **Corregido el 14-nov:** la afirmaciÃ³n Â«hoy solo los NPCs especiales del caso son conversables; las 4 especies nuevas no tienen textosÂ» era falsa: las seis especies ya tenÃ­an texto en `data/world/species.json` y cualquier habitante abre `LiveDialogue`. Lo que faltaba era variedad, y en esta fase se amplÃ­a (4 o mÃ¡s frases por situaciÃ³n, clave `sad`, lÃ­neas por oficio, 8 hechos de lore). Sigue pendiente el criterio del ~40 % de habitantes conversables, que no estÃ¡ medido.
- **DiseÃ±o futuro (conversaciones, 14-nov):** tres mejoras de conversaciÃ³n posibles y no excluyentes, a secuenciar por tamaÃ±o: (1) ampliar nodos en el caso (barato, ya existe el sistema ramificado de `investigation`); (2) ramificar la conversiÃ³n (`conversion/`) con mÃ¡s opciones antes de convertir; (3) ramificar `LiveDialogue` (menÃº plano â†’ nodos de diÃ¡logo por raza/estado), la mÃ¡s grande y ligada al punto anterior de NPCs conversables ~40 %. **Estado tras el PR #10 (fusiÃ³n el 14-nov):** (1) y (3) tienen ya nodos (ampliaciÃ³n del caso y rama Â«newsÂ» de `LiveDialogue`); la conversiÃ³n sigue con un menÃº plano salvo el paso APPROACH. En esta fase se aÃ±ade ademÃ¡s la lÃ­nea de oficio como saludo.
- **DiseÃ±o futuro (arte, 14-nov):** revisar la carpeta `art/` para (a) organizar por subcarpetas por categorÃ­a/sistema (rig, shared, por zona, sprites, atlas, etc.) y (b) estudiar si los PNG generados estÃ¡n optimizados para Godot (tamaÃ±o, formato, compresiÃ³n, atlas) y si conviene reexportarlos o generarlos con parÃ¡metros mÃ¡s eficientes. Tarea de arte/rendimiento, no bloquea gameplay.
- **DiseÃ±o futuro (audio, 14-nov):** la mÃºsica actual a veces es muy estridente; se quiere un enfoque mÃ¡s ambiental y mayor variedad para evitar una canciÃ³n en bucle continuo. Explorar mÃºsica ambiental experimental: sonidos relajantes para zonas tranquilas, y sonidos que varÃ­en tempo/velocidad para provocar ansiedad en zonas de tensiÃ³n. **Preferencia de paleta sonora:** que todo suene a guitarra clÃ¡sica o instrumentos de cuerda pulsada de todo el mundo (guitarra, laÃºd, oud, shamisen, etc.). Tarea de audio/contenido, no bloquea gameplay.
- **DiseÃ±o futuro (UI conversiÃ³n, 14-nov):** en las pantallas de preguntas de conversiÃ³n, centrar mÃ¡s la pregunta y las frases de las IAs en la pantalla. Tarea de UI/visual, no bloquea gameplay. **Hecho en esta fase (14-nov):** el tÃ­tulo de la pregunta y el cuerpo del mensaje se centran en el panel, y la cuenta atrÃ¡s lleva un espacio compensatorio para que el tÃ­tulo no se descentre; las frases de las IAs ya estaban centradas y ahora lo cubren pruebas. La posiciÃ³n vertical del bloque no se cambia (ver `adr/0029-contenido-y-ui-conversion.md`); falta la validaciÃ³n manual en partida.
- **DecisiÃ³n tomada (validaciÃ³n 13-nov):** en zonas con una sola especie no se ofrece la opciÃ³n Â«malmeterÂ» (no hay rival presente). El sistema ya lo gestiona asÃ­ y se acepta.
- **MediciÃ³n en grÃ¡fica real (15-nov, esta fase):** el director ejecutÃ³ `MEDIR.bat` en la Intel HD 520. 0 regresiones contra la nueva referencia: ciudad 34,08 ms, caminando 153,11 ms, pelea 51,36 ms, pausa 52,82 ms (medianas, 12/12/6/6 rondas). El caminando sigue siendo el cuello de botella (6,5 fps). El desglose por partes muestra que **el coste estÃ¡ distribuido**: quitar personajes baja un 28 % y quitar el protagonista un 24 %, pero la fÃ­sica solo consume ~35 ms del fotograma de 153 ms; el resto es renderizado (draw_calls ~130-158). **Consecuencia:** la decisiÃ³n de P-30 (`WorkerThreadPool`) se **revierte** â€” ahora sÃ­ hay mediciÃ³n que la justifica, y pasa a la siguiente fase. La referencia anterior (7,20 / 18,60 / 11,20 / 16,40) era de la beta con una sola zona y no era comparable: daba regresiones artificiales del +200 % al +700 %. La nueva referencia es esta mediciÃ³n. Ver `tools/medir_windows/referencia.txt`.

## Medición en gráfica real del 19-nov (P-30)

Medición **completa** hecha por el director el 19-nov 18:22 en su Intel HD 520
(`MEDIR.bat`, archivo `build/medicion/medicion.txt`, 84 líneas `RESULTADO`,
36 rondas base y 48 con `quitar=`). Es medición **en gráfica real**.

| Caso | Referencia (15-nov) | Medición (19-nov) | Variación |
|---|---|---|---|
| ciudad | 34,08 ms | 35,27 ms | +3,5 % |
| caminando | 153,11 ms | 148,58 ms | −3,0 % |
| pelea | 51,36 ms | 71,34 ms | **+38,9 % (REGRESIÓN)** |
| pausa | 52,82 ms | 62,10 ms | +17,6 % |

- `python tools/verificar.py` falla **solo por la mediana de pelea**.
- **Regresión de pelea no confirmada** (análisis del medidor): hay deriva de
  entorno (los bloques `r`/`p1` corrieron un 30-45 % más lentos que `p2`/`t`
  sin cambio de guion, y la pelea solo corrió en el bloque lento); en
  `opengl3` la pelea sube +11,5 % (bajo el umbral) y la bandera la dispara
  ANGLE; el p99 está dentro de referencia en todos los casos. No hay medición
  del 15-nov por driver para comparar.
- Desglose `quitar=personajes`: en caminando solo baja 8-16 ms de ~150
  (6-10 %) y en ciudad 0-2 ms; el coste no está en los sprites de personajes.
- **Decisión del director (19-nov):** implementar igualmente el ocultado de
  rigs fuera de cámara (ver `adr/0036-culling-rigs-fuera-de-camara.md`) y
  **documentar y seguir** con la regresión de pelea: la referencia del 15-nov
  **NO se actualizó**, no se subieron umbrales y no se tocó código de
  rendimiento a ciegas. `verificar.py` seguirá dando la bandera mientras no
  cambie la referencia.
- **Sin medir:** el ahorro real del culling de rigs tras el cambio. La
  confirmación se hará en una medición nueva en gráfica real, con desglose
  por driver para aislar ANGLE.

## Tras la fase 6
- Los valores de daÃ±o, alcance y recarga del combate son provisionales (`docs/adr/0005-combate.md`).
- Los disparos solo afectan a guardias y tiradores, no a drones ni cÃ¡maras.

## Tras la fase 7
- Valores provisionales de la beta: `docs/adr/0006-zona-beta.md`.
- Las rutas de sigilo con enemigos activos tienen prueba automÃ¡tica en `tests/flows/beta_routes_test.gd`; el usuario ademÃ¡s las ha probado en partida.
- Sin hacer: viaje entre puntos de guardado y consecuencias al salir de la zona. La pieza que suelda Don RamÃ³n y la huella visible al morir un aliado Ãºnico ya estÃ¡n implementadas (`scenes/beta/beta_challenges.gd`, `tests/beta/beta_robustness_test.gd`). Lo decidido estÃ¡ en `02_DECISIONES.md`.

## Tras P-09 (lotes 1 y 2)
- 76 preguntas de conversiÃ³n, motes y comentarios del protagonista integrados. Valores provisionales: `docs/adr/0007-motes-y-comentarios.md`.
- Los comentarios solo salen en la zona beta y nadie los ha probado aÃºn en partida.
- Esperan a su sistema: comentarios de Cupido_Beta enamorada y del viaje rÃ¡pido, motes de las 14 IAs no jugables y las 12 preguntas reservadas de las otras cuatro razas (`docs/borradores/P-09_lote_2.md`).

## Tras la fase 7b
- Tiempos, temblor, zancada, deformaciÃ³n y colores de desgaste son provisionales. Los 12 textos de burla de las IAs estÃ¡n pendientes de la crÃ­tica del director (P-09).
- Rendimiento sin medir en una grÃ¡fica real: las pruebas dibujan por software.
- Sin revisar: cuadrado gris a los pies de Don RamÃ³n.

## Tras la fase 8
- Toda la poblaciÃ³n, los sucesos, las misiones y los textos de `data/world/` son provisionales. El director puede tachar festividades.
- Sin medir en una grÃ¡fica real. Terminar una misiÃ³n y reventar una fiesta tienen prueba automÃ¡tica en `tests/flows/beta_routes_test.gd`; falta probarlos a mano en partida.
- Los personajes con nombre siguen con diÃ¡logos escritos, fuera del motor social.
- P-19: proponer opciones para mostrar los controles, que ahora salen en el chat de las IAs.
- Capturas de partida real con `tools/captura_partida.gd` (variables CAPTURAS, SALIDA, FECHA, ACCION y SUCESO).

## Tras la fase 9
- 20 IAs, batallas, vista de estrategia, 100 melodÃ­as y 40 perfiles de voz sintÃ©ticos. Las voces no son acentos reales. Valores y textos provisionales.
- Sin medir en una grÃ¡fica real. Una batalla en curso no se guarda.
- Pruebas de rendimiento con `tools/medir_rendimiento.gd` (variables CASO y EXTRA). Audio con `tools/audio/gen_audio.py`.

## Tras el cierre de la beta
- P-02 implementado y provisional, a revisar jugando. PoblaciÃ³n, catÃ¡logo y textos son provisionales.
- El director no ha jugado aÃºn la beta entera con estos cambios. Sin medir en una grÃ¡fica real.
- Recorridos reales con `tools/recorrido_beta.gd` (variables RUTA, SEMILLA y FECHA).
- Siguiente fase: P-24, revisiÃ³n de cÃ³digo y mÃ¡s pruebas funcionales. Ideas post-beta: P-23, P-25, P-26 y P-27.

## Tras los arreglos de la beta
- Rendimiento medido solo con grÃ¡fica por software: falta confirmarlo en el ordenador del director. Medir con `tools/medir_por_partes.gd` (variables NOCHE, EXTRA y CAPAS).
- La pelea contra grupos no la ha probado el director a mano. Radio de reacciÃ³n (250) y hueco alrededor del jugador (34), provisionales.
- Clics reales de pelea con `tools/probar_pelea.gd`.

## Tras la revisiÃ³n de cÃ³digo (P-24)
- Razas, zona, progenitores, armas, animaciones y muertes viven en datos: ver `adr/0016-revision-codigo.md`.
- Medido en la grÃ¡fica del director (Intel HD 520): ciudad de 84 a unos 30 ms, batalla de 250 a 16-28 ms. Para 60 imÃ¡genes por segundo aÃºn faltan protagonista en textura, paredes en bloques y atlas de personajes.
- Medir el juego exportado con `tools/medir_exportado.tscn` y el preajuste Â«Medicion WindowsÂ».
- Al ejecutar dos Godot a la vez, usar un `XDG_DATA_HOME` distinto: comparten `user://`.

## Tras la optimizaciÃ³n en grÃ¡fica integrada
- En la Intel HD 520 del director, con OpenGL directo: ciudad 7 ms, caminando 19, pelea 11 y pausa 16 (medido antes de los Ãºltimos ajustes). La fÃ­sica al caminar, unos 21 ms por paso, es el siguiente cuello de botella.
- Sin probar en Windows por Claude. Plugins de estilo IRCap confirmados por el director el 10-nov: los quiere, con fase de revisiÃ³n estÃ©tica despuÃ©s. Sin confirmar todavÃ­a: provocar peleas y autocolocaciÃ³n de piezas.
- El director vio personajes desaparecer al hablar mal de la otra raza; no se ha reproducido. Queda por vigilar.
- Provisionales: retroceso de 80 unidades, tres frases para provocar batalla, y tamaÃ±o de personajes al 50 %.

## Tras las pruebas finales de la beta
- Grupos engaÃ±ados (respuestas Â«chatarra al norteÂ» y Â«sombreros en el surÂ»): antes se esfumaban; ahora se van andando y desaparecen al llegar. Salida y velocidad provisionales.
- Investigado: tras un rumor, casi toda una raza puede irse andando a contÃ¡rselo a la otra. Es P-14 exagerado: el director decide si se limita.
- De noche, los Jubilados apagados no se defienden en una batalla (8 caÃ­dos sin devolver un golpe en la prueba): decisiÃ³n pendiente.
- Ejecutado aquÃ­ con capturas: provocar por malmeter, autocolocaciÃ³n, aviso al recoger, retroceso y chat. Sin confirmar por el director, igual que OpenGL directo y el `.exe` en Windows. Sin probar en partida: batalla por recado insultante.
- Herramientas: `tools/seguir_personajes.gd`, `tools/probar_pendientes.gd` y `tools/probar_desvio.gd`.
- Preguntas abiertas de la post-beta: P-23, P-25 a P-31, mapa, orden de razas, guardar batallas, rendimiento objetivo y textos provisionales.

## Herramientas y CI (fusionado en `main` el 10-nov)

- Entorno local gratuito en `opencode_projects`: Godot 4.7.2, Python 3.12.10, ffmpeg, Inkscape 1.4.4 y plantillas de exportaciÃ³n; todos en el PATH de usuario. Audacity ya estaba instalado.
- Scripts deterministas: `tools/verificar.py` (entrada Ãºnica), `tools/validar_datos.py` (46 comprobaciones), `tools/formatear.py`, `tools/comparar_medicion.py`. Estado hoy: 0 errores en datos y en 255 archivos de texto; 64 avisos de lÃ­neas largas, deuda anterior.
- Al crear el formateador se corrigieron 12 archivos que incumplÃ­an la norma de lÃ­nea final (9 JSON de `data/` y 3 pruebas). No se debilitÃ³ ninguna comprobaciÃ³n.
- GitHub Actions: `pruebas.yml` (verificaciones deterministas + 311 pruebas gdUnit4, con `timeout` y `</dev/null`) y `exportar.yml` (`.exe` y `.pck` como artefactos). Ambos YAML validados con parser real.
- **Primer run de `pruebas.yml` en Linux: 311/311 ejecutadas, 3 fallos**, mientras que en Windows la suite local dio 311/311 y 0 fallos (22 min 28 s). Causa: estado global (`get_tree().paused` e `InputMap`) que las suites no aÃ­slan y gdUnit4 ordena distinto en Linux. Se corrigiÃ³ con `before_test()` en `tests/ui/ajustes_prueba_test.gd`, `tests/ui/controls_panel_test.gd` y `tests/flows/beta_routes_test.gd`, sin tocar ningÃºn `assert` (24/24 en esas suites, en local).
- El **segundo run no fallÃ³: fue cancelado** (`conclusion: cancelled`) a los 7 min 12 s por un push nuestro con `cancel-in-progress: true`; no habÃ­a ningÃºn `FAILED`. Diagnosticado contra la API con un subagente de solo lectura. Se ajustÃ³ `pruebas.yml` (`paths-ignore` para docs, sin run duplicado de PR, `timeout -k 30 1200`, job a 30 min y procedimiento de no empujar durante la verificaciÃ³n).
- **Run del HEAD final `3aed01f`: verde**, `311 test cases | 0 errors | 0 failures`, 7 min 46 s. Confirma los 3 `before_test()` en Linux. AdemÃ¡s, sobre `f1f2297` el run de `push` dio 311/311 y el de PR dio 1 fallo en `test_ruta_fuerza_completa_los_cuatro_retos`: es intermitente, preexistente y ajeno a esta rama. Queda registrado como **P-39** para la post-beta, sin debilitar la prueba.
- ExportaciÃ³n local verificada: `godot --headless --export-release "Windows"` genera `bug_de_familia.exe` (109 MB) y `.pck` (20 MB) en `build/`. El workflow de exportaciÃ³n corre al fusionar en `main`.
- Capturas y vÃ­deo reales de la zona beta generados con `tools/captura_partida.gd` sobre la Intel HD 520 (26 PNG + MP4). Sirven para validar que el entorno puede producirlas.
- Estudiado y descartado: servidores MCP (coste de contexto y dependencias), LSP (sin servidor para GDScript), plugins de marketplace de terceros, y el generador de imÃ¡genes de OpenCode (de pago, sin fondos). Ver `adr/0019-herramientas-ci-y-mcp.md`.
- Plantillas de mohÃ³crata: SVG por cÃ³digo con la paleta y el rig actual, no integradas aÃºn en el juego (ejemplo para el director).

## Herramientas de sesiÃ³n (fusionado en `main` el 10-nov)

- `HERRAMIENTAS.md` reÃºne rutas, versiones, comandos y limitaciones. OpenCode lo carga al empezar cada sesiÃ³n (`instructions` en `opencode.jsonc`). DecisiÃ³n: `adr/0021-herramientas-al-iniciar-sesion.md`.
- Instalado el 10-nov: Playwright 1.65.0 con Chromium 158 (lo usa `tools/art/ground_gen.py`), Krita 5.3.4.1 y Audacity 4.0.2. Inventario y licencias en `DEPENDENCIAS.md`.
- Pendiente de probar en una sesiÃ³n nueva. Antes hay que reiniciar la aplicaciÃ³n de OpenCode: el PATH nuevo solo llega a los procesos que arrancan despuÃ©s.
- Cuota: el 10-nov, `big-pickle` (modelo por defecto) respondiÃ³ Â«Free usage limit reachedÂ». Si vuelve a pasar, aplica `FALLBACK_MODELS.md` y `adr/0020-tres-modelos-por-agente.md`.

## Post-beta (fusionado en `main` por el PR #3 y fases siguientes)

Trabajo de la fase acordada para P-1, P-2, P-3, P-4, P-5, P-6, P-10 y P-15 (P-16 descartado), mÃ¡s P-37 y P-39 en fases posteriores. Todo provisional y pendiente de revisiÃ³n/validaciÃ³n manual en partida.

- **P-10:** ventana de propagaciÃ³n de rumores reducida a 7 s en `simulation/rumor_engine.gd`. Prueba actualizada: `res://tests/simulation/rumor_test.gd` (7/7) ejecutada en Windows (Godot 4.7.2 headless).
- **P-2:** los grupos engaÃ±ados van a la zona indicada en el diÃ¡logo (`indicated`, centro del hogar contrario) sin salirse del mapa. Prueba: `res://tests/beta/group_diversion_test.gd` (2/2) ejecutada.
- **P-3:** de noche los Jubilados huyen/se esconden en su hogar sin devolver golpes y no atacan (`no_attack`, pasivos/investigando al hogar). Se ajustÃ³ `res://tests/beta/beta_zone_test.gd::test_power_off_at_night_is_only_an_advantage` al comportamiento decidido; suite `res://tests/beta/beta_zone_test.gd` (31/31) ejecutada. Pendiente validaciÃ³n manual.
- **P-4:** lÃ­mite aleatorio y determinista (2-5, por `rng.randi_range`) de repeticiones por opciÃ³n de conversaciÃ³n en PNJ/habitantes (`investigation/investigation_director.gd`, `simulation/live_dialogue.gd`); al agotarse la opciÃ³n se oculta y provoca enfado/pelea inmediata. Conteos en memoria, no persistidos en guardado. Pruebas ejecutadas: `res://tests/investigation` (9/9) y `res://tests/simulation` (27/27). Pendiente afinar alcance/reaperturas y validaciÃ³n manual.
- **P-5:** duelo ~20 s reales junto a los muertos (`NpcState.mourn_until/mourn_at`, `LiveWorld` dirige al lugar y muestra reacciÃ³n). Pendiente comprobar visibilidad al pasar cerca en partida y aÃ±adir/ajustar pruebas especÃ­ficas si hace falta.
- **P-6:** habitantes con tamaÃ±o visual variable (30 %-80 %), mayorÃ­a adultos al nacer (~80 %) y niÃ±os que crecen a adulto a los 5 min reales (300 s de `sim.elapsed`, cambio Ãºnico fijo). Aplica a nacimientos/reciÃ©n llegados por el mismo camino de creaciÃ³n; solo visual (sin alterar colisiones, detecciÃ³n ni alcances). Pendiente revisiÃ³n visual/rigs y pruebas especÃ­ficas.
- **P-15/P-29 (hecho el 15-nov):** sonidos de pasos generados con `tools/audio/gen_audio.py --solo-sfx` (`audio/sfx/paso_01..06.ogg`), registrados en `data/audio/library.json`; reproducciÃ³n posicional integrada (`audio/footstep_audio.gd`) en jugador y guardias. Sin voces nuevas. **AÃ±adido en P-29:** oclusiÃ³n por muro (el paso tapado suena en el bus `PasosTapados`, mÃ¡s bajo y mÃ¡s grave) y timbre propio por IA (`normal`, `radio`, `eco`, `distorsion` en `data/ai/personalities.json`, con un bus y su filtro por timbre). Ver `adr/0031-sonido-direccional-y-timbre-ia.md`. Pendiente validaciÃ³n manual de posicionalidad, volumen, bus y cobertura, y decidir si se aÃ±aden sonidos de alerta o de ataque.
- **P-30:** analizado; no se aplica `WorkerThreadPool`. La simulaciÃ³n lÃ³gica avanza por pasos (`WorldSim` recorre habitantes, rumores, sucesos, misiones y festividades) sobre una poblaciÃ³n pequeÃ±a en la beta, sin mediciÃ³n en grÃ¡fica real que justifique paralelizar; repartirla complicarÃ­a el cÃ³digo y puede introducir fallos difÃ­ciles de reproducir. Pendiente medir en grÃ¡fica real si aparece necesidad.
- **P-25 (provisional):** 7 fotogramas por acciÃ³n (idle/ataque/recarga) dibujados por cÃ³digo en el atlas SVGâ†’PNG; `ActionFrameCatalog`/`ActionFrame` exponen el frame actual en protagonista y enemigos. La conexiÃ³n con el combate es cosmÃ©tica. Ver `adr/0024-fotogramas-por-accion.md`.
- **P-28 (provisional):** 4 `RichTextEffect` registrados en `IrcChat.log_view` con el mapeo aprobado por el director; la tartamuda repite letras; `reduce_motion` deja el texto plano; sin RNG global.
- **P-31 (provisional):** siluetas de edificios en `StrategyView._draw_map` con los rectÃ¡ngulos reales de `BetaLayout`, 5 llamadas de dibujo antes de los luchadores.
- **P-33 (provisional):** el aviso del chat pasa a ser un marco con relleno transparente, en vez de un relleno blanco que restaba contraste; respeta `reduce_motion`.
- **P-26 (opciÃ³n 1a, aprobada por el director):** los fantasmas siguen solo en la pausa tÃ¡ctica y en la conversiÃ³n. Se documenta el punto de enganche en `ui/ai_spectres.gd`: el futuro `ZoneLoader`/pantalla de viaje rÃ¡pido crearÃ¡ el nodo con `AiTeam` y llamarÃ¡ a `set_shown(true)` mientras el juego estÃ© parado. Queda **bloqueado** hasta que exista el gestor multi-zona (infraestructura post-beta, aÃºn sin implementar). Duda abierta, sin resolver: si el tiempo del mundo avanza durante el viaje. No se ha creado ninguna pantalla de carga nueva.
- **P-26 (diseÃ±o del viaje, decidido por el director el 11-nov):** las IAs activas del destino se muestran como fantasmas durante la carga; tiempo mÃ­nimo de carga de **5 segundos**; si la apertura tarda mÃ¡s, se respeta ese tiempo. Sigue bloqueado hasta el gestor multi-zona.
- **P-37 (implementado el 11-nov):** al empezar la pelea el protagonista ataca solo. Al confirmar la pre-pausa (`FightDirector.confirm_pre_fight` arranca el combate con el nuevo `start_combat`) el combate se auto-engancha al guardia objetivo (`CombatSystem.engage`) sin orden del jugador (clic o conversaciÃ³n); el auto-ataque sale del propio `CombatSystem` (acercamiento + golpes en rango). Prueba nueva: `tests/sandbox/game_flow_test.gd::test_fight_starts_engaging_the_guard_without_player_order` (1/1). Suites `tests/sandbox` (28/28) y `tests/combat` (24/24) en verde. Pendiente: validaciÃ³n manual en partida y las dudas de diseÃ±o de P-37 (sustituciÃ³n del ataque manual, alcance de armas, desactivaciÃ³n en opciones, sigilo).
- **P-37 (patrullas, implementado el 11-nov):** las patrullas desviadas ya no desaparecen para siempre. Al llegar al punto indicado se quedan allÃ­ (visibles e interactuables); en partida cargada se colocan directamente en ese punto. Pruebas: `tests/beta/group_diversion_test.gd` (2/2).\n- **P-39 (cerrado el 12-nov):** la causa real no era un suceso aleatorio de eventos.json, sino la pelea automÃ¡tica (P-37): `start_combat()` enganchaba al primer guardia disponible (siempre `jub_barrio`) aunque el guardia que alertara fuera otro, y arrancaba pelea incluso con el jugador agachado (sigilo). Fix: `start_combat()` engancha al guardia que disparÃ³ la alerta, y no arranca si el jugador va agachado (`FightDirector.player.is_crouching`). AdemÃ¡s, la espera en `_start()` se hizo determinista (54 fotogramas de fÃ­sica en lugar de 300 ms reales) y se fijÃ³ el dÃ­a del calendario. `beta_routes_test.gd`: 6/6, 0 fallos (Windows). Pendiente confirmaciÃ³n en Linux (CI). Ver `stealth/fight_director.gd`, `scenes/sandbox/sandbox.gd`.

**Pruebas ejecutadas (Windows, Godot 4.7.2 headless):** `tests/simulation/rumor_test.gd` 7/7, `tests/investigation` 9/9, `tests/simulation` 27/27, `tests/beta/group_diversion_test.gd` 2/2, `tests/beta/beta_robustness_test.gd` 11/11, `tests/beta/beta_zone_test.gd` 31/31, `tests/beta/music_test.gd` 5/5, `tests/beta/fight_groups_test.gd` 5/5, `tests/beta/battle_test.gd` 6/6, `tests/flows/input_flows_test.gd` 13/13, `tests/flows/beta_routes_test.gd` 6/6 (ejecuciÃ³n final, con estabilizaciÃ³n y correcciÃ³n de dÃ­a forzado). `python tools/verificar.py`: OK. **No ejecutado:** suite completa en esta sesiÃ³n tras todos los cambios, mediciÃ³n en grÃ¡fica real, ni validaciÃ³n manual en partida.

## Pasada correctiva visual (10-nov, fusionada en `main` por el PR #3)

Trabajo provisional de P-25, P-26, P-28, P-31 y P-33, mÃ¡s la regla del `.exe` en cada fusiÃ³n (`adr/0023-exe-en-cada-fusion.md`) y la rotaciÃ³n de `explore` a Go (`adr/0022-rotacion-explore-a-go.md`). Fase cerrada administrativamente: PR #3 fusionado en `main` el 10-nov (HEAD `fd9366e1`, 329 pruebas, 0 fallos).

**Recursos generados (origen y herramienta):** `art/shared/atlas/piezas.png` y `data/art/atlas_piezas.json` se regeneraron con `tools/art/piece_atlas_gen.gd` (Godot 4.7.2 consola) el 10-nov, desde los SVG propios de `art/shared/rig/` mÃ¡s 7 fotogramas dibujados por cÃ³digo con `Palette`: 55 piezas, 170 de 2048 px. `data/art/action_frames.json` es catÃ¡logo escrito a mano. Detalle en `adr/0024-fotogramas-por-accion.md`. Se aÃ±adiÃ³ `tools/verificar_apis_godot.gd` para comprobar las APIs contra el motor instalado.

**Pruebas ejecutadas (Windows, Godot 4.7.2 headless):** `python tools/verificar.py` OK (48 comprobaciones, 24 archivos; 274 archivos de texto sin errores); `tools/verificar_apis_godot.gd` 0 errores; `validar_datos.py --actualizar` OK; **329 pruebas GdUnit por carpetas, 0 fallos y 0 errores** (ui 28, art 17, data 7, core 20, entities 5, combat 24, conversion 25, ai 37, body 14, investigation 9, simulation 27, stealth 7, sandbox 27, beta 63, flows 19). Incluyen 18 pruebas nuevas; no se desactivÃ³ ni debilitÃ³ ninguna. Semilla 1234 en simulaciÃ³n. Un fallo inicial por precisiÃ³n de `lerpf` y un warning de shadowing se corrigieron en el cÃ³digo (parÃ¡metro `strength`) y en el comparador (`is_equal_approx` con tolerancia), sin relajar ninguna aserciÃ³n.

**ExportaciÃ³n local:** preset Â«WindowsÂ». Regenerada el **11-nov 00:14** tras la correcciÃ³n de Â«Esc: salirÂ» y la opciÃ³n C: `build/bug_de_familia.exe` (109 MB) y `build/bug_de_familia.pck` (20,9 MB). Incluye los cambios de esta fase y se generÃ³ antes de la fusiÃ³n del PR #3; conforme a `adr/0023-exe-en-cada-fusion.md` se regenera antes de cada fusiÃ³n posterior.

**ObservaciÃ³n del director (10-nov, a ojo, sin mediciÃ³n):** el `.exe` local Â«de velocidad va perfectoÂ». No sustituye a la mediciÃ³n formal con `MEDIR.bat` en grÃ¡fica real, que sigue sin hacerse.

**CorrecciÃ³n tras la revisiÃ³n del director (10-nov):** al elegir Â«solo mirarÂ» la vista de estrategia se abre sola y M no hace nada, porque M **solo abre** (`02_DECISIONES.md:148`). La ayuda de la vista decÃ­a Â«M: salirÂ», contradiciendo esa decisiÃ³n: se corrige a Â«Esc: salirÂ» y se aclara en `docs/controles.md`. Se aÃ±aden pruebas de M/Esc y del texto de ayuda.

**P-31, opciÃ³n C aprobada por el director (10-nov):** los edificios no se veÃ­an porque el encuadre a zoom 1,9 los reducÃ­a a franjas de 84â€“152 px. CÃ¡lculo estimado con `brawl_patrol` (**no** medido en partida): con zoom 0,6 entran como bloques de 264â€“320 px y la ciudad completa (hace falta un zoom de 0,659 o menos). Se baja `ZOOM_MIN` de 0,7 a **0,6** y se aÃ±ade un **alejazo puntual y rÃ¡pido** al abrir la vista y al caer un luchador, solo en la vista de estrategia, respetando `reduce_motion` y con decaimiento en tiempo real (no se acelera a x4). Ver `adr/0025-alejazo-vista-estrategia.md`. Los edificios **no** se ven de forma permanente, solo durante el alejazo; el minimapa fijo (opciÃ³n A) queda sin hacer. El diagnÃ³stico con Godot sobre la escena real se colgÃ³ en `debug>` y se cancelÃ³; las cifras son analÃ­ticas.

**Ajuste provisional (11-nov):** al criticar el director que el alejazo Â«va muy rÃ¡pidoÂ», `PULSE_DECAY` sube de **2,5** a **1,2** en `ui/strategy_view.gd` (decaimiento ~0,83 s de tiempo real frente a 0,4 s); la prueba `test_el_pulso_aleja_el_zoom_y_decae_en_tiempo_real` se ajustÃ³ a ese nuevo valor y sigue verde. `ZOOM_MIN = 0,6` (aprobado), `ZOOM_MAX = 1,9` y `ACTION_SHOW_TIME = 0,5 s` siguen provisionales.

**ReducciÃ³n de movimiento (11-nov):** se cierra el hueco detectado en la validaciÃ³n: el temblor del veredicto de conversiÃ³n (`ConversionScreen.show_verdict`) respeta ahora `GameSettings.reduce_motion`; con la opciÃ³n activa no tiembla. Pruebas: `tests/conversion/conversion_test.gd` (12/12, con 2 casos nuevos sobre el veredicto). Con esto, Â«Reducir temblores y destellosÂ» desactiva el pulso de la vista de estrategia, los efectos de texto, el flash/impacto y el grano.

**No ejecutado:** suite completa en un solo comando (cubierta por carpetas), validaciÃ³n manual en partida, mediciÃ³n en grÃ¡fica real y arranque del `.exe` exportado. P-39 sigue abierto para cierre definitivo en Linux.

**Pendiente de validaciÃ³n manual:** aspecto de los fotogramas, efectos de texto por IA, marco del chat y siluetas de edificios en la vista de estrategia.

## P-40 (fusionado en `main`)
- Grupos desviados al hablar con ellos ahora siguen la ruta de `NavGrid` (sin atravesar edificios): `scenes/beta/beta_challenges.gd`. Prueba: `tests/beta/group_diversion_test.gd` 2/2. Otros movimientos ordenados (habitantes/guardias) ya usaban `nav` y no se vieron afectados.

## Preparar el entorno en una conversaciÃ³n nueva

En Windows, rutas y comandos: `HERRAMIENTAS.md`. Los pasos siguientes son de Linux.

1. Clonar `rvillalba1983/bug-de-familia`. Si la copia es superficial, usar `git fetch origin main` y `FETCH_HEAD`.
2. Descargar `Godot_v4.7.2-stable_linux.x86_64.zip` de `github.com/godotengine/godot-builds/releases/download/4.7.2-stable/`.
3. Importar: `godot --headless --import`. Plantillas de exportaciÃ³n: `Godot_v4.7.2-stable_export_templates.tpz`, en `~/.local/share/godot/export_templates/4.7.2.stable/`.
4. Probar siempre con `timeout` y `</dev/null`, porque un error de script abre un `debug>` que se queda colgado:
   `timeout 300 godot --headless -s -d res://addons/gdUnit4/bin/GdUnitCmdTool.gd --ignoreHeadlessMode -a res://tests -c 2>&1 </dev/null`
5. Capturas: `LIBGL_ALWAYS_SOFTWARE=1 xvfb-run -a -s "-screen 0 1920x1080x24" godot --rendering-driver opengl3 --path . -s script.gd`

## Forma de trabajar con Git
- Una rama por fase y **siempre Pull Request** a `main` (decisiÃ³n del director del 10-nov); nada de fusiÃ³n directa en local. `merge --ff-only` solo en el caso excepcional autorizado. Ver `adr/0023-exe-en-cada-fusion.md`.
- Antes de pedir la fusiÃ³n del PR: generar el `.exe` en `build/` (preset Â«WindowsÂ»), actualizar este archivo y dejar el CI verde. El director aprueba la fusiÃ³n; despuÃ©s se avisa del cambio de conversaciÃ³n.
- Las ramas remotas las borra el usuario.
- Los documentos cambiados se copian al proyecto de Claude, en `Videojuego/Desarrollo/`. El repositorio manda.

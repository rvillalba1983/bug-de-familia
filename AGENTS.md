# AGENTS.md — Bug de Familia

Juego 2D de sigilo táctico e investigación para PC con **Godot 4.7.2 estable** (edición estándar, no .NET), GDScript tipado, renderer `gl_compatibility`, completamente offline. Todo el proyecto —documentación, textos y código— está en español.

## Comandos

La versión del motor está fijada: no la cambies sin revisar compatibilidad, ejecutar las pruebas y documentar el cambio.

```bash
godot --headless --import                 # importar; necesario tras clonar o añadir recursos
godot --headless -s -d res://addons/gdUnit4/bin/GdUnitCmdTool.gd --ignoreHeadlessMode -a res://tests -c   # todas las pruebas
```

- Una carpeta o suite concreta: mismo comando con `-a res://tests/ai` o `-a res://tests/ai/ai_perks_test.gd`. `-i <ruta>` excluye; `-c` desactiva fail-fast.
- Un error de script en headless abre un prompt `debug>` y deja la ejecución colgada: usa un timeout y redirige stdin (`timeout 300 ... </dev/null` en bash).
- Preparación completa del entorno (binario, plantillas de exportación, capturas): `docs/03_ESTADO.md`, sección «Preparar el entorno».
- Comprobaciones deterministas antes de commitear: `python tools/verificar.py` (datos, normas de formato y medición si existe `medicion.txt`). En OpenCode, comando `/verificar`. Ver `docs/adr/0019-herramientas-ci-y-mcp.md`.
- Herramientas, rutas, comandos y limitaciones: `HERRAMIENTAS.md`. OpenCode lo carga al empezar cada sesión (`instructions` en `opencode.jsonc`).

## Estructura

- Las carpetas raíz son sistemas de juego: `ai`, `art`, `audio`, `body`, `combat`, `conversion`, `core`, `entities`, `investigation`, `scenes`, `simulation`, `stealth`, `ui`. `tests/` espeja esas carpetas; `addons/gdUnit4` es el framework de pruebas; `tools/` son scripts de medición y captura.
- Escena principal: `res://scenes/beta/beta_zone.tscn`.
- Contenido en datos, separado del código: catálogos en `core/data/`, mundo y zonas en `data/` (JSON). Ver `docs/adr/0016-revision-codigo.md`.
- Los presets de exportación excluyen `addons/`, `tests/`, `tools/` y `docs/`, e incluyen `data/*.json`.

## Documentación

- `docs/00_LEEME.md` es el índice: qué documento leer según la tarea.
- `docs/02_DECISIONES.md` manda sobre todo lo demás. No restaures decisiones sustituidas.
- `docs/01_CONFLICTOS_Y_PENDIENTES.md`: no lo resuelvas por tu cuenta; propón alternativas y sigue con tareas independientes.
- `docs/03_ESTADO.md`: progreso por fases, avisos de cada una y número de pruebas actuales.
- Las decisiones técnicas nuevas se registran como ADR en `docs/adr/` y actualizan la documentación afectada.

## Flujo de trabajo

- El usuario es el director de producto: aprueba decisiones de diseño y fusiones. No le traslades decisiones técnicas triviales.
- Una fase del plan (`docs/40_plan_desarrollo.md`) por conversación; termina al fusionarla en `main`. Al fusionar, actualiza `docs/03_ESTADO.md` y avisa al usuario de que hay que cambiar de conversación.
- Git: una rama por fase; fusión a `main` con `--ff-only` y solo cuando el usuario lo aprueba. Las ramas remotas las borra el usuario.
- Entregas pequeñas; siempre debe existir una versión ejecutable.
- No inventes lo que falta: los parámetros provisionales se marcan como tales.
- No afirmes que algo funciona sin ejecutarlo: distingue pruebas ejecutadas de no ejecutadas.
- Comprueba las APIs contra Godot 4.7.2; no inventes APIs del motor.
- No subas código ni recursos a servicios externos sin autorización. Registra origen y herramienta de cada recurso generado.
- Al cerrar una tarea, informa de: qué se ha hecho, archivos afectados, pruebas y resultados, validación manual necesaria, limitaciones y decisiones que requieren aprobación.

## Pruebas

- Convenio: `tests/<sistema>/<nombre>_test.gd`. Usa `TestSupport.reset_session()` (`tests/test_support.gd`) para aislar estado y fijar semilla (1234).
- Semillas reproducibles en todas las pruebas de simulación.
- Nunca desactives ni debilites una prueba para conseguir verde; si deja de ser válida, justifica el cambio y sustitúyela.

## Normas de código (resumen de `docs/35_normas_codigo.md`)

- GDScript tipado siempre (variables, parámetros y retornos). Tabuladores, LF, UTF-8 sin BOM, líneas de menos de 100 caracteres.
- `snake_case` en archivos, variables y funciones; `PascalCase` en clases.
- Movimiento y física en `_physics_process()`; evita recorrer la población en cada fotograma.
- No desactives warnings ni captures errores en silencio: los fallos deben ser visibles y señalar el archivo y el campo problemáticos.

## Modelo y agentes

- `opencode.jsonc` define el equipo (ver `CONFIG_AGENTS.md`): nueve agentes del proyecto, `explore` y el modelo por defecto para `build`, `plan` y `general`. Precios, límites y alternativos: `FALLBACK_MODELS.md`. Decisión: `docs/adr/0018-agentes-y-modelos.md`.
- Dos fuentes: gratuitos de la consola de OpenCode (`opencode/big-pickle` es el modelo por defecto) y suscripción OpenCode Go de 10 $/mes (`opencode-go/<modelo>`). Donde hay gemela gratuita, se usa la gratis.
- Go no tiene cadena automática: si un modelo agota su ventana de 5 horas o se retira un gratuito, se cambia a mano siguiendo `FALLBACK_MODELS.md` y se documenta en un ADR.
- Franja punta: solo DeepSeek en Go cuesta el doble de lunes a viernes en 02:00-05:00 y 07:00-11:00 (hora española de invierno). El resto cuesta igual a cualquier hora. El principal de qa es gratuito y no tiene franja.
- Los modelos gratuitos son por tiempo limitado y pueden usar los datos para mejorar el modelo (Big Pickle); DeepSeek y GLM flash free son de retención cero.
- El plugin `.opencode/_disabled/model-fallback` está desactivado a propósito: usaba un hook inexistente en V2 y no puede cambiar de proveedor. No lo reactives.
- La cadena `openrouter/auto` global (`~/.config/opencode/opencode.json`) sigue existiendo para otros proyectos; este repo no la usa.
- Comprobación rápida: `opencode run` debe mostrar `big-pickle` en la cabecera de la respuesta. Si falla por cuota o retirada (429/402/404), pega el error literal y aplica `FALLBACK_MODELS.md`.
- **Tres modelos por agente:** la fuente única es `tools/modelos_agentes.json`. Si un modelo agota su límite, ejecuta `python tools/cambiar_modelo.py --rotar <agente>` y **relanza la tarea**: V2 no reintenta la petición fallida con el modelo nuevo. `--validar` comprueba la sincronización. Decisión: `docs/adr/0020-tres-modelos-por-agente.md`.

## Este clon (Windows)

- Los comandos de `docs/03_ESTADO.md` asumen Linux (`timeout`, `</dev/null`, `xvfb-run`): adáptalos a PowerShell.
- Las herramientas están en `opencode_projects` y en el PATH del usuario (Godot 4.7.2, Python, ffmpeg, Inkscape, Git, GitHub CLI). Una sesión de OpenCode solo las ve si arrancó después del cambio de PATH. Rutas, versiones y comandos: `HERRAMIENTAS.md`.
- Medir rendimiento en la gráfica real del director: exportar con el preset «Medicion Windows» y ejecutar `tools/medir_windows/MEDIR.bat` (unos 20 minutos, genera `medicion.txt`).
- `CLAUDE.md` guarda las instrucciones equivalentes para Claude Code: mantén ambos archivos sincronizados si cambias las reglas.

## Trabajar con OpenCode

- Una fase del plan por conversación; la conversación termina al fusionar esa fase en `main`.
- El trabajo de dominio se delega a subagentes especialistas (equipo en `opencode.jsonc`, ver `CONFIG_AGENTS.md`).
- Las tareas deterministas van en scripts: solo se revisa la respuesta.
- La conversación principal coordina y decide con el director.

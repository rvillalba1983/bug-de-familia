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

## Modelo y fallback

- Todos los `model` de `opencode.jsonc` (raíz y `agents.*`) son `openrouter/auto`. No los cambies por modelos de otro proveedor.
- `openrouter/auto` es una cadena de tres modelos gratuitos definida en `~/.config/opencode/opencode.json` (`providers.openrouter.models.auto.body.models`). OpenRouter pasa al siguiente si el primero falla o agota cuota; el máximo que acepta es tres.
- El plugin `.opencode/_disabled/model-fallback` está desactivado a propósito: usaba un hook inexistente en V2 y no puede cambiar de proveedor. No lo reactives.
- Comprobación rápida: `opencode run` debe mostrar `auto` en la cabecera de la respuesta. Si muestra otro modelo, la configuración no se está aplicando.
- Si una petición falla por cuota (429/402), pega el error literal y espera instrucciones; no cambies de modelo a mano ni inventes alternativas.
- No subas `limit.output` del modelo `auto` sin comprobar el saldo de OpenRouter: por encima de unos 48k tokens de salida la petición se rechaza con 402.

## Este clon (Windows)

- Los comandos de `docs/03_ESTADO.md` asumen Linux (`timeout`, `</dev/null`, `xvfb-run`): adáptalos a PowerShell.
- En PowerShell no hay `git` ni `godot` en el PATH (nov-2026); Godot 4.7.2 win64 está sin extraer en `~/Downloads/Godot_v4.7.2-stable_win64.exe.zip`.
- Medir rendimiento en la gráfica real del director: exportar con el preset «Medicion Windows» y ejecutar `tools/medir_windows/MEDIR.bat` (unos 20 minutos, genera `medicion.txt`).
- `CLAUDE.md` guarda las instrucciones equivalentes para Claude Code: mantén ambos archivos sincronizados si cambias las reglas.

# Herramientas del proyecto

Este archivo se carga al empezar cada sesión de OpenCode (`instructions` en `opencode.jsonc`). `AGENTS.md` y `CLAUDE.md` también lo citan. Si cambias una herramienta, una ruta o un comando, cambia este archivo en el mismo cambio. Dependencias y licencias: `docs/DEPENDENCIAS.md`.

Comprobado el 10-nov-2026 en Windows con PowerShell. Lo añadido el 13-nov por el incidente de arranque (ADR 0028) va marcado como tal y **no está validado todavía**. Lo que aquí figura como «sin ejecutar» no se ha probado.

## 1. Al empezar una sesión

- `git status` en la raíz: revisa la rama (`main` o la de la fase en curso) y los cambios sin confirmar.
- Las herramientas están en el PATH del usuario, pero una sesión de OpenCode solo ve el PATH con el que arrancó. Si un comando no aparece, cierra y abre OpenCode, o usa la ruta de la sección 2.
- En PowerShell, un ejecutable con ruta entre comillas se lanza con `&`: `& "C:\...\python.exe" --version`.
- Un clon nuevo necesita `godot --headless --import` antes de las pruebas. Crea `.godot/`, que no va a git.

## 2. Rutas y versiones

| Herramienta | Ruta o comando | Uso |
|---|---|---|
| Godot 4.7.2, consola | `C:\Users\usuario\opencode_projects\godot\Godot_v4.7.2-stable_win64_console.exe` | Pruebas, importar, exportar, medir |
| Godot 4.7.2, editor | `C:\Users\usuario\opencode_projects\godot\Godot_v4.7.2-stable_win64.exe` | Editar escenas |
| Plantillas de exportación 4.7.2 | `%APPDATA%\Godot\export_templates\4.7.2.stable` | Exportar el `.exe` de Windows |
| Python 3.12.10 | `C:\Users\usuario\opencode_projects\python\python.exe` | Scripts de `tools/` |
| ffmpeg | `C:\Users\usuario\opencode_projects\ffmpeg\bin\ffmpeg.exe` | Audio con libvorbis y vídeo de capturas |
| Inkscape 1.4.4 | `C:\Users\usuario\opencode_projects\inkscape\PFiles64\Inkscape\bin\inkscape.com` | Retoques de SVG |
| Krita 5.3.4.1 | `C:\Program Files\Krita (x64)\bin\krita.exe` | Retoques puntuales de imagen |
| Audacity 4.0.2 | `C:\Program Files\Audacity 4\bin\Audacity4.exe` | Revisión de audio |
| Git 2.56.0 | `git` | Ramas, fusiones e historial |
| GitHub CLI 2.103.3 | `gh` (sesión iniciada) | CI e incidencias |
| Playwright 1.65.0 y Chromium 158 | `python -m playwright` | Texturas del suelo (`tools/art/ground_gen.py`) |
| OpenCode CLI 2.2.7 | `opencode` (atajo en `opencode_projects\opencode`) | `opencode run` y comprobaciones |

Paquetes de Python: `& "<python.exe>" -m pip install <paquete>`. Instalados el 10-nov: playwright 1.65.0, numpy 2.5.4 y scipy 1.18.1.

## 3. Comprobaciones sin Godot

- `python tools/verificar.py`: datos, rutas `res://` literales (`validar_rutas.py`), normas de formato, tabla de modelos y las pruebas de las propias herramientas (`unittest` sobre `tools/tests`); y, si hay `medicion.txt` en la raíz, la comparación de medición. Es el comando `/verificar` de OpenCode. Ejecútalo antes de cada commit. Hecho el 10-nov: OK; el 13-nov se añadieron rutas y pruebas de herramientas (ADR 0028).
- `python tools/validar_datos.py`: `--estricto` hace fallar también los conteos. `--actualizar` reescribe `tools/referencia_datos.json`: solo con un cambio de datos intencionado.
- `python tools/validar_rutas.py`: comprueba que cada literal `res://...` de código, escenas, datos y workflows exista en el árbol. No revisa rutas dinámicas (`%s`, formatos), rutas que acaban en `/`, `user://` ni `res://.godot/`. Detecta en segundos un renombrado incompleto sin arrancar Godot (el fallo del 13-nov). Opción: `--raiz <directorio>`. Añadido el 13-nov (ADR 0028) y ya integrado en `verificar.py`. Sin validar todavía.
- `python tools/formatear.py --comprobar --resumen`: solo comprueba. `python tools/formatear.py <archivo>` corrige UTF-8 sin BOM, LF y línea final; es el formatter de OpenCode.
- `python tools/comparar_medicion.py medicion.txt`: regresiones frente a `tools/medir_windows/referencia.txt`.
- `python tools/validar_informes.py --grupo <grupo> --minimo <n> --argumentos-gdunit "<-a res://...>"`: valida el informe JUnit real de GdUnit4 (`reports/report_N/results.xml`, el más reciente): que se hayan ejecutado casos (no cero y al menos el suelo `--minimo`), sin fallos, errores ni pruebas omitidas, con los conteos cuadrados (raíz = suites = casos del XML) y al menos una suite por cada carpeta `-a` recibida. Existe porque GdUnit4 sale con código 0 aunque no ejecute nada (por ejemplo, si la carpeta `-a` no existe): es el falso verde del PR #7 (ADR 0028). `--informes` cambia el directorio de informes y `--registro <log>` comprueba también errores de parseo y carga fuera del XML. Añadido el 13-nov; pruebas unitarias y detección del ejecutable roto verificadas en local. Pendiente de suite completa y CI.
- `python tools/verificar_humo.py --binario <binario> --datos humo_datos --registro humo.log`: prueba de humo del binario exportado con prueba positiva de arranque. Lanza el binario con `--headless` y un perfil de usuario aislado y único dentro de `--datos` (redirige `user://` con `APPDATA` en Windows y `XDG_DATA_HOME` en Linux, sin borrar partidas previas), espera `user://partida.json` y la valida: esquema versión 3, cuerpo del protagonista, zona actual (`--zona`, por defecto `despliegue_cero`), zona marcada visitada y población no vacía. Revisa el registro: exige el banner del motor y rechaza líneas `ERROR:`/`USER ERROR:`/`SCRIPT ERROR:`/`Parse Error:` o avisos de zona sin montar. No depende de que el proceso acabe bien ni de `--quit-after`: si la partida no aparece, falla. Opciones: `--espera <segundos>` (60 por defecto) y `--partida <archivo>` para validar una partida ya guardada sin lanzar (acompañada de `--registro`). Añadido el 13-nov (ADR 0028). Sin validar todavía.
- `python tools/cambiar_modelo.py --estado | --validar | --rotar <agente> | --usar <agente> <modelo> | --restaurar <agente>`. Si un modelo agota su límite: `--rotar` y **relanzar la tarea** (ADR 0020).
- `godot --headless --path . -s tools/verificar_apis_godot.gd`: comprueba contra el motor instalado las APIs de `CharFXTransform`, `RichTextLabel` e `Image` que usa el código. No sustituye a las pruebas, pero evita inventar APIs. Añadido el 10-nov (P-28/P-25).

## 4. Godot: importar y pruebas

Desde PowerShell, lanza Godot por consola y cierra su entrada:

```powershell
cmd /c "C:\Users\usuario\opencode_projects\godot\Godot_v4.7.2-stable_win64_console.exe --headless -s -d res://addons/gdUnit4/bin/GdUnitCmdTool.gd --ignoreHeadlessMode -a res://tests -c < NUL"
```

`< NUL` hace el papel de `</dev/null` de Linux: un error de script no deja el proceso esperando en `debug>`. Pon también un timeout en la herramienta de shell. La suite completa tardó unos 22 min en Windows, según `docs/03_ESTADO.md`.

- Importar: el mismo comando con `--import` en lugar de los argumentos de pruebas.
- Una carpeta o archivo: `-a res://tests/despliegue_cero` o `-a res://tests/despliegue_cero/music_test.gd`. Probado el 10-nov con el nombre anterior (`tests/beta`): `music_test.gd`, 5 de 5, en 3 s. La carpeta se renombró el 13-nov; los archivos de dentro aún pueden renombrarse (trabajo en curso), así que comprueba los nombres con `Get-ChildItem tests/despliegue_cero` antes de apuntar a uno concreto.
- `-i <ruta>` excluye; `-c` no para al primer fallo.
- Resultado: la línea `Overall Summary` y el código de salida. Los `WARNING` de carga de GDScript salen en cada ejecución. No los silencies (`docs/35_normas_codigo.md`).
- **Ojo (13-nov, ADR 0028):** GdUnit4 devuelve código 0 aunque no ejecute ningún caso (por ejemplo, si la carpeta `-a` no existe). No des nada por bueno solo con el código de salida: comprueba `Overall Summary` con casos > 0 o valida el informe con `tools/validar_informes.py` (§3).
- Informes: `reports/report_N/index.html` y `results.xml`. No van a git. El `results.xml` es el que valida `validar_informes.py`.

## 5. Exportar y medir

- Exportar Windows: preset «Windows» de `export_presets.cfg`. En PowerShell, con `cmd /c` y `< NUL`, el preset va **sin comillas internas** (con `"Windows"` se pierden y Godot recibe `.`, error `Invalid export preset name`): `cmd /c "C:\Users\usuario\opencode_projects\godot\Godot_v4.7.2-stable_win64_console.exe --headless --export-release Windows build/bug_de_familia.exe < NUL"`. Sale a `build/`, que no va a git. Verificado el 10-nov (`.exe` de 109 MB y `.pck` de 20,9 MB).
- **Regla del director (10-nov):** en cada fusión a `main` se genera también el `.exe` con este comando, antes de actualizar `docs/03_ESTADO.md` y avisar del cambio de conversación. Ver `adr/0023-exe-en-cada-fusion.md`.
- Medición en la gráfica del director: preset «Medicion Windows» y zip. El director ejecuta `MEDIR.bat` (unos 20 min) y envía `medicion.txt`. Lo copias a la raíz y ejecutas `verificar.py`. Solo el director puede medir su gráfica.
- Medición por software: `tools/medir_rendimiento.gd` (CASO, EXTRA), `tools/medir_por_partes.gd` (NOCHE, EXTRA, CAPAS) y `tools/medir_exportado.gd` (CASO). Sirven para comparar, no para fijar cifras de la gráfica real.
- Al dar una cifra, di si es medida por software, en gráfica real o no medida.

## 6. Capturas y pruebas con ventana

Necesitan ventana y gráfica, así que no llevan `--headless`. Se lanzan con `--path . -s <script>`, y las variables van como variables de entorno (en PowerShell: `$env:NOMBRE = "valor"` y después `Remove-Item Env:NOMBRE`).

- `tools/captura_partida.gd`: `CAPTURAS` (x,y,segundos,nombre, separados por espacios), `SALIDA`, `FECHA`, `ACCION`, `SUCESO`, `NOCHE`, `SEMILLA`. Usa su propio guardado.
- `tools/recorrido_beta.gd`: `RUTA`, `SEMILLA`, `FECHA`.
- `tools/probar_pelea.gd`, `tools/probar_pendientes.gd` y `tools/probar_desvio.gd`: clics reales de pelea, de pendientes y de desvíos.
- `tools/seguir_personajes.gd`: con `SEGUIR=1` la cámara sigue al primero que sale a contar un rumor.
- `tools/beta_walker.gd`: caminante de `tests/flows/beta_routes_test.gd`. Ver P-39 en `docs/01_CONFLICTOS_Y_PENDIENTES.md`.

## 7. Arte y audio

- Atlas de piezas: `--headless --path . -s tools/art/piece_atlas_gen.gd` y después `--import`. Repítelo si cambia un SVG de `art/shared/rig/`.
- `tools/art/ground_gen.py <carpeta>`: hornea `suelo_bosque`, `suelo_ciudad` y `suelo_barro` con Playwright y Chromium. Chromium arranca y renderiza (probado el 10-nov). El script no se ha ejecutado, para no regenerar texturas.
- Otros generadores de `tools/art/` (`rig_split.py`, `protagonist_gen.py`, `props_gen.py`, `npc_views_gen.py`, `facades_gen.py`, `city_scene_gen.py`, `beta_assets_gen.py`): solo con encargo.
- `python tools/audio/gen_audio.py [carpeta]`: sintetiza música y voces. Necesita numpy, scipy y ffmpeg con libvorbis (los tres comprobados). La semilla de cada pista es su número. Regenera la biblioteca: no lo lances sin encargo. Catálogo: `data/audio/library.json`.
- `tools/poblar_contenido.py` y `tools/poblar_zonas.py` reescriben JSON: desde el 13-nov leen y escriben UTF-8 con LF y `ensure_ascii=False`. Antes leían sin `encoding` y en Windows (cp1252) dañaron 65 textos de `data/world/species.json`. No los ejecutes sin encargo.
- Cada recurso generado registra origen y herramienta (`AGENTS.md`).

## 8. Git y GitHub

- Una rama por fase y **siempre Pull Request** a `main` (decisión del director del 10-nov); nada de fusión directa en local; `merge --ff-only` solo en el caso excepcional autorizado. Procedimiento: rama → commit → push de la rama → PR → CI verde → aprobación del director → fusión. **Antes de pedir la fusión del PR** se genera el `.exe` en `build/` (preset «Windows», §5) y se actualiza `03_ESTADO.md`. Las ramas remotas las borra el director.
- `git push` pide confirmación (permiso en `opencode.jsonc`). Crear el PR implica subir la rama a GitHub: se confirma con el director en el momento, porque no se sube código ni recursos a servicios externos sin autorización. Un push nuevo cancela la verificación en curso: no empujes mientras corre el CI.
- CI en `.github/workflows/`:
  - `pruebas.yml`: en cada push, salvo cambios solo en `docs/` o `*.md`, y al abrir o reabrir un PR. Ejecuta `verificar.py` y las pruebas GdUnit en Linux, con tope de 30 min. **Cambios del 13-nov (ADR 0028, en revisión y sin validar todavía):** el import falla si deja errores de script en el log; la matrix pasó de «beta» a «despliegue_cero» (core, combate, simulación, despliegue_cero) con un suelo `minimo` de pruebas por grupo; tras GdUnit corre `tools/validar_informes.py`, que valida el informe JUnit real (el falso verde del PR #7: GdUnit sale 0 con 0 casos y el CI solo miraba el código de salida); y hay un job nuevo `arranque` (Linux) que exporta el binario Linux y lanza `tools/verificar_humo.py` con perfil de usuario aislado y zona `despliegue_cero`.
  - **Nota (12-nov):** el workflow se dividió en 4 jobs paralelos (core, combate, simulación, y «despliegue_cero» desde el 13-nov). El job «despliegue_cero» es el más lento (~10 min por `beta_routes_test.gd`). Si el tiempo total supera los 11 minutos, revisar: subir `SPEED` en `beta_routes_test.gd` (3.0 → 4.0 → 5.0, validando que sigan pasando) o reducir los recorridos.
  - `exportar.yml`: en push a `main` y a mano. Exporta Windows y sube el artefacto `bug-de-familia-windows`. **Cambios del 13-nov (en revisión):** la exportación falla si el import o el export dejan errores de script y comprueba que `.exe` y `.pck` existen y no están vacíos; la prueba de humo del binario Windows no puede correr en el runner de Linux (la hace el job `arranque` de `pruebas.yml` con el binario Linux).
  - Un push nuevo cancela la verificación en curso: no empujes mientras corre.
- Consultar el CI: `gh run list --repo rvillalba1983/bug-de-familia --limit 5` y `gh run view <id> --log-failed`.
- Revisar un PR con el servidor MCP `github`: `pull_request_review_write` (create), `add_comment_to_pending_review` y `pull_request_review_write` (submit_pending).
- Riesgo conocido: P-39 (fallo intermitente de `test_ruta_fuerza_completa_los_cuatro_retos` en Linux). Puso en rojo `main` el 10-nov, en el run `42858970637`.

## 9. Agentes, modelos y OpenCode

- `opencode.jsonc` define nueve agentes del proyecto (`arquitecto`, `ingeniero-godot`, `gameplay`, `qa`, `documentacion`, `datos`, `arte`, `audio`, `medidor`) y `explore`. Equipo: `CONFIG_AGENTS.md`. Modelos, precios y límites: `FALLBACK_MODELS.md`.
- Tres modelos por agente, con fuente única en `tools/modelos_agentes.json`.
- No reactivar `.opencode/_disabled/model-fallback`.
- OpenCode recarga la configuración al guardar. `/reload` fuerza una recarga completa.
- Comprobación de modelo: `opencode run "..."` debe mostrar `big-pickle` en la cabecera.
- Skills útiles aquí: `opencode` (dudas sobre OpenCode, según su documentación V2) y `report` (reportar fallos de OpenCode con `gh`). Las demás skills del entorno son de otros proyectos.

## 10. Reglas que siempre aplican

Resumen. El texto completo está en `AGENTS.md` y `docs/35_normas_codigo.md`.

- No desactives ni debilites una prueba para conseguir verde. Semilla 1234 en las pruebas de simulación.
- GDScript tipado. Tabuladores, LF, UTF-8 sin BOM y líneas de menos de 100 caracteres.
- Registra origen y herramienta de cada recurso generado.
- En cada informe, separa lo ejecutado de lo no ejecutado.

## 11. Limitaciones conocidas (10-nov)

- Si `python`, `godot` u `opencode` no responden, es el PATH heredado: ver sección 1.
- Si `python` no está en el PATH de la sesión, el formatter de OpenCode falla y sigue. Ejecuta `python tools/formatear.py --comprobar` a mano.
- Sin ejecutar: `ground_gen.py`, `gen_audio.py` y `validar_datos.py --actualizar`: todos escriben archivos. La exportación sí se ejecutó el 10-nov (§5) y `cambiar_modelo.py --rotar explore` se ejecutó el 10-nov (ADR 0022).
- Validado (13-nov): `validar_rutas.py`, `validar_informes.py` y `verificar_humo.py`, y el arreglo de arranque (PR #8, merge `f56ef52`): CI verde (5 jobs), 372/372 pruebas y humo OK. Ver `adr/0028-validacion-arranque-y-ci.md`.
- En `C:\Program Files\Audacity` queda solo el desinstalador de la versión 3. La válida es `Audacity 4`.
- El 10-nov, `opencode run` con `big-pickle` respondió: «Free usage limit reached. Connect a provider or subscribe to OpenCode Go to keep going, or switch models.». Si vuelve a pasar, aplica `FALLBACK_MODELS.md` y el ADR 0020.

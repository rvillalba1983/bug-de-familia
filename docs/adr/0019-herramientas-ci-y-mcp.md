# ADR 0019: herramientas locales, CI y estudio de MCP, formatters y LSP

Estado: aplicación aprobada como decisión técnica el 10-nov. En la rama
`feature/configuracion-opencode-agentes`, pendiente de fusión en `main`.

## Problema

El desarrollo necesitaba herramientas gratuitas que ahorren tokens y minutos de
 trabajo: un entorno local reproducible, comprobaciones deterministas y
 ejecutables generados sin intervención manual. El director pidió además estudiar
 si convenía instalar servidores MCP, y qué había de aprovechable en
 Formatters/LSP, Repos/GitHub y herramientas de desarrollo.

Restricciones que condicionan la decisión:

- Todo lo instalado debe ser **gratuito**. El único modelo de imágenes del
  catálogo de OpenCode es de pago y la cuenta no tiene fondos; queda descartado.
- El juego es **completamente offline** y el proyecto trabaja en **headless**
  (`godot --headless --import` y gdUnit4), no con el editor gráfico abierto.
- `docs/35_normas_codigo.md` (6.4 y 8.5): no instalar herramientas de procedencia
  dudosa, ni subir código o datos del proyecto a servicios externos sin
  autorización; cada dependencia añade coste de mantenimiento.
- Objetivo explícito del director: **ahorrar tokens**. Cada herramienta MCP
  añade sus esquemas al contexto en cada turno, incluso sin usarla.

## Decisión

### 1. Entorno local, gratuito y sin servicios externos

Instalado en `C:\Users\usuario\opencode_projects\` y añadido al PATH de usuario:
Godot 4.7.2 win64 (editor y consola), Python 3.12.10, ffmpeg, Inkscape 1.4.4
(instalación administrativa desde el MSI oficial) y las plantillas de
exportación 4.7.2.stable. Audacity ya estaba en el sistema. Godot importó el
proyecto sin errores. Ninguna de estas herramientas se usa en tiempo de
ejecución del juego.

### 2. Comprobaciones deterministas en scripts

| Script | Función |
|---|---|
| `tools/validar_datos.py` | 46 comprobaciones estructurales y de referencias cruzadas sobre `data/`; `--actualizar` regenera `tools/referencia_datos.json`; `--estricto` falla por conteos |
| `tools/formatear.py` | Aplica UTF-8 sin BOM, LF y una única línea final (`docs/35_normas_codigo.md` 3.1). Modo `--comprobar` para CI; avisa, sin reescribir, de líneas >100 caracteres e indentación con espacios |
| `tools/verificar.py` | Punto de entrada único: datos + normas, y comparación de medición si existe `medicion.txt` |
| `tools/comparar_medicion.py` | Compara `medicion.txt` con `tools/medir_windows/referencia.txt`; umbral +25 %, `--actualizar`, códigos 0/1 |

Al crear `formatear.py`, el modo `--comprobar` detectó que **12 archivos del repo
incumplían la norma de línea final** (9 JSON de `data/` y 3 pruebas). Se
corrigieron con el propio formateador: no se debilitó el chequeo. Estado actual:
`OK: 46 comprobaciones, 23 archivos` y `OK: 255 archivos revisados, 0 errores,
64 con avisos`. Los avisos son deuda preexistente de líneas largas; no bloquean.

`formatear.py` se registra además como **formatter propio** de OpenCode
(`formatter.normas-proyecto` en `opencode.jsonc`), porque los formatters
integrados no cubren GDScript (`.gd`) ni escenas (`.tscn`). Requiere `python` en
el PATH; si no está, OpenCode registra el fallo y continúa.

### 3. GitHub Actions (Repos/GitHub)

| Workflow | Disparador | Resultado |
|---|---|---|
| `.github/workflows/pruebas.yml` | push a cualquier rama y PR | Importa, ejecuta las 311 pruebas gdUnit4 con `timeout 900` y `</dev/null`, y publica resumen. Antes de descargar Godot corre `python3 tools/verificar.py`, que falla rápido y ahorra minutos |
| `.github/workflows/exportar.yml` | push a `main` y despacho manual | Exporta el preset «Windows» y sube `.exe` y `.pck` como artefactos |

Ambos cachean binarios y plantillas (tier gratuito: 2000 min/mes), usan
`concurrency` con cancelación y versiones estables de las acciones. `build/` se
añadió a `.gitignore`. `gh` ya estaba autenticado con ámbitos `repo` y
`workflow`.

### 4. MCP servers: **no se añade ninguno al proyecto**

En OpenCode V2 MCP **no es un plugin**: es configuración nativa bajo
`mcp.servers` (documentación oficial V2). No hay nada que instalar para
«activarlo». El director configuró el 10-nov, en otra sesión y en la
**configuración global de usuario** (`~/.config/opencode/opencode.json`), el
servidor remoto oficial de GitHub (`https://api.githubcopilot.com/mcp/`, con
`oauth: false` y `Authorization: Bearer {env:GITHUB_TOKEN}`). Está conectado:
expone 46 herramientas. No lo ha instalado este trabajo, no se modifica y no
forma parte del repositorio. La configuración del proyecto no define ningún
servidor MCP.

Estudio de candidatos, incluido el ya presente:

| Candidato | Veredicto | Motivo |
|---|---|---|
| GitHub MCP (ya configurado por el director, global) | Se mantiene, **no se usa por defecto en este repo** | Es decisión del director y el repo ya vive en GitHub, así que no hay dato nuevo que salga. Para este proyecto se prefiere `gh` y los workflows: mismas operaciones, sin 46 herramientas en el contexto. Con `codemode` por defecto las herramientas MCP no entran en la lista nativa, lo que reduce el coste, pero siguen ocupando el catálogo de Code Mode |
| Godot Editor MCP (`hybridindie/godot-mcp`, `NPGameDev/godot-mcp-toolkit`, `Sods2/godot-mcp`, otros) | No | Exigen Node 22+/npm, `uv`/Python o Bun (ninguno instalado), un **editor Godot gráfico abierto** y un addon dentro de `addons/`. Invierten el flujo headless del proyecto, añaden 52-180 herramientas al contexto y son dependencias de terceros a revisar según 8.4 |
| Context7 / grep.app / Playwright / filesystem | No | Duplican `webfetch`/`websearch`, el navegador del panel y las herramientas nativas de archivos; son remotos o añaden contexto sin aportar capacidad nueva |

La documentación oficial advierte: «MCP tools consume model context, so add only
the servers you need», y la de V1 señala explícitamente que el MCP de GitHub
puede agotar la ventana de contexto. Añadir más servidores iría **en contra del
ahorro de tokens** que pide el director. Si en la post-beta hiciera falta
conducir el editor gráfico (capturas, escenas en vivo), se reevaluará entonces
con una prueba de concepto aislada y un ADR nuevo.

### 5. Formatters y LSP

- **Formatters**: los integrados (prettier, biome, ruff, gofmt, etc.) no cubren
  los archivos del proyecto. Se activa solo el formatter propio del apartado 2.
- **LSP**: no se activa. No hay servidor LSP integrado para GDScript en la lista
  oficial, el proyecto no tiene un editor gráfico en marcha y la propia
  documentación recomienda, para muchos proyectos, alimentar al agente con
  herramientas CLI de diagnóstico en vez de servidores LSP (se desincronizan,
  consumen memoria y varían por versión). Esa función ya la cumplen
  `godot --headless --import`, gdUnit4, `validar_datos.py` y `verificar.py`,
  todos deterministas y documentados en `AGENTS.md`.
- **Herramientas de desarrollo adicionales**: `watcher.ignore` excluye
  `.godot/`, `build/`, `export/` y `reports/`; el comando `/verificar` evita
  recordar rutas. Sin plugins de terceros: requieren Node/Bun, no están
  verificados y añaden contexto.

### 6. Plantillas de arte

El generador de imágenes de OpenCode (`gpt-image-2.5-sunburst`, único del
catálogo) es **de pago** y falló con «Insufficient account funds». El director
confirmó que no se quiere. Las plantillas de mohócrata se generan como **SVG por
código**, con la paleta y los helpers de `tools/art/beta_assets_gen.py`,
conservando tallo, raíces y boca del rig actual para que `rig_split.py`, las
animaciones y el atlas sigan valiendo. Es la vía del pipeline existente y no
cuesta nada.

## Consecuencias

- `python` debe estar en el PATH para el formatter y los scripts; en este clon
  está en `C:\Users\usuario\opencode_projects\python\`. En CI se usa `python3`.
- Ejecutado ya: la suite local de 311 pruebas pasa al completo en Windows
  (22 min 28 s, 0 fallos). El primer run de `pruebas.yml` en Linux ejecutó
  311/311 con **3 fallos** de estado global entre suites; se corrigieron con
  `before_test()` en tres ficheros de pruebas, sin debilitar ningún `assert`
  (24/24 en esas tres suites, verificado en local).
- El segundo run parecía rojo pero la API de GitHub lo da como **`cancelled`**,
  no `failure`: fue cancelado a los 7 min 12 s por un push nuestro, porque el
  workflow tiene `cancel-in-progress: true`. No había ni un `FAILED` ni
  `Overall Summary`; el `cat pruebas.log` nunca llegó a ejecutarse. Se comprobó
  contra la API (`run_started_at`, `updated_at`, `head_sha` de los runs) con
  un subagente de solo lectura. Quedan sin verificar en Linux los 3 arreglos y
  el tiempo real de la suite corregida: hace falta un run completo.
- Ajustes aplicados en `pruebas.yml` tras ese diagnóstico: `paths-ignore` para
  commits que solo tocan documentación, `pull_request` limitado a
  `opened/reopened/ready_for_review` para no duplicar cada push con un run de
  PR, `timeout -k 30 1200` y `timeout-minutes: 30` para que el límite del job
  no enmascare el código 124 del timeout, y una nota de procedimiento: **no
  empujar mientras el run de verificación esté en curso**. Con la PR abierta
  cada push costaba ~16 min (dos runs); estos cambios lo dejan en ~8 min.
- **Run completo del HEAD final (`3aed01f`): verde**, 311/311 con 0 fallos en
  7 min 46 s. Confirma los arreglos de estado global en Linux.
- El CI ha destapado además un **fallo intermitente preexistente**: sobre el
  mismo SHA, el run de `push` pasó 311/311 y el de PR falló en
  `test_ruta_fuerza_completa_los_cuatro_retos` (`fallen_ids` vale 1). Ya
  aparecía en el primer run, antes de los arreglos, con código de juego
  idéntico a `main`: no lo introduce esta rama. Registrado como **P-39** en
  `01_CONFLICTOS_Y_PENDIENTES.md` con el diagnóstico del arnés de tiempo y la
  corrección propuesta, sin relajar ninguna aserción. No se marca como flaky
  ni se desactiva.
- 64 avisos de líneas largas siguen pendientes; son deuda anterior y no
  bloquean. No se reescribieron para no mezclar cambios de formato con lógica.
- Ambos workflows se validaron con un parser YAML real (PyYAML instalado solo
  en el entorno de desarrollo, no en el repo) y GitHub registró `pruebas.yml`
  al ejecutarlo. `exportar.yml` solo se registra al estar en `main`: su primera
  ejecución será tras la fusión. La exportación local equivalente ya se probó
  (`bug_de_familia.exe` de 109 MB y `.pck` de 20 MB).
- Generadas capturas y vídeo reales de la zona beta con `tools/captura_partida.gd`
  sobre la gráfica del director (26 PNG + MP4), para acreditar que el entorno
  puede producirlas. No se integran en el juego.
- Las herramientas locales no forman parte del juego exportado: los presets
  excluyen `addons/`, `tests/`, `tools/` y `docs/`.

## Alternativas consideradas

- **Instalar un MCP de Godot para manejar el editor**: rechazada por coste de
  contexto, dependencias no instaladas, procedencia de terceros y ruptura del
  flujo headless.
- **MCP de GitHub en vez de `gh` + Actions**: rechazada por duplicidad, coste de
  contexto y servicio externo sin autorización.
- **Activar `lsp: true` / `formatter: true` sin más**: rechazada; ningún servidor
  ni formatter integrado entiende GDScript, y `formatter: true` habilitaría
  reescrituras no deseadas si apareciera prettier o ruff en el proyecto.
- **Plugin de marketplace para el cierre de fase o el control de coste**:
  rechazada; requiere Node/Bun, es de procedencia no verificada y añade
  herramientas al contexto. Ya existe el plugin global `@taraksh011/oc-usage`
  para consumo, instalado antes de este ADR.

# ADR 0047: música zonal de cuerda pulsada en las 24 zonas (26-nov)

Estado: decisión del director del 26-nov, implementada en la rama
`fase/musica-24-zonas`, **EN CURSO y sin fusionar**. PR abierto, pendiente de
aprobación. El director escuchó los cues zonales en el exe de prueba y aprobó
la paleta («Sí, abre el PR»), igual que los diez cues de `adr/0045`. Las
rotaciones de modelos durante la fase se registran en `adr/0046`.

## Contexto

`adr/0045` añadió diez cues de cuerda pulsada y los integró solo en
`despliegue_cero`: las otras 23 zonas seguían sin `MusicDirector`, aunque su
música estaba prevista en los objetivos de `docs/37_audio.md`. El director
aprobó esos diez cues en partida («me parecen bien») y pidió extender la
paleta al resto del mapa.

El director eligió el 26-nov dos opciones: **«cues nuevos por zona»** y
**«día, noche y tensión»** para las 23 zonas que no son `despliegue_cero`.
Después precisó una tercera decisión: en **tensión suena siempre el cue de la
zona** en las zonas genéricas, sin caer en los cues compartidos de otra zona.
`despliegue_cero` conserva sus cuatro barrios y sus diez cues anteriores.

## Decisión

### 1. Sesenta y nueve pistas, una por zona y estado

`audio/music/zona_<id>_<estado>.ogg` cubre los 23 identificadores de
`data/zones/*.json` excepto `despliegue_cero`, con los estados `dia`, `noche` y
`tension` (23 × 3 = 69). Cada pista declara `zone` con su id, `any_zone=false`,
`palette="cuerda_zonal"` y `ambient` solo en calma. La tensión sube 18 BPM,
igual que en `adr/0045`.

Combate y festival siguen usando la biblioteca original de 100 pistas. En
`despliegue_cero` no cambia la selección: sus cuatro barrios comparten los
diez cues `cuerda_pulsada` aprobados en `adr/0045`.

### 2. Catálogo, tamaño y nivel

`data/audio/library.json` pasa de **110 a 179 pistas**: 100 originales +
10 `cuerda_pulsada` + 69 `cuerda_zonal`. `tools/referencia_datos.json` se
actualizó con el nuevo conteo; `tools/validar_datos.py --estricto` lo acepta.

Los 69 OGG suman **5.024.149 bytes** (~4,79 MiB). El pico decodificado
máximo es **−2,1 dB** (0,785 lineal), sin saturación. Coste: **0 créditos**.
Síntesis local con `numpy`, `scipy` y `ffmpeg` (libvorbis), sin servicios
externos ni muestras de terceros. Origen registrado en el campo `origin` del
catálogo: `tools/audio/gen_audio.py`, `tools/audio/gen_cuerda_cues.py` y
`tools/audio/gen_cues_zonas.py`, 26-nov-2026.

### 3. Generador incremental e idempotente

`tools/audio/gen_cues_zonas.py [carpeta]` reutiliza `gen_cuerda_cues.py` y
`gen_audio.py`. Usa semillas `n=111..179` y `default_rng(30000+n)`; el lead
rota en guitarra, laúd, oud y shamisen. Solo escribe los OGG que faltan y
comprueba que no haya entradas sin archivo ni archivos sin entrada; una
segunda ejecución no modifica nada.

Para ampliar esta paleta **no hay que ejecutar** `gen_audio.py` ni
`gen_cuerda_cues.py`: el primero regeneraría la biblioteca y las voces, y el
segundo podría sobrescribir sus propias pistas. Tras ejecutar el generador
zonal hace falta `godot --headless --import` para crear los 69 `.import`.

### 4. Integración en código

- `MusicDirector.level` pasa de `DespliegueCeroZone` a `ZoneBase` tipado.
- `MusicDirector.zone()` delega en `level.music_zone()`; ya no calcula barrios
  con `DespliegueCeroLayout`.
- `ZoneBase.is_night()` centraliza los umbrales de noche (21:00 y 08:00) y
  `MusicDirector.situation()` la usa en lugar de `atmosphere.is_night()`.
- `battles` y `fight` se comprueban por nulidad antes de leer su fase, porque
  las zonas genéricas no montan esos directores.
- `MusicDirector` se crea **una sola vez** en `ZoneBase._ready()`; se retiró
  la creación duplicada de `DespliegueCeroZone`.
- `DespliegueCeroZone` sobreescribe `music_zone()` con sus cuatro barrios y
  devuelve `music_prefers_own_zone() == false`. Las zonas genéricas devuelven
  `true`, de modo que calma y tensión prefieren las pistas de su propio id.

## Consecuencias y limitaciones

- El lote añade 4,79 MiB de audio local. Se exportó `build/prueba_cuerda_zonas.exe`
  (109.268.480 bytes) y su `.pck` (44.167.928 bytes) solo para la escucha; el
  `.exe` oficial se regenerará al fusionar.
- Los diez cues de `adr/0045` siguen vigentes e intactos en `despliegue_cero`;
  esta decisión los amplía, no los sustituye.
- Sin ejecutar: suite completa `res://tests` y medición en gráfica real.
  La escucha manual en partida fue aprobada por el director el 26-nov.
- El `.exe` oficial y `docs/03_ESTADO.md` se actualizarán solo cuando se
  fusione la rama, según `adr/0023-exe-en-cada-fusion.md`.

## Verificación ejecutada (26-nov)

- `godot --headless --import`: sin errores de script; se crearon los 69
  `.import` de los OGG zonales.
- `tests/zones/music_zones_test.gd`: **6/6** (`report_60`, JUnit validado).
- `tests/despliegue_cero/music_test.gd`: **9/9** (`report_61`, JUnit validado).
- Carpeta `tests/zones` completa: **88/88** en una pasada anterior a añadir
  el sexto caso (`report_57`, JUnit validado).
- El caso nuevo de tensión se comprobó que **falla con el algoritmo antiguo**,
  antes de aplicar la preferencia por la zona activa.
- `python tools/verificar.py`: OK. `python tools/validar_datos.py --estricto`:
  OK. `python tools/formatear.py --comprobar`: 0 errores y 78 avisos
  preexistentes.
- `python tools/verificar_humo.py` sobre `build/prueba_cuerda_zonas.exe`: OK
  (motor 4.7.2, partida esquema 3, 36 individuos en `despliegue_cero`).
- CI del PR #48 verde en los runs `45907863552` y `45907888483` (todos los
  jobs, incluidos arranque exportado y los cuatro grupos de GdUnit4).
- `.exe` oficial regenerado desde la rama con el preset «Windows» antes de
  pedir la fusión (`adr/0023`): 109.268.480 bytes; los 69 cues zonales y los
  10 de `adr/0045` están dentro del `.pck`.

## Referencias

- `adr/0045-musica-ambiental-cuerda-pulsada.md` (paleta y diez cues previos).
- `adr/0046-rotacion-arquitecto-y-a-gratuitos.md` (rotaciones de modelos).
- `adr/0023-exe-en-cada-fusion.md` (fusión del `.exe` y del estado).
- `docs/02_DECISIONES.md`, «Música zonal en las 24 zonas (26-nov)».
- `docs/37_audio.md` (estado de la biblioteca y validación de audio).
- `docs/03_ESTADO.md` (traspaso de la fase en curso).
- `HERRAMIENTAS.md`, §7 (generador `gen_cues_zonas.py`).

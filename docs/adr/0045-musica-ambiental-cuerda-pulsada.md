# ADR 0045: música ambiental de cuerda pulsada (26-nov)

Estado: decisión del director del 26-nov, implementada en la rama
`fase/audio-ambiental-cuerda` y **fusionada en `main`** (PR #47, merge
`2146d76`). El director escuchó los cues en el exe de prueba y aprobó la
paleta («me parecen bien»); el CI del PR terminó en verde.

**Nota (26-nov, `adr/0047`):** estos diez cues siguen vigentes e intactos en
`despliegue_cero`. La fase `fase/musica-24-zonas` los amplió con 69 cues
zonales para las otras 23 zonas; está EN CURSO y sin fusionar.

## Contexto

`docs/03_ESTADO.md` recogía desde el 14-nov una preferencia de diseño: la música
actual a veces sonaba «muy estridente» y se quería un enfoque más ambiental, con
sonidos relajantes en zonas tranquilas y tempo creciente en tensión. La paleta
deseada era guitarra clásica o instrumentos de cuerda pulsada de todo el mundo
(guitarra, laúd, oud, shamisen, etc.).

El director eligió esta fase el 26-nov y autorizó explícitamente un lote de
8-12 cues nuevos generados en local, sin servicios externos ni créditos. La
biblioteca tenía 100 pistas (30 día, 20 noche, 18 tensión, 17 combate y 15
festival) con leads de flauta, acordeón, marimba y laúd, además de 120 muestras
de voz. Ejecutar `tools/audio/gen_audio.py` tal cual habría regenerado también
las voces y sobrescrito `data/audio/library.json`, así que se descartó.

## Decisión

### 1. Diez cues nuevos, sin regenerar la biblioteca

`tools/audio/gen_cuerda_cues.py` añade diez pistas (`cuerda_001.ogg` a
`cuerda_010.ogg`): cuatro de día, dos de noche y cuatro de tensión. Usa los
presets locales `laud` del generador original y tres nuevos: `guitarra`
(Karplus-Strong con cuerpo), `oud` (quinta al aire) y `shamisen` (ataque seco y
armónico atenuado). No hay batería; las pistas tranquilas llevan un drone suave
y las de tensión suben 18 BPM a lo largo del cue. Fundidos de entrada y salida,
pico 0,72 y semillas fijas por pista. El generador es idempotente: solo reemplaza
sus propias pistas y deja intactas las 100 originales y las 120 voces.

### 2. Metadatos y selección

Las pistas nuevas llevan `palette="cuerda_pulsada"`, `ambient`, `lead` y
`bpm_fin`; las originales reciben `palette="original"` sin cambiar sus archivos
ni sus campos existentes. `MusicDirector.pick()` prefiere la paleta de cuerda en
`dia`, `noche` y `tension` cuando queda al menos un cue fresco para la zona; si
no lo hay, mantiene el comportamiento anterior. Combate y festival no cambian.
La anti-repetición (`RECENT_SIZE = 6`), los fundidos y la carga en segundo plano
siguen iguales.

El azar propio del director se fija ahora en 1234 para que la selección sea
reproducible en pruebas. En Godot 4.7.2 `RandomNumberGenerator.seed` es una
propiedad, así que se asigna (`_rng.seed = RNG_SEED`), no se llama como método.
Esto no toca la semilla de la partida.

### 3. Origen y herramienta

- Síntesis local con `numpy`, `scipy` y `ffmpeg` (libvorbis), 22.050 Hz mono.
- Registro: `tools/audio/gen_audio.py` + `tools/audio/gen_cuerda_cues.py`,
  26-nov-2026, sin muestras de terceros, sin servicios externos y sin créditos.
- Los diez `.ogg.import` se generaron con `godot --headless --import`.
- Ningún recurso se subió a un servicio externo; el juego sigue funcionando
  sin red.

## Consecuencias y limitaciones

- Los diez OGG añaden unos 0,8 MB a `audio/music/`. La exportación Windows del
  26-nov generó un `.exe` de 109.268.480 bytes y un `.pck` de 38.004.572 bytes.
- La suavidad se ha medido y escuchado: frente a ocho pistas originales, el
  centroide espectral medio baja de 2590 Hz a 2165 Hz (−16 %) y el RMS de 0,097
  a 0,074; el pico queda en 0,769 (0,772 en las originales), sin saturación.
  El director escuchó los cues en partida y aprobó la paleta.
- En esta fase solo se instanciaba `MusicDirector` en `despliegue_cero`.
  `adr/0047` lo extiende a las otras 23 zonas con música zonal; combate y
  festival conservan la paleta anterior.
- Si se ejecuta el generador completo (`gen_audio.py`) se perderían los nuevos
  campos del catálogo. Para ampliar la paleta hay que usar el generador
  incremental.
- No se ha ejecutado la suite completa `res://tests` ni medición en gráfica
  real. El CI del PR sí ejecutó la prueba de humo del binario Linux exportado.

## Incidentes y verificación ejecutada (26-nov)

- La primera ejecución de GdUnit colgó en el prompt `debug>` por llamar a
  `_rng.seed(...)` como método. Se detuvieron los procesos Godot del test
  (PID 15072 y 21052) y se corrigió a asignación de propiedad.
- `--check-only -s` sobre `music_director.gd` y `music_test.gd`: sin errores de
  parseo. `godot --headless --import`: sin errores de script.
- `tests/despliegue_cero/music_test.gd`: **8/8** (`reports/report_53`, 0 fallos,
  0 errores, 0 omitidas).
- `python tools/validar_informes.py --grupo despliegue_cero --minimo 8
  --argumentos-gdunit "-a res://tests/despliegue_cero"`: informe JUnit fiable.
- `python tools/verificar.py`: OK (105 comprobaciones, 313 literales `res://`,
  900 conversaciones). `python tools/formatear.py --comprobar`: 0 errores y
  78 avisos preexistentes.
- CI del PR #47: 4/4 jobs verdes (runs `45899765032` y `45899809971`).
  `.exe` oficial regenerado con el preset «Windows» antes de la fusión; se
  comprobó que el `.pck` contiene los diez cues.
- El director probó `build/prueba_cuerda.exe` y aprobó la paleta sonora
  («me parecen bien»), registrado en el PR. Fase fusionada en `main`
  (`2146d76`).

## Referencias

- `docs/03_ESTADO.md`, «Pendiente de respuesta del usuario» (preferencia de
  paleta sonora del 14-nov).
- `docs/37_audio.md` (objetivos de música ambiental y validación de audio).
- `docs/adr/0013-audio-y-rendimiento.md` (origen de las 100 pistas y las voces).
- `docs/adr/0031-sonido-direccional-y-timbre-ia.md` (buses y timbres).

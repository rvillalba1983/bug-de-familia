# ADR 0031: sonido direccional con oclusión y timbre por IA

Estado: **en revisión** (15-nov-2026). Rama `fase/p09-p29-p30-p32-p36-p39-p41`.

## Contexto

P-29 (pedido del director, 9-nov): «Sonido con posición (`AudioStreamPlayer2D`) y efectos de
audio. Oír de dónde viene un guardia y si está tras una pared, como información de sigilo;
timbre propio de cada IA (radio rota, eco, distorsión) sin generar más voces. Requiere añadir
sonidos a los personajes, como los pasos».

La parte de los pasos ya estaba hecha (P-15): `audio/footstep_audio.gd` es un
`AudioStreamPlayer2D` que suena en el jugador y en los guardias, con `attenuation` y
`panning_strength`. Lo que faltaba era lo que hace útil ese sonido:

1. **Saber si el guardia está detrás de un muro.** Con el posicional solo, un guardia tras una
   pared suena igual de fuerte y claro que uno en la misma habitación.
2. **Distinguir a las IAs por el timbre.** Las veinte IAs del equipo hablan con el mismo timbre
   de «blabla»: se distinguen por el texto y el color, no por la voz.

Restricción: **sin generar más voces**. Hay 40 perfiles grabados (3 tomas cada uno) y no se
pueden añadir archivos de voz.

## Comprobación previa: qué ofrece el motor

Godot 4.7.2 **no tiene** oclusión de audio incorporada. Comprobado contra el motor instalado
(`tools/verificar_apis_godot.gd`):

- `AudioStreamPlayer2D` **no** tiene propiedad `occlusion` (las propiedades reales son `stream`,
  `volume_db`, `volume_linear`, `pitch_scale`, `playing`, `autoplay`, `stream_paused`,
  `max_distance`, `attenuation`, `max_polyphony`, `panning_strength`, `bus`, `area_mask` y
  `playback_type`).
- La clase `AudioEffectOcclusion` **no existe** en 4.7.2.
- Sí existen `AudioEffectLowPassFilter`, `AudioEffectBandPassFilter`, `AudioEffectDistortion`
  (con `MODE_CLIP`, `MODE_ATAN`, `MODE_LOFI`, `MODE_OVERDRIVE` y `MODE_WAVESHAPE`),
  `AudioEffectReverb` y `AudioEffectPitchShift`.
- `AudioServer` permite crear buses en marcha (`add_bus`, `add_bus_effect`), y el proyecto ya
  lo hacía para `Musica` y `Voces`: no hay bus layout en el repositorio.

De ahí sale la decisión: **la oclusión y el timbre se hacen con buses y filtros**, no con una
propiedad que no existe.

## Decisión

### 1. Buses nuevos

`core/audio_mixer.gd` crea, además de `Musica` y `Voces`:

| Bus | Para qué | Efectos |
|---|---|---|
| `Pasos` | pasos con línea de visión directa | ninguno |
| `PasosTapados` | pasos con un muro de por medio | `AudioEffectLowPassFilter` (900 Hz) |
| `VocesRadio` | IAs con timbre de radio | `AudioEffectBandPassFilter` (1700 Hz) + `AudioEffectDistortion` en modo LOFI |
| `VocesEco` | IAs con timbre de eco | `AudioEffectReverb` (sala 0.9, dry 0.5, wet 0.7) |
| `VocesDistorsionada` | IAs con timbre distorsionado | `AudioEffectDistortion` en modo OVERDRIVE (drive 6) |

Los cuatro buses de voz heredan el ajuste de volumen de las voces de las opciones, así que
mutar las voces silencia también los tres timbres.

### 2. Oclusión de los pasos

`audio/footstep_audio.gd` gana dos propiedades: `listener` (quien oye, el jugador) y
`occludable`. En cada paso, `is_muffled()` lanza un rayo del oyente al paso contra la capa
`PhysicsLayers.WALLS` (con el helper `Detector.ray_end`, que ya se usaba para lo que oye un
guardia). Si el rayo choca:

- el paso suena en el bus `PasosTapados` (agudos attenuated, se oye más lejos),
- baja 7 dB y el tono cae un 12 % (`MUFFLED_PITCH`), para que suene amortiguado y no igual.

El bus se decide justo antes de `play()`. Godot 4 enruta el sonido al bus en el momento de
mezclar, así que cambiarlo no reinicia el paso.

El jugador **no** usa oclusión: es el oyente, sus pasos no están detrás de nada. Los guardias
sí: `Guard.setup()` pasa el jugador como `listener` y activa `occludable`.

### 3. Timbre por IA

`data/ai/personalities.json` gana un campo `timbre` por IA, con cuatro valores posibles:
`normal`, `radio`, `eco` y `distorsion`. El reparto se hizo a mano, para que case con el
personaje: las máquinas y los descuidados (`panico`, `pesimo_optimus`, `friki`, `siestaware`,
`sargento_bit`) suenan a radio de bolsillo; los que hablan en espacios vacíos (`abuela`,
`matriz`, `conspi`, `nihil`, `burocrata`) tienen eco; los de carácter ácido (`dr_desprecio`,
`mama`, `troll`, `rencorosa`, `chef`) salen distorsionados; las demás, normales.

`BlablaVoice.speak()` acepta el timbre, elige bus con `AudioMixer.bus_for_timbre()` y, en el
caso de la radio, **desajusta el tono** de forma aleatoria (entre 0.86 y 1.14), como una radio
que se va de frecuencia. Los clips grabados se siguen usando: el timbre lo pone el filtro del
bus, no hace falta regenerar ninguna voz.

El reparto de timbres se aplicó con `tools/asignar_timbre_ias.py`, que inserta la clave tras el
`pitch` de cada IA sin reformatear el fichero.

## Consecuencias y limitaciones

- **El número de buses crece.** Son cuatro buses nuevos, creados en marcha; el coste por bus es
  una cadena de efectos y solo se procesa si hay audio en él.
- **El eco cuesta más que los otros filtros.** `AudioEffectReverb` es el más caro de los
  cuatro; solo se activa cuando habla una IA con ese timbre.
- **La oclusión se calcula en el paso, no en tiempo real.** Si un guardia cruza una pared
  mientras su paso suena, ese paso conserva el timbre con el que empezó. El paso dura 0,2 s y
  el intervalo entre pasos es de 0,3 a 0,62 s, así que el error es pequeño.
- **Solo los pasos hacen oclusión.** No hay sonidos de alerta ni de ataque: no hay archivos de
  ese tipo, y generarlos no estaba en el encargo.
- **Las preferencias de las IAs son provisionales.** El reparto de timbres lo eligió el equipo;
  el director puede cambiarlo en `data/ai/personalities.json` sin tocar código.
- Falta la **validación manual en partida**: que el timbre de cada IA se reconozca y que el paso
  tapado se distinga del claro sin tener que mirar la pantalla.

## Referencias

- P-29 en `docs/01_CONFLICTOS_Y_PENDIENTES.md`.
- P-15 (pasos posicionales) y P-29 parcial en `docs/03_ESTADO.md`.
- Implementación: `core/audio_mixer.gd`, `audio/footstep_audio.gd`, `ai/blabla_voice.gd`,
  `ai/ai_chatter.gd`, `entities/enemies/guard.gd`, `data/ai/personalities.json`.
- Comprobación de APIs: `tools/verificar_apis_godot.gd`.
- Pruebas: `tests/core/audio_direccional_test.gd`.

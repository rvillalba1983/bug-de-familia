# ADR 0013: audio y rendimiento (fase 9)

Estado: pendiente de aprobación del director.

## Audio
- Origen: `tools/audio/gen_audio.py`, síntesis local con numpy, scipy y ffmpeg. Autor: Claude. Sin muestras ni servicios externos. Fecha: 9-nov. Semilla por pista.
- 100 pistas de 34 a 46 s en `audio/music/` (13 MB), con estado, barrio, tempo, escala, capas y fundido en `data/audio/library.json`: día 30, noche 20, tensión 18, combate 17 y festival 15.
- 40 perfiles de voz con 3 tomas en `audio/voices/` (1,3 MB). Cada IA tiene un perfil fijo. **Son cadencias inventadas, no acentos humanos reales**, porque aquí no se pueden grabar voces: el objetivo de 40 idiomas sigue abierto.
- `audio/music_director.gd` elige por situación, hora y barrio, con fundidos y carga en segundo plano.

## Validación de audio
Medido: pico 0,72 en música y 0,80 en voces, sin saturación. Volumen medio por situación entre -18,7 y -20,7 dB. Parecido espectral medio entre pistas 0,91 sobre 1: se parecen entre sí, como aceptó el director. Nadie las ha escuchado todavía: Claude solo puede medirlas.

## Rendimiento medido (Godot 4.7.2 sin ventana, CPU, 300 muestras, `tools/medir_rendimiento.gd`)
| Caso | Personajes | Física media | Física p99 | Proceso medio | Proceso p99 |
|---|---|---|---|---|---|
| Normal | 23 | 7,8 ms | 13,1 ms | 0,7 ms | 0,8 ms |
| Normal | 43 | 7,2 ms | 8,6 ms | 1,5 ms | 1,7 ms |
| Pausa | 43 | 0,1 ms | 0,1 ms | 1,4 ms | 1,5 ms |
| Batalla | 43 | 5,8 ms | 7,4 ms | 2,0 ms | 3,2 ms |

Sin medir en una gráfica real: el dibujo y el nuevo filtro de pantalla. Debe comprobarlo el director en su ordenador.

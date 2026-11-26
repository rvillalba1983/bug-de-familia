# Audio

## 6. Música

Objetivo de contenido:
- Al menos 100 melodías no repetitivas.
- Mezcla de música ambiental, temas regionales y música asociada a acontecimientos.
- Referencia de estilo: acústico, tribal y world music, adaptado a la identidad del juego.
- Transiciones contextuales por zona, hora, tensión y evento.
- Evitar cortes bruscos y repeticiones demasiado frecuentes.

Preparar metadatos por pista: zona, estado, intensidad, duración, capas, transiciones y condiciones de uso.

## 7. Voces y sonidos de criaturas

Objetivo post-beta (aún sin hacer):
- Frases absurdas en diferentes idiomas y acentos; referencia previa de al menos 40 idiomas, con voces grabadas y acentos humanos reales.
- Los lenguajes de las criaturas se expresan mediante sonidos y gestos propios. Las frases multilingües forman parte de su carácter y humor; no implican que todas las especies hablen literalmente idiomas humanos.
- Preparar variantes de tono, duración, emoción, distancia y contexto.
- Evitar que un mismo personaje repita una frase de forma evidente.
- Todo el audio se incluye localmente y se reproduce sin red.
- No sintetizar voz mediante IA online durante la partida.

Estado actual: las voces son síntesis generada por código, no grabaciones, y no llevan acentos humanos reales. Ver la nota de estado más abajo.

## Estado en la fase 9

100 melodías y 40 perfiles de voz con 3 tomas cada uno, generados por `tools/audio/gen_audio.py`. Son síntesis por código, no grabaciones: los perfiles imitan cadencias inventadas y **no son acentos humanos reales**. Los objetivos de acentos reales y 40 idiomas de la sección 7 quedan para la post-beta. Ver `adr/0013-audio-y-rendimiento.md`.

## Estado en la fase de audio ambiental (26-nov)

La biblioteca pasa a **110 pistas**: las 100 originales siguen intactas y se
añaden 10 cues de cuerda pulsada generados por
`tools/audio/gen_cuerda_cues.py` (guitarra, laúd, oud y shamisen; 4 de día,
2 de noche y 4 de tensión). `MusicDirector` prefiere esa paleta en calma y
tensión cuando hay un cue disponible para la zona, sin tocar combate ni
festival. La elección tiene semilla fija (1234) y se mantiene la anti-repetición.
Los metadatos nuevos son `palette`, `ambient`, `lead` y `bpm_fin`; el campo
`bpm_fin` sube 18 BPM en los cues de tensión. Ver
`adr/0045-musica-ambiental-cuerda-pulsada.md`.

Medición de los diez cues frente a ocho pistas originales: pico 0,769 frente a
0,772; RMS medio 0,074 frente a 0,097; centroide espectral 2165 Hz frente a
2590 Hz. **Nadie los ha escuchado todavía**: la percepción de «menos estridente»
queda pendiente de validación manual en partida.

## 8. Validación de audio

Comprobar:
- Niveles y normalización.
- Ausencia de clipping.
- Transiciones y loops.
- Repetición perceptible.
- Claridad en mezclas con efectos.
- Volumen relativo de voces, música y ambiente.
- Tamaño total de biblioteca y memoria de audio.

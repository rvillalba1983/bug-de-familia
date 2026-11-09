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

- Voces pregrabadas.
- Frases absurdas en diferentes idiomas y acentos; objetivo previo de al menos 40 idiomas.
- Los lenguajes de las criaturas se expresan mediante sonidos y gestos propios. Las frases multilingües forman parte de su carácter y humor; no implican que todas las especies hablen literalmente idiomas humanos.
- Preparar variantes de tono, duración, emoción, distancia y contexto.
- Evitar que un mismo personaje repita una frase de forma evidente.
- Todo el audio se incluye localmente y se reproduce sin red.
- No sintetizar voz mediante IA online durante la partida.

## Estado en la fase 9
100 melodías y 40 perfiles de voz con 3 tomas cada uno, generados por `tools/audio/gen_audio.py`. Son síntesis, no grabaciones: los perfiles imitan cadencias inventadas y **no son acentos humanos reales**. Ver `adr/0013-audio-y-rendimiento.md`.

## 8. Validación de audio

Comprobar:
- Niveles y normalización.
- Ausencia de clipping.
- Transiciones y loops.
- Repetición perceptible.
- Claridad en mezclas con efectos.
- Volumen relativo de voces, música y ambiente.
- Tamaño total de biblioteca y memoria de audio.


Las IA hablan con texto y sonido tipo "blabla", con acentos humanos reales y frases sin sentido. Todo el audio es local.

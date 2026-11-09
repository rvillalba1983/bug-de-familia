# ADR 0007: estilo visual de la beta con Godot y SVG

Estado: aprobado el estilo por el director (9-nov). Pendiente de ejecutar en Godot y validar en partida.

## Decisión
- Paleta «Cuñado Radiactivo» en `entities/art/palette.gd`.
- Suelo, paredes, árboles, luces, noche, esporas y lluvia se dibujan con Godot.
- El suelo usa texturas repetibles horneadas con `tools/art/ground_gen.py`, y las murallas largas se trocean en edificios de altura y color distintos.
- Jubilados, Mohócratas, Don Ramón, minas, dron y bobina usan SVG de `art/beta/`.
- El protagonista se dibuja con polígonos de Godot por piezas, datos en `data/art/protagonista.json`. Sustituye al marcador provisional y toma como modelo la hoja de diseño, que sigue siendo la referencia.

## Limitaciones
- Protagonista: dos vistas, frente y espalda; los lados se resuelven reflejando. Las 8 direcciones reales quedan pendientes.
- Enemigos: una sola vista, reflejada según hacia dónde miran.
- La noche no altera las reglas; su oscuridad es provisional.
- La centralita y el depósito siguen siendo paredes transitables; sus SVG de fachada no se usan todavía.

## Procedencia de los recursos
Generados por Claude: SVG escritos a mano por script, y protagonista calcado de la hoja de diseño con `tools/art/protagonist_gen.py`. Sin servicios externos de imagen.

## Vídeo de muestra
El vídeo de 17 segundos enseñado al director es una simulación fuera de Godot, no una grabación del juego.

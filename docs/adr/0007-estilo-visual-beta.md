# ADR 0007: estilo visual de la beta con Godot y SVG

Estado: en prueba, pendiente de validar en partida.

## Decisión
- Paleta «Cuñado Radiactivo» en `entities/art/palette.gd`.
- Suelo, paredes, árboles, luces, noche, esporas y lluvia se dibujan con Godot.
- Jubilados, Mohócratas, Don Ramón, minas, dron y bobina usan SVG de `art/beta/`.
- El protagonista se dibuja con polígonos de Godot por piezas, datos en `data/art/protagonista.json`. Sustituye al marcador provisional y se prueba frente al acabado pintado de la hoja, que sigue siendo la referencia final.

## Limitaciones
- Protagonista: dos vistas, frente y espalda; los lados se resuelven reflejando. Las 8 direcciones reales quedan pendientes.
- Enemigos: una sola vista, reflejada según hacia dónde miran.
- La noche no altera las reglas; su oscuridad es provisional.
- La centralita y el depósito siguen siendo paredes transitables; sus SVG de fachada no se usan todavía.

## Procedencia de los recursos
Generados por Claude: SVG escritos a mano por script, y protagonista calcado de la hoja de diseño con `tools/art/protagonist_gen.py`. Sin servicios externos de imagen.

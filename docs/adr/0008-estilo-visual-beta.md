# ADR 0008: estilo visual de la beta con Godot y SVG

Estado: aprobado por el director el 9-nov, tras ejecutarlo en Godot 4.7.2 y ver capturas y vídeo reales.

## Decisión
- Paleta «Cuñado Radiactivo» en `entities/art/palette.gd`.
- Suelo, paredes, árboles, luces, noche, esporas y lluvia se dibujan con Godot.
- El suelo usa texturas repetibles horneadas con `tools/art/ground_gen.py`, y las murallas largas se trocean en edificios de altura y color distintos.
- Jubilados, Mohócratas, Don Ramón, minas, dron y bobina usan SVG de `art/beta/`.
- El protagonista se dibuja con polígonos de Godot por piezas, datos en `data/art/protagonista.json`. Sustituye al marcador provisional y toma como modelo la hoja de diseño, que sigue siendo la referencia.

## Direcciones y aspecto de las piezas
- Protagonista: 8 vistas. El cuerpo de los lados izquierdos se refleja; las cabezas no, porque cada mitad de la cara es distinta.
- Las vistas intermedias se calculan deformando las principales (`tools/art/protagonist_gen.py`).
- Piezas: 10 cabezas, 20 brazos y 10 piernas, con colores y complementos propios. La pieza original usa el aspecto 0.
- Las piezas convertidas eligen aspecto a partir de su nombre, sin gastar azar de la partida.
- NPC y dron: 4 direcciones (sur, este y norte dibujadas; oeste reflejada).

## Fachadas
- La centralita y el depósito tienen fachada propia, con la puerta encajada en la de la centralita.
- Al acercarse el jugador se vuelven translúcidas: si no, taparían las patrullas interiores y el sigilo perdería información. Distancias provisionales en `BuildingFacade`.

## Limitaciones
- Enemigos sin animación de andar.
- La noche no altera las reglas; su oscuridad es provisional.
- El cartel y la urna de esporas aún no están colocados en el mapa.

## Procedencia de los recursos
Generados por Claude: SVG escritos a mano por script, y protagonista calcado de la hoja de diseño con `tools/art/protagonist_gen.py`. Sin servicios externos de imagen.

## Vídeo de muestra
El vídeo de 17 segundos enseñado al director es una simulación fuera de Godot, no una grabación del juego.

## Texturas en `_draw`
Las llamadas de dibujo no retienen la textura: cargada con `load` dentro de `_draw` se libera y sale blanca. Se usa `preload` en constantes; `tests/art/draw_textures_test.gd` lo vigila.

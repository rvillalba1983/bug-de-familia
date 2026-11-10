# ADR 0025: alejazo puntual en la vista de estrategia (P-31, opción C)

Estado: decidido por el director el 10-nov-2026 e implementado de forma provisional.
Pendiente de validación visual en partida y de medición en gráfica real.

## Contexto
P-31 pedía enseñar edificios en la vista de estrategia «sin romper la cámara ni el
rendimiento». Con el encuadre original (`ZOOM_MAX = 1.9`, cámara centrada solo en los
luchadores), los edificios de `BetaLayout` quedaban reducidos a franjas de 84–152 px
y con poco contraste: el director reportó que «no ve nunca edificios».

Cálculo **estimado** con las posiciones de `brawl_patrol` (no medido en partida):
con zoom 1,9 el mundo visible es x[1595,2605] e y[1036,1604]; con zoom 0,6 pasa a
x[500,3700] e y[420,2220]. La ciudad mide 1640 px verticales, así que para que entre
completa hace falta un zoom de 0,659 o menor.

El director propuso un zoom que se aleje y acerque mucho y muy rápido. Cambiar la
perspectiva/cámara requiere aprobación (`35_normas_codigo.md:282`) y choca con
`02_DECISIONES.md:156` («Efectos en movimiento reducidos») y con la opción
«Reducir temblores y destellos» (P-33). Se le plantearon cuatro alternativas y eligió
la **C**: alejazo extremo solo en momentos puntuales, solo en la vista de estrategia,
aceptando ampliar `ZOOM_MIN`.

## Decisión
| Parámetro | Valor provisional |
|---|---|
| `ZOOM_MIN` | 0,6 (antes 0,7) |
| `PULSE_DECAY` | 2,5 (el pulso se consume en ~0,4 s de tiempo real) |
| Disparos | al abrir la vista (`open`) y al caer un luchador (`BattleDirector._strike`) |
| Objetivo del alejazo | `ZOOM_MIN` (el zoom base se interpola hacia él mientras dura el pulso) |
| `reduce_motion` | con la opción activa `pulse()` no hace nada: zoom fijo |
| Velocidad de batalla | el pulso decae en **tiempo real** (`delta / Engine.time_scale`): a x4 no marea cuatro veces más |

Implementación:
- `ui/strategy_view.gd`: `_base_zoom` (suavizado como antes) y `_pulse` (aplicado encima,
  de forma instantánea); `pulse()`, `tick_pulse()`, `pulse_level()` y
  `zoom_with_pulse()` (función estática y pura, para poder probarla).
- `scenes/beta/battle_director.gd`: `_strike()` llama a `_view.pulse()` **solo cuando
  alguien cae**, no en cada golpe, para que sea realmente puntual.
- No se toca la cámara del mundo, los controles, el combate ni las reglas de muerte.

## Consecuencias
- Los edificios pasan a verse como bloques de 264–320 px de alto durante el alejazo,
  en vez de franjas finas. La ciudad entera entra en pantalla.
- **No se ven de forma permanente**: con la opción C solo aparecen completos durante
  el alejazo. Si el director quiere verlos siempre, haría falta añadir el minimapa fijo
  (opción A), que queda sin hacer.
- Rendimiento: al alejar a 0,6, `_draw_dirt()` pasa de ~54 a ~345 puntos de suciedad
  durante ~0,4 s. Es una estimación por número de llamadas; **sin medición en gráfica
  real**. Las etiquetas siguen en coordenadas fijas y los muñequitos se encogen con el
  zoom durante el pulso.
- Se corrige además el comentario de cabecera y la ayuda de la vista, que decían
  «M abre y cierra» / «M: salir» y contradecían `02_DECISIONES.md:148`.

## Pruebas
`tests/ui/strategy_view_test.gd`: `ZOOM_MIN` permite ver la ciudad, el pulso aleja y
decae, y `reduce_motion` lo congela. `tests/beta/battle_test.gd`: al caer un guardia
la vista recibe el pulso; M abre y Esc cierra. No se desactivó ni debilitó ninguna
prueba.

## No ejecutado
Validación visual en partida, medición en gráfica real del coste del alejazo, y el
diagnóstico con Godot sobre la escena real (se colgó en `debug>` y se canceló; las
cifras de este ADR son analíticas, no medidas en partida).

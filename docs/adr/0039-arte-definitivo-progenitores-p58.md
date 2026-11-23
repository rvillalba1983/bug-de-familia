# ADR 0039: arte definitivo de los 15 progenitores con raster incrustado (23-nov)

Estado: aplicado en la rama `fase/p58-arte-progenitores`.
Pendiente de aprobación del director y fusión en `main`.

## Contexto
ADR 0038 entregó 75 SVG geométricos para los 15 progenitores (5 vistas cada
uno). El director encargó la fase P-58 sustituirlos por arte artístico
definitivo generado con modelo de imágenes, autorizando explícitamente el uso
de un servicio externo de generación y el cambio de modelo si el primero
fallaba. `docs/36_pipeline_graficos.md` mantiene la regla general de «Godot y
SVG, sin generadores de imágenes», con la salvedad de que el director puede
abrir el abanico para recursos concretos: esta fase es esa excepción.

Dos restricciones técnicas del proyecto condicionan el formato:

- `GuardVisual._view_texture()` construye la ruta con la extensión `.svg`
  fija (`entities/enemies/guard_visual.gd`, línea 90).
- `tools/validar_datos.py` exige 75 ficheros `<id><sufijo>.svg` y la ruta
  exacta `progenitores/<id>` (`validar_dialogos_progenitores`, línea 1294).

`docs/03_ESTADO.md` también fija `gl_compatibility` y sin recursos en red
durante la partida.

## Decisión
Mantener los nombres `.svg`, el `viewBox="0 0 512 560"` y el tamaño de
visualización 256 × 280, pero sustituir el contenido vectorial por un único
elemento `<image>` con el mapa de bits incrustado en base64 (`data:image/png;
base64,`). El raster se genera con un modelo de imágenes, se limpia y se
escala antes de incrustarlo.

Consecuencias de esta decisión:

- No cambia ninguna ruta: `data/world/progenitors.json` conserva
  `art: "progenitores/<id>"`, `GuardVisual` sigue pidiendo `.svg` y
  `validar_datos.py` sigue contando 75 vistas. No se toca lógica de juego.
- El PNG va dentro del SVG; no hay ficheros nuevos ni peticiones en
  tiempo de ejecución. El juego sigue funcionando sin conexión.
- El fondo del modelo es blanco y opaco. Se elimina por relleno de los
  componentes blancos conectados al borde y se escala a 512 × 560 con los
  pies en y = 520 (0,93 de la altura, como `GuardVisual.ART_FEET`).
- Se conserva el contorno `#1B0E2A` y las sombras `#6A2BA8` de la paleta
  «Cuñado Radiactivo» en el prompt de cada vista.

### Herramientas y reproducibilidad
- `tools/art/progenitores_prompts.py`: plantilla de prompt. Lee nombre,
  color, material y propiedad fija de `data/world/progenitors.json` y la
  consecuencia de muerte de `data/conversation/progenitors.json`, y compone
  el texto con el estilo, la cámara y la vista. Puede volcar los 75 prompts a
  un manifiesto JSON.
- `tools/art/progenitores_raster_a_svg.py`: limpia el fondo, recorta,
  escala a 512 × 560 y escribe el SVG con el PNG incrustado.
- Modelo usado: `openrouter/recraft/recraft-v4.1-flash-v2:free` para las
  15 vistas base (acepta prompt de texto, no imágenes de entrada). Para las
  vistas diagonales se usaron `openrouter/microsoft/mai-image-2.7-flash` y
  `openrouter/bytedance-seed/seedream-5-5`, que sí aceptan la vista base como
  referencia (en PNG). El modelo por defecto (`opencode/minimax-h3-image`)
  falló por saldo insuficiente; el cambio está autorizado por el encargo.
- **Fallback determinista (decisión del director, 23-nov):** al agotarse los
  créditos de los modelos de imagen quedaban 43 vistas por generar. El
  director eligió derivarlas de la vista base con
  `tools/art/progenitores_derivar_vistas.py` (escalado horizontal, espejo y
  ajuste de luminancia, preservando el fondo blanco) en lugar de entregar la
  fase incompleta. Resultado: 15 bases con modelo + 17 direccionales con modelo
  + 43 derivadas = 75 SVG. Las vistas derivadas son una aproximación de
  menor calidad artística; la aprobación visual final sigue siendo del
  director. Si en el futuro hay créditos, pueden regenerarse con el mismo
  pipeline y sobrescribir las derivadas sin cambiar rutas ni lógica.
- Registro completo de origen, modelo y parámetros por imagen:
  `art/shared/progenitores/ORIGEN.md`.

### Validación
- Godot 4.7.2 en modo headless carga un SVG de prueba con `<image>` incrustado
  a 256 × 280, con transparencia correcta en las esquinas (23-nov).
- Pruebas nuevas: `tests/art/art_progenitores_test.gd` comprueba las 75 vistas,
  el tamaño, la transparencia, el `viewBox`, la incrustación y la ausencia de
  texto y del generador anterior.
- `python tools/verificar.py` y la importación con `--headless --import` se
  ejecutan antes de proponer el PR.

## Consecuencias
- El `.pck` crece: cada vista lleva un PNG incrustado en lugar de un SVG de
  unas pocas líneas. El tamaño exacto se mide al terminar la fase.
- La coherencia entre las cinco vistas de un mismo progenitor depende del
  modelo; se usa la vista base como referencia siempre que el modelo lo
  permite. La aprobación visual final corresponde al director.
- Esta decisión es específica de los progenitores (P-58). No deroga la regla
  general de `docs/36_pipeline_graficos.md` para el resto del arte de juego.

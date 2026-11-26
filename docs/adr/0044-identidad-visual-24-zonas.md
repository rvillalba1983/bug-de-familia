# ADR 0044: identidad visual de las 24 zonas (26-nov)

Estado: decisiones del director del 26-nov, implementadas en la rama
`fase/arte-identidad-24-zonas` y todavía **sin fusionar**. Pendiente de
validación manual en partida y de la verificación del CI.

## Contexto

El mapa de 24 zonas y la interacción de sus habitantes ya estaban validados en
partida. Faltaba cerrar el inventario visual que dejó abierto el P-56:

- 8 zonas tenían 4 fachadas SVG propias cada una (32 en total), aprobadas en
  partida el 18-nov.
- `despliegue_cero` usaba las 4 fachadas genéricas del P-53 de forma
  provisional.
- Las otras 15 zonas no tenían fachadas declaradas en sus corredores.
- Solo `despliegue_cero` tenía suelo texturizado; el resto usaba un color plano.

El director aprobó el plan presentado el 26-nov, **incluida la opción L3-B** y
la petición explícita de que `despliegue_cero` tenga **fachadas propias**. El
coste aprobado fue de 0 créditos: se reutilizan generadores deterministas
locales, sin modelos de imagen ni servicios externos.

## Decisión

### 1. Fachadas propias para las 24 zonas

`tools/gen_fachadas_zona.py` pasa de 32 a **96 SVG** (24 zonas × 4 variantes).
Las 32 fachadas ya aprobadas se conservan byte a byte; las 64 restantes cubren
las 15 zonas que no tenían fachadas y `despliegue_cero`. Cada zona nueva usa
una paleta y un emblema acordes a su lore, dibujados con formas y trazos, sin
`<text>` ni filtros.

`ZoneBase.CORRIDOR_FACADE_ART_BY_ZONE` declara las 24 series. Las 4 fachadas
genéricas siguen en `CORRIDOR_FACADE_ART_DEFAULT` solo como salvaguarda de una
zona futura no registrada; ya no son el arte de ninguna zona del mapa.

### 2. Suelo con bioma y tinte

`ZoneBase.FLOOR_TEXTURES` reúne 8 texturas repetibles: las 3 ya existentes
(`bosque`, `ciudad`, `barro`) y 5 nuevas horneadas en local (`taller`,
`mercado`, `archivo`, `colmena`, `piedra`). `FLOOR_ART_BY_ZONE` asigna a cada
una de las 24 zonas un bioma y un tinte. El tinte modula solo el dibujo: no
cambia colisiones, navegación, detección ni alcances.

`despliegue_cero` queda registrada en el catálogo para que las 24 zonas tengan
identidad declarada, pero su escena sigue pintando el suelo con
`DespliegueCeroGround.paint()`: no se sustituye su arte actual.

### 3. Corredores y carteles en datos

`tools/gen_fachadas_zonas_json.py` añade `facades` a **42 corredores** de 15
zonas y `sign` a **47 corredores** de 16 zonas (las 15 nuevas y
`despliegue_cero`). No mueve ni borra los rect existentes: delimita la boca con
los mismos dos rect usados por las 8 zonas del P-56. La señal se calcula con
una réplica de `posmod(hash(destino), 10) + 1`, de modo que declararla no
cambia la cartelería ya vista en partida. El generador es idempotente: una
segunda ejecución no escribe archivos.

### 4. Origen y herramientas

- Fachadas: dibujo procedural propio generado por `tools/gen_fachadas_zona.py`
  (Python estándar, salida UTF-8 y LF). Sin material de terceros.
- Suelos: `tools/art/ground_gen.py` con Playwright y Chromium locales, semillas
  fijas de los filtros (8, 3 y 5), salida PNG de 512 × 512. Los 3 PNG antiguos
  no se regeneraron.
- Datos: `tools/gen_fachadas_zonas_json.py` (Python estándar, UTF-8 y LF).
- Ningún recurso se subió a un servicio externo. Ninguna herramienta de
  generación se necesita durante la partida.

## Consecuencias y limitaciones

- Hay que ejecutar `godot --headless --import` tras incorporar los SVG y PNG;
  los archivos `.import` generados por el motor forman parte del cambio.
- El fallback genérico se mantiene por robustez, no como arte previsto: si una
  zona nueva no está registrada, `ZoneBase` avisa con `push_warning`.
- La validación visual en partida de las 24 zonas sigue pendiente: el director
  debe revisar suelos, tintes, fachadas y carteles en el juego real.
- No se ha ejecutado la suite completa `res://tests` ni una medición de
  rendimiento; solo el paquete pequeño `tests/zones`, según la regla del
  director de paquetes de menos de 5 minutos.
- Los avisos de formato que aparecen en `zone_base.gd` y
  `gen_fachadas_zona.py` son preexistentes; este cambio no añade ninguno.

## Verificación ejecutada (26-nov)

- `tests/zones`: **83/83** (`reports/report_51/results.xml`, 11 suites), 0
  fallos, 0 errores y 0 omitidas. Incluye los 4 casos nuevos de
  `zone_visual_identity_test.gd`.
- `tools/validar_informes.py --grupo zonas --minimo 83 --argumentos-gdunit
  "-a res://tests/zones"`: informe JUnit fiable.
- `python tools/verificar.py`: OK (105 comprobaciones, 313 literales `res://`,
  900 conversaciones, 68 pruebas de herramientas).
- `python tools/formatear.py --comprobar`: 0 errores, 78 avisos preexistentes.

No ejecutadas: capturas con ventana, suite completa y medición en gráfica real.

## Referencias

- `docs/02_DECISIONES.md`, sección «Identidad visual de las 24 zonas (26-nov)».
- `docs/01_CONFLICTOS_Y_PENDIENTES.md`, P-53, P-56 y P-62.
- `docs/36_pipeline_graficos.md` (origen y herramienta de los recursos).
- `docs/34_zonas_y_contenido.md` (mapa de biomas por zona).
- `docs/adr/0034-corredores-fisicos.md` apartado 7 y
  `docs/adr/0035-arte-personajes-y-delimitadores.md` (origen del sistema
  `facades` y de las 32 fachadas aprobadas).

# ADR 0034: corredores físicos con muros y señal de entrada

Estado: aceptado por el director el 16-nov-2026. Implementación en la fase «Contenido y diseño de
zonas». Ampliado el 16-nov con el fondo de las bocas sur y este (apartado 6).

## Contexto

Hoy los corredores entre zonas (`ZoneDefinition.geometry.corridors`) son solo un rectángulo
de transición en el borde del mapa más un cartel de UI flotante (`ZoneBase._build_corridors`
y `_build_zone_sign`, `scenes/zones/zone_base.gd:160-213`). No hay camino delimitado: el
jugador camina por suelo abierto hasta el borde y la «señal» es un `PanelContainer` de texto.
El director quiere que cada corredor sea un **pasillo físico delimitado por muros, con
identidad visual propia en cada salida y que oculte lo que hay más allá de las curvas**
(oclusión por muros/cámara), conectando zonas explorables.

El diseño lo elaboró el agente `arquitecto` (solo lectura) sobre el código actual. La
decisión es compatible con el esquema multi-zona del ADR 0027: la geometría ya se declara en
el JSON de zona (`shape_blocks`, `corridors`), así que los muros de corredor también viven en
datos y se montan en la escena genérica.

## Decisión

### 1. Modelo de datos: campos opcionales por corredor

Se amplía el diccionario de cada corredor en `data/zones/<id>.json` con dos claves
opcionales (no rompen las 24 zonas existentes, que no las declaran):

- `"walls"`: `Array` de rectángulos `[x, y, w, h]` que forman las paredes del pasillo.
  No deben invadir el `rect` del corredor (margen del radio del jugador) y sí dejar el
  propio `rect` como hueco caminable hasta el borde.
- `"sign"`: `String` con el nombre del SVG de señal (`señal_01`..`señal_10`) para dar
  identidad propia a esa salida. **Si falta, el fallback está implementado**:
  `ZoneBase._corridor_sign_id()` elige `señal_%02d` con `posmod(hash(to_zone), 10) + 1`
  (el `posmod` evita índices negativos). Así ninguna boca se queda sin cartel, incluidas las
  de `despliegue_cero`, que no declara `sign` en ningún corredor: no hay que tocar JSON.

`ZoneDefinition.corridors()` (`core/data/zone_definition.gd:138`) devuelve estas claves.

### 2. Montaje: muros reales, no solo colisión

En `ZoneBase._build_corridors()` se construye cada muro del pasillo con `_add_wall(rect,
altura, Wall.Kind.SOLID)` (altura de pasillo ~200 u, muy superior a las 48 u actuales), en
lugar del `_add_blocker` que solo ponía colisión invisible. Así los muros entran en `walls`
(oclusión gratis) y en `actors` (y-sort ya activo).

### 3. Navegación: sin tocar NavGrid

`ZoneBase._all_blockers()` (`zone_base.gd:495`) ya suma `shape_blocks` + `wall_rects()`;
se añaden los `corridor.walls` para que `NavGrid` (`core/nav_grid.gd:12`) los respete.
Riesgo: un rect mal puesto cierra el paso al borde; se valida con `tools/verificar.py`.

### 4. Señal de entrada: SVG del director

`_build_zone_sign()` monta la señal de la boca: un `Sprite2D` con
`res://art/shared/fuentes/<sign>.svg` en la boca del pasillo, como hijo de `actors` para
el y-sort y con `z_index = 1` para no quedar detrás de los muros (apartado 6), y **delante**
el nombre de la zona destino (`zone.display_name`, o el id si no hay definición) como
`Label` con `UiStyle.FONT_LOUD` 26 px, `Palette.HUESO` con contorno `Palette.INK` y fondo de
tinta semitransparente (alfa 0.35: el cartel se sigue viendo detrás), hijo de `actors` y con
`z_index` 2 (cartel detrás, nombre delante). Ese nombre **sustituye al panel de texto viejo**
(«Bienvenido a…», «Seguir el camino», «a N m»), que se retira (P-55). Toda boca lleva cartel
y nombre, también las que no declaran `sign` (despliegue_cero): se aplica el fallback del
apartado 1.
Los 10 SVG los genera el agente `arte` con el brief del director (viewBox `0 0 512 320`,
contorno `#1B0E2A`). Tras añadirlos hay que correr `--import`.

### 5. Oclusión de «más allá de la curva»

Los muros físicos altos ocultan lo que queda al norte de su base en la proyección (frentes
hacia el norte, `entities/world/wall.gd`). Para salidas sur/este los muros laterales no pueden
ocultar el tramo siguiente; esa limitación se resolvió el 16-nov con el fondo de la boca
(apartado 6).

### 6. Fondo de las bocas sur y este (decisión del director, 16-nov-2026)

Problema: en las salidas `south` y `east` el pasillo se veía cortado en el borde del mapa,
sin nada que cerrara la vista. El director descartó tocar la cámara por riesgo y eligió un
panel de fondo en la boca; se implementó como muro, sin `zigzag`, porque un solo panel basta.

- **Datos: sin claves nuevas.** El fondo se deriva del propio corredor: se construye cuando
  `edge` es `south` o `east` **y** el corredor ya declara `walls`. Así el opt-in sigue siendo
  `walls` (las 16 zonas que no lo declaran quedan idénticas) y no hay un flag que se pueda
  olvidar o contradecir. Un rect por corredor en el JSON habría duplicado 22 entradas.
- **Montaje:** `ZoneBase._build_corridor_backdrop()` añade un `Wall` de tipo
  `Wall.Kind.BACKDROP` (nuevo) con `front_height` = dimensión Y del rect del corredor y el
  frente arrancando en el borde del mapa: el frente cae justo sobre el rect del corredor en
  pantalla, así que cierra la vista y no invade el hueco caminable.
- **El paso sigue abierto:** `BACKDROP` tiene `collision_layer` 0 (no colisiona) y no entra en
  `_all_blockers()`, de modo que NavGrid y la transición del corredor no cambian. Como la
  boca sur usa una lengüeta de 16 u (`BACKDROP_LIP`), el tejado del muro —que se dibuja hacia
  el norte— no llega a los pies de quien aparece en el pasillo.
- **Sin desvanecido:** `Wall.always_opaque` (falso por defecto) impide atenuar el fondo, que
  es justo lo que descubriría el corte del mapa. Los muros normales siguen atenuándose.
- **Señal:** el SVG de la boca pasa a `z_index = 1` para dibujarse sobre los muros y el fondo;
  antes quedaba tapada en las salidas norte y este. Además, `corridor_sign_position()` coloca
  señal y nombre `SIGN_LIFT` (150 u) hacia dentro de la sala, y en las salidas **norte** ese
  desplazamiento va hacia el sur (+Y): el centro del corredor está en el borde superior del
  mapa y con el desplazamiento hacia el norte ambos caían fuera del límite de la cámara
  (`y = -118` la señal, `y = -58` el texto) y no se veían. El resto de direcciones conserva su
  posición (el nombre va `SIGN_NAME_DROP` = 96 u por debajo del ancla de la señal).
- **Nombre en vez del cartel viejo (P-55, 17-nov):** se retira el `PanelContainer` de texto de
  las bocas; el nombre de la zona destino se dibuja **delante del cartel** con la tipografía y
  la paleta del arte (`UiStyle.FONT_LOUD`, `Palette.HUESO`/`INK`, fondo de tinta al 35 % para
  que el cartel se vea detrás). Con el fallback del apartado 1, todas las bocas llevan cartel y
  nombre, también las de `despliegue_cero`.
- Pruebas: `tests/zones/generic_zone_test.gd` (fondo, paso abierto, opacidad y opt-in) y
  `tests/entities/wall_test.gd` (`BACKDROP` sin colisión y sin atenuación).

## 7. Delimitación con edificios/fachadas (P-53, 17-nov-2026)

Decisión del director: los pasillos se delimitan con **edificios con fachada**, no con muros.
Las fachadas son la **forma normal** y `walls` queda como **legacy** soportado. No se rehacen
las zonas que ya usan muros; las nuevas y las mejoras usan fachadas.

- **Datos:** clave opcional nueva por corredor, `"facades"`: `Array` de rectángulos
  `[x, y, w, h]` con la **misma interpretación que `walls`** (delimitan el pasillo sin invadir
  el `rect` caminable). Un corredor declara `walls`, `facades` o ninguno, **nunca los dos**:
  `ZoneDefinition.corridors()` avisa con el archivo y el destino y se queda con `facades`
  (la forma normal), para no montar dos veces el mismo delimitador. La misma regla la aplica
  `tools/validar_datos.py` antes de arrancar el motor.
- **Montaje:** cada rect se monta como `CorridorFacade` (`entities/world/corridor_facade.gd`),
  un `StaticBody2D` **nuevo**, hermano de `Wall`, y no como `BuildingFacade`. Se descartó
  reutilizar `BuildingFacade` porque ésta es un edificio transitable: no tiene colisión, se
  vuelve translúcida al acercarse el jugador (`_process` con distancia al interior) y necesita
  `player`, `interior` y puerta. Parametrizarla habría metido un modo muro dentro de la
  fachada de interior y puesto en riesgo las dos fachadas de `despliegue_cero`. El nodo nuevo
  hace lo mismo que un muro (colisión, oclusión y y-sort) sin código condicional.
- **Aspecto:** frente hacia el norte de `CORRIDOR_WALL_HEIGHT` (200 u), como los muros, con la
  textura SVG estirada al frente y un tejado del color de los muros para que el pasillo se lea
  como una pieza. **Provisional:** las fachadas genéricas de corredor todavía no están
  dibujadas (las hará el agente `arte`); mientras tanto se alternan `fachada_centralita.svg` y
  `fachada_deposito.svg` desde el catálogo `ZoneBase.CORRIDOR_FACADE_ART`, único punto donde
  cambiar la lista de modelos.
- **Opacidad:** la fachada de corredor **nunca se atenúa**. No se registra en `Sandbox.walls`
  (la lista que `_update_wall_occlusion` recorre) ni tiene `_process`, así que no hay
  desvanecido por proximidad: cumple la función de muro de ocultar lo que hay más allá.
- **Navegación:** los rects de `facades` entran en `_all_blockers()` igual que los de `walls`,
  así que `NavGrid` los respeta sin tocar `core/nav_grid.gd`.
- **Fondo de las bocas sur y este (apartado 6):** ahora se deriva de declarar **algún**
  delimitador (`walls` o `facades`); sin claves nuevas y con el mismo aspecto.
- **Señal y nombre de la boca:** sin cambios (apartados 1 y 4).
- **Pruebas:** `tests/zones/corridor_facades_test.gd` (montaje con colisión, NavGrid, opacidad,
  fondo con fachadas, conflicto `walls`+`facades` y corredores legacy intactos),
  `tests/entities/corridor_facade_test.gd` (geometría, colisión y ausencia de desvanecido) y
  `tools/tests/test_herramientas.py` (validación de los rects y del conflicto).
- **Pendiente:** las fachadas SVG genéricas de corredor y aplicar el modelo a
  `data/zones/*.json` (lo hace otro agente con este modelo). Los placeholders actuales estiran
  un edificio entero al frente del pasillo, así que el aspecto definitivo depende del arte.

## Consecuencias

- Positivas: las zonas sin `walls` en sus corredores no cambian (cambio 100% opt-in); las 8
  zonas de la fase ganan pasillos con identidad, la señal SVG sustituye el cartel genérico y
  las bocas sur/este quedan cerradas visualmente sin tocar la cámara.
- Positivas (P-53): el modelo es aditivo; ningún JSON cambia hasta que se declaren `facades`, y
  los corredores con `walls` siguen montando exactamente los mismos muros y fondos.
- Negativas / limitaciones: el texto de los SVG no se renderiza en Godot (se pierde al
  importar), por eso el nombre de la zona se dibuja como `Label` encima. La señal de las
  salidas este y oeste sobresale del borde del mapa por diseño (parte queda recortada por la
  cámara). Mientras el arte no dibuje las fachadas genéricas, los corredores con `facades` se
  ven con las dos fachadas de edificio existentes, que no están dibujadas para la proporción
  del frente de un pasillo.
- Herramientas: `tools/verificar.py` y `tests/zones/content_test.gd` (lista
  `ZONAS_CON_CONTENIDO`) deben seguir en verde zona por zona.

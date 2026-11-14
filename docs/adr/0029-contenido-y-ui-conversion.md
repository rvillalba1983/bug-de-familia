# ADR 0029: contenido conversacional, zonas esqueleto y centro de la conversión

Estado: **en revisión** (14-nov-2026). Rama `fase/contenido-y-ui-conversion`. Las cifras de
pruebas y el `.exe` se anotan en `docs/03_ESTADO.md` cuando se ejecuten.

## Contexto

El director dejó tres frentes de trabajo para esta fase (14-nov), todos tomados de
`docs/03_ESTADO.md`, sección «Pendiente de respuesta del usuario»:

1. **UI de conversión**: «en las pantallas de preguntas de conversión, centrar más la pregunta
   y las frases de las IAs en la pantalla».
2. **Contenido conversacional**: que todas las especies tengan textos y que las zonas tengan
   contenido, no solo población.
3. **Higiene técnica y CI**: actualizar las GitHub Actions y corregir afirmaciones caducadas de
   `docs/03_ESTADO.md`.

La auditoría previa encontró que el punto 2 estaba **mucho más avanzado de lo que decía la
documentación**: `docs/03_ESTADO.md` afirmaba que «solo los NPCs especiales del caso son
conversables; las 4 especies nuevas no tienen textos», pero los seis tipos de especie ya
existían en `data/world/species.json` (13 frases y 5 hechos de lore por especie) y `LiveWorld`
abre `LiveDialogue` con cualquier habitante. Lo que faltaba de verdad era **variedad**, no
cobertura.

## Decisión

### 1. Centro de la pantalla de conversión

- El **título de la pregunta** (el texto de la pregunta y los títulos de los pasos) se centra en
  horizontal dentro del panel: `heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER`.
- El **cuerpo del mensaje** (`show_message`: resultado, descripciones de pieza) también se centra.
- La **cuenta atrás** se compensa con un espacio vacío de su mismo ancho al otro lado del título
  (`ConversionScreen.TIMER_WIDTH`), de modo que el título queda centrado en el panel y no
  desplazado a la izquierda por el número.
- Las **frases de las IAs** (el comentario `add_remark` y la burla `show_taunt`) ya estaban
  centradas; ahora lo cubren pruebas, para que no vuelvan a perderse.
- La posición vertical del bloque (frase arriba, panel abajo) **no se toca**: la decisión de
  subir el panel y bajar la frase ya se tomó en `adr/0025`/P-38 y sus valores son provisionales.
  Cambiarlos sin verla en partida sería otra Iteración a ciegas.

### 2. Contenido conversacional de las especies

En `data/world/species.json`, para las seis especies (`jubilado`, `mohocrata`, `plegado`, `eco`,
`grux`, `manada`):

- Se añade la clave **`sad`**, que el juego ya pedía (`live_world.gd`, duelo) y que hasta ahora
  caía al texto de `angry` por el respaldo de `_random_line`.
- Cada situación (`greet`, `opener`, `nothing`, `angry`, `praised`, `weird`, `sad`) tiene **al
  menos 4 frases**; las ya escritas se conservan y se añaden nuevas.
- Se añade **`role_lines`**: un objeto con una entrada por cada valor de `roles`, con 2 o 3
  frases del oficio (el archivista, el tasador, el repartidor…). `LiveDialogue` usa la línea del
  oficio del habitante como saludo (`_greeting`), y vuelve al saludo normal si la especie no
  tiene línea para ese oficio.
- `lore` pasa de 5 a **8 hechos** por especie, con el campo `true`/`false` ya en uso: los `true`
  salen de `docs/50_lore.md` y los `false` son leyendas falsas de cada especie.

El contenido es **provisional**: lo escribe el equipo con la voz de `docs/16_razas_facciones.md`
y `docs/50_lore.md` y lo revisa el director.

### 3. Las ocho zonas esqueleto

`antecamara`, `camara`, `camino`, `canon`, `instalacion`, `sendero`, `ultima_ruta` y `valle`
tienen ya población desde la fase de infraestructura, pero estaban sin objetos, decorado ni
actores. Ahora cada una tiene:

- **Objetos**: dos cajas convertibles, una pierna y un brazo, con anclajes de posición propios.
- **Decorado**: 3 o 4 grupos de props reutilizando el arte ya existente en `art/shared/props/`.
- **Actores guiados**: dos, con ruta fija y especie de la zona, como los de `lonja` y
  `el_enchufe` (guardias pasivos, no habitantes del mundo vivo).

El reparto y los nombres siguen el mapa de diseño de cada zona (`art/mapas_zonas/README.md`):
la Antecámara son ruinas, archivo y pliegue; la Cámara de Resonancia es acústica; el Valle
tiene montañas, archivos, túneles y puestos; la Última Ruta, puestos y almacenes.

Las **13 zonas pobladas que siguen sin props, objetos ni actores** (`archivo`, `asamblea`,
`atajo`, `cementerio`, `colmena`, `cumbre`, `desguace`, `encrucijada`, `gran_cruce`,
`gran_mercado`, `paso`, `poligono`, `taller`) quedan fuera de esta fase: es el siguiente
lote de contenido.

### 4. Higiene del CI

Las dos GitHub Actions suben a las versiones mayores disponibles (noviembre de 2026): 
`actions/checkout@v7`, `actions/cache@v6` y `actions/upload-artifact@v7`. Los migrations a ESM
son internos de cada acción y no cambian las entradas que usa este repositorio.

## Consecuencias y limitaciones

- Las cifras de la tabla de zonas de `docs/34_zonas_y_contenido.md` quedan desactualizadas
  (decían «sin población real» para ocho zonas que ya la tienen) y se corrigen en este cambio.
- El reparto de posiciones, cantidades y rutas es **provisional** y solo se ha validado de forma
  automática (que caen dentro del suelo y que las rutas existen). Falta la **validación manual
  en partida**: que no estorben, que los actores no se solapen con los bloques y que el
  decorado se lea bien.
- Los textos nuevos son provisionales hasta que el director los critique; `docs/03_ESTADO.md`
  recoge que la fase anterior dejó doce textos de burla pendientes de crítica.
- La clave `role_lines` es opcional por diseño: una especie sin ella sigue funcionando con el
  saludo normal.
- `docs/03_ESTADO.md` afirmaba que las cuatro especies nuevas no tenían textos; la corrección
  queda documentada ahí para que no se repita el error.

## Referencias

- Pendientes del director (14-nov): `docs/03_ESTADO.md`, sección «Pendiente de respuesta del
  usuario», y `docs/01_CONFLICTOS_Y_PENDIENTES.md` (P-38).
- Voz de las especies: `docs/16_razas_facciones.md`; hechos del mundo: `docs/50_lore.md`.
- Zonas y contenido: `docs/34_zonas_y_contenido.md`; mapas de diseño: `art/mapas_zonas/README.md`.
- Ejecución de las zonas: `scenes/zones/zone_base.gd` y `core/data/zone_definition.gd`.

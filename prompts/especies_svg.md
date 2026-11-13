# Prompt para generar modelos SVG de las especies de "Bug de Familia"

Pega este prompt completo en otra IA generadora de SVG. El objetivo es producir los modelos SVG de las 6 especies jugables del juego, manteniendo el estilo visual existente del proyecto.

## Contexto del juego

"Bug de Familia" es un juego 2D de sigilo táctico e investigación para PC, con estética cartoon, contornos definidos, colores vivos y mezcla de orgánico y mecánico. Ciencia ficción gamberra, influencia de Gender Wars. Evitar lo serio, militar o superheroico. El jugador es un buscavidas espacial de cuatro brazos.

Las especies son los habitantes del planeta. Seis razas: cuatro alienígenas y dos nacidas en el planeta. Se mueven en grupos por zonas. Cada una tiene una personalidad, economía y cultura propia.

## Requisitos técnicos de los SVG

- Formato: SVG, ancho/alto `256x256`, `viewBox="0 0 512 512"`.
- Fondo transparente. Sombra elíptica en la base: `<ellipse cx="256" cy="470-474" rx="150-162" ry="26" fill="#1B0E2A" opacity="0.5"/>`.
- Paleta de contorno: negro azulado `#1B0E2A` para todos los trazos.
- Grosor de trazo: 6-8 para contornos principales, 3-5 para detalles, 2-3 para texturas.
- `stroke-linejoin="round"` y `stroke-linecap="round"` en todos los trazos.
- Gradientes radiales/lineales para dar volumen (luz desde arriba-izquierda: `cx="0.3" cy="0.2"`).
- Texturas superficiales: puntos, rayas o trazos cortos con opacidad baja (0.3-0.4) en el color claro de la especie.
- Ojos/elementos brillantes: círculos con color de acento y halo translúcido.
- Estilo general: personaje de cuerpo completo visto de frente (vista sur), de pie, con pies en la parte baja del canvas (y≈400-470).

## Vistas necesarias

Cada especie necesita **3 vistas planas** (para las especies sin esqueleto animado):
- `{especie}.svg` — vista sur (frente)
- `{especie}_e.svg` — vista este (perfil derecho)
- `{especie}_n.svg` — vista norte (espalda)

Para las especies con esqueleto (jubilado_hierro y mohocrata) además se necesitan **piezas de rig** en carpetas `rig/{especie}/`, `rig/{especie}_e/`, `rig/{especie}_n/`:
- `torso.svg`, `cabeza.svg`, `brazo_i.svg`, `brazo_d.svg`, y `pierna_i.svg`/`pierna_d.svg` si tienen piernas.

Las especies con esqueleto son: **jubilado_hierro** (tiene piernas) y **mohocrata** (sin piernas, flota). El resto (plegado, eco, grux, manada) solo vistas planas.

## Definición de las 6 especies

### 1. Jubilados de Hierro (`jubilado`, art `jubilado_hierro`)

- **Origen:** del planeta (robots de servicio antiguos).
- **Cómo son:** gruñones, lentos y nostálgicos. Juegan a la petanca con minas. Robots de servicio antiguos.
- **Color cuerpo:** `#a0a8b8` (gris azulado). Color mapa: `#a0c8ff`.
- **Material:** nanoacero.
- **Rival:** mohocrata.
- **Roles:** petanquista, vigilante, archivero, mecánico.
- **Aspecto:** robot viejo con torso redondeado de metal, cabeza esférica con un ojo/visor brillante naranja `#FF6A00` o cian `#00E5FF`, dos brazos mecánicos con manos pinza, dos piernas cortas y gruesas, pies redondos. Lleva accesorios: una mina de petanca (esfera morada `#3A1A5C` con puntos amarillos), un sombrero o casco abollado, cables sueltos, soldadura. Actitud encorvada, cansada. Superficie con remaches y costuras soldadas.
- **Rasgos:** se apagan a las 21:00, odian las escaleras, nunca perdonan que les llamen "viejos". Recuerdan el mundo de antes y lo cuentan mal a propósito. Algunos conocieron a los progenitores.
- **Referencia existente:** ya hay SVGs reales en `art/shared/jubilado_hierro*.svg` y rig. Mantener ese estilo.

### 2. Mohócratas (`mohocrata`, art `mohocrata`)

- **Origen:** alien, después del colapso.
- **Cómo son:** colonias de hongos con sombreros de chatarra. Carroñeros que reciclan robots muertos.
- **Color cuerpo:** `#8fbf60` (verde hongo). Color mapa: `#a0f060`.
- **Material:** biocerámica.
- **Rival:** jubilado.
- **Roles:** votante, recolector, escrutador, reciclador.
- **Aspecto:** colonia fúngica antropomórfica: cuerpo bajo y ancho (sin piernas, flota/desliza), sombrero de hongo grande hecho de piezas de chatarra y metal oxidado, textura de esporas y agujeros, brazos delgados y nodosos, cara con ojos saltones y boca pequeña. Superficie orgánica con manchas y protuberancias. Sin piernas (flota).
- **Rasgos:** democracia de esporas, votan todo incluso respirar, pacíficos hasta que votan guerra. Odian la luz. Sus votos se compran con fertilizante. Votan 3 veces antes de atacar.
- **Referencia existente:** ya hay SVGs reales en `art/shared/mohocrata*.svg` y rig. Mantener ese estilo.

### 3. Plegados (`plegado`, art `plegado`)

- **Origen:** alien, antes del colapso.
- **Cómo son:** seres planos que viven doblados como papiroflexia. Se esconden en grietas y se despliegan para atacar.
- **Color cuerpo:** `#c8b8e8` (lila pálido). Color mapa: `#d8c8ff`.
- **Material:** fibra fotónica.
- **Rival:** grux.
- **Roles:** archivista, plegador, clasificador, desplegador.
- **Aspecto:** ser plano y anguloso, como una figura de origami/papiroflexia. Cuerpo hecho de planos y dobleces geométricos, aristas afiladas, esquinas marcadas. Forma humanoide pero estilizada y facetada. Superficie con líneas de pliegue (trazos finos). Ojos como pequeñas gemas o puntos brillantes. Colores lila/violeta con reflejos nacarados. Debe parecer hecho de papel/fibra plegada, no orgánico.
- **Rasgos:** vinieron a "archivar" el planeta aplanándolo. Nadie sabe si era rescate o saqueo. Se pliegan 7 veces; mojados no pueden desplegarse. Su líder es La Doblez Mayor. Todo debe tener ficha.

### 4. Ecos de Vurm (`eco`, art `eco`)

- **Origen:** alien, antes del colapso.
- **Cómo son:** criaturas de sonido que solo existen mientras haya ruido. Se alimentan de conversaciones.
- **Color cuerpo:** `#8fdbd8` (turquesa claro). Color mapa: `#8fffe8`.
- **Material:** cristal plasma.
- **Rival:** grux.
- **Roles:** resonador, repetidor, oyente, amplificador.
- **Aspecto:** ser translúcido y etéreo, como una onda de sonido cristalizada. Cuerpo semi-transparente con anillos/ondas concéntricas, forma humanoide pero fluida y vibrante. Superficie con patrones de ondas y destellos. Color turquesa/cian con brillo interior. Ojos como puntos de luz. Debe parecer hecho de sonido solidificado, con halo luminoso.
- **Rasgos:** atraídos por las radios humanas. Se sospecha que el silencio tras el apocalipsis fue culpa de su hambre. Repiten la última palabra que oyen; se debilitan en zonas de silencio; no soportan los susurros. Solo existen mientras haya ruido.

### 5. Tasadores Grux (`grux`, art `grux`)

- **Origen:** alien, después del colapso.
- **Cómo son:** barriobajeros de cuatro brazos con un estómago bolsillo. Tragan lo que roban, incluidas tus piezas.
- **Color cuerpo:** `#d8985a` (naranja/cobre). Color mapa: `#ffb060`.
- **Material:** restos.
- **Rival:** plegado.
- **Roles:** tasador, cobrador, tragaperras, prestamista.
- **Aspecto:** criatura robusta y agachada, de cuatro brazos (dos principales grandes, dos secundarios pequeños). Boca grande con dientes afilados, estómago prominente que actúa como bolsillo/caja fuerte. Piel áspera, color cobre/naranja, con cicatrices y manchas. Ropa harapienta o armadura improvisada de chatarra. Actitud codiciosa, gesto de tasación (mordiendo objetos). Dientes visibles.
- **Rasgos:** mafia de prestamistas que cobra deudas que nadie recuerda haber pedido. Pagan en dientes; vomitan lo robado si huelen azufre; tasan todo de un mordisco. Llegaron después del colapso a cobrar.

### 6. Manada Recalculada (`manada`, art `manada`)

- **Origen:** del planeta (animales mutantes).
- **Cómo son:** animales mutantes con navegadores implantados que siguen rutas de reparto de antes del fin.
- **Color cuerpo:** `#a8c860` (verde lima). Color mapa: `#c0ff60`.
- **Material:** gel memoria.
- **Rival:** grux.
- **Roles:** repartidor, recorredor, cargador, rastreador.
- **Aspecto:** animal cuadrúpedo mutante (mezcla de perro/liebre/ciervo) con un navegador/dispositivo GPS implantado en la cabeza (pantalla brillante, antena). Cuerpo esbelto y aerodinámico, patas largas, cola corta. Piel con textura de gel translúcido/verde lima. Los ojos tienen aspecto de interfaz (puntos de luz). Lleva una caja/paquete vacío atado al cuerpo. Actitud de movimiento constante, orientada hacia adelante.
- **Rasgos:** mascotas de una empresa de envíos. Siguen entregando paquetes vacíos a direcciones que ya no existen. Solo giran a la derecha; obedecen ladridos en binario; se pierden si cambias una señal.

## Estilo visual de referencia

Observa los SVGs existentes de jubilado_hierro y mohocrata en `art/shared/`. Características clave:
- Contorno negro azulado `#1B0E2A` con grosor 7-8.
- Sombra elíptica en la base.
- Gradientes para volumen (radial con luz arriba-izquierda).
- Texturas de superficie con trazos cortos y opacidad baja.
- Ojos/elementos brillantes con halo.
- Accesorios y detalles que reflejan la cultura de cada especie.
- Personaje de cuerpo completo, de pie, pies en la base del canvas.

## Entregables esperados

Para cada especie sin esqueleto (plegado, eco, grux, manada): 3 archivos SVG (sur, este, norte).
Para las especies con esqueleto (jubilado_hierro, mohocrata): los 3 archivos planos ya existen como referencia; si se regeneran, mantener las piezas de rig (torso, cabeza, brazos, piernas) con las mismas proporciones y puntos de articulación.

Nombres de archivo exactos:
- `art/shared/{art}.svg`, `art/shared/{art}_e.svg`, `art/shared/{art}_n.svg`
donde `{art}` es: jubilado_hierro, mohocrata, plegado, eco, grux, manada.

## Notas importantes

- Los SVGs actuales de plegado, eco, grux y manada son placeholders idénticos (genéricos). Hay que reemplazarlos por modelos reales y distintivos de cada especie.
- Mantener la legibilidad a tamaño pequeño (los personajes se dibujan a ~77px de alto en el juego).
- No incluir texto ni etiquetas en los SVG.
- Usar IDs de gradientes únicos por archivo para evitar colisiones.
- El color principal del cuerpo debe coincidir con el `color` de species.json para que el juego los identifique visualmente.

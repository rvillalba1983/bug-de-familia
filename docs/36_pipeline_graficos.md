# Producción gráfica

Decisión vigente (9-nov): todo el arte se hace con Godot y SVG, sin generadores de imágenes. La hoja de diseño del protagonista sigue siendo la referencia.

## Paleta «Cuñado Radiactivo»
Código en `entities/art/palette.gd`.

| Nombre | Color | Uso |
|---|---|---|
| Moratón | `#1B0E2A` | Contornos |
| Berenjena Rencorosa | `#6A2BA8` | Sombras y lujo cutre |
| Cian Reseteo | `#00E5FF` | Pantallas y ojos robot |
| Azul Mono de Currela | `#0A7FC2` | Metal pintado |
| Rosa Multa | `#FF1F8F` | Alarmas y sombreros |
| Naranja Butano | `#FF6A00` | Calor y óxido vivo |
| Amarillo Obra | `#FFD400` | Avisos y latón |
| Ácido de Batería | `#C6FF00` | Esporas y energía |
| Verde Moho Electoral | `#2FBF71` | Mohócratas |
| Óxido de Abuelo | `#A8482A` | Chapa vieja |
| Hierro de Jubilado | `#8894B5` | Robots |
| Hueso Sucio | `#F6E7C8` | Dientes y papeles |

## Qué se hace con cada herramienta
| Godot | SVG |
|---|---|
| Suelo, grietas, cráteres y charcos | Enemigos, progenitores y objetos |
| Edificios, paredes y árboles | Fachadas e iconos |
| Noche, luces, partículas y shaders | Formas base para animar por piezas |
| Cono de visión, colas y animación por huesos | |
| Protagonista, con polígonos por piezas | |

## Reglas técnicas del SVG
- Para importar directamente en Godot: formas, trazos y degradados. Sin filtros ni `<text>`.
- Lo que necesite filtros (pincel, grano, brillo) se hornea antes a PNG con Chromium. Así se hacen las texturas del suelo (`tools/art/ground_gen.py`).
- Tamaño del SVG acorde al de pantalla, para que no se vea borroso.

## Perspectiva y profundidad
- Cámara de juego: vista alta inclinada, de ángulo fijo.
- La perspectiva marcada solo es correcta desde un punto fijo: se reserva para escenas fijas. Referencia: `tools/art/city_scene_gen.py`, que proyecta edificios 3D y añade sombras, neblina lejana y primer plano desenfocado.
- En el mapa con scroll: convergencia muy suave o ninguna, orden Y y capas a distinta velocidad.

## Generadores y recursos
| Archivo | Contenido |
|---|---|
| `tools/art/beta_assets_gen.py` | Los 10 elementos de la beta, en `art/beta/fuentes/` |
| `tools/art/protagonist_gen.py` | Protagonista por piezas, en `data/art/protagonista.json` |
| `tools/art/ground_gen.py` | Texturas repetibles del suelo |
| `tools/art/city_scene_gen.py` | Escena de ejemplo con perspectiva |
| `tools/art/props_gen.py` | Objetos de la zona beta, en `art/beta/props/` |

Elementos de la beta: mina de petanca, bobina, cartel de tierra de nadie, dron viejo, urna de esporas, Mohócrata votante, Jubilado de Hierro, Don Ramón, centralita del Contestador y depósito mohócrata. El cartel y la urna aún no están integrados. Vistas extra de los NPC en `tools/art/npc_views_gen.py` y fachadas en `tools/art/facades_gen.py`.

## Estilo
Cartoon grotesco de acabado pintado: anatomías extrañas, formas asimétricas, ojos, bocas y extremidades exagerados, colores saturados y poco naturales, mezcla de atractivo y desagradable, y humor visual. Estética adulta. Cada especie con identidad propia.

## Cámara
Vista alta inclinada, de ángulo fijo. Se ven la cara y el cuerpo escorzado. Cada pieza modular necesita sus propias orientaciones, y los escenarios muestran frentes de paredes y objetos. Sprites en 8 direcciones, reflejando las que se pueda para reducir las imágenes.

## Reparto de trabajo
| Paso | Quién |
|---|---|
| Brief y prompt de cada recurso | Claude |
| Crear el arte en SVG o Godot | Claude |
| Quitar fondo, recortar, igualar escala y paleta | Claude |
| Anclajes, pivotes, capas, atlas | Claude |
| Rigging, animación e integración en Godot | Claude |
| Aprobar el resultado en el juego | Usuario |

## Herramientas
Godot 2D (Sprite2D, Skeleton2D, Bone2D, AnimationPlayer, AnimationTree, TileMapLayer, GPUParticles2D, shaders, Light2D), Krita para retoques puntuales y Git para versiones. SVG y técnicas procedurales siguen disponibles para iconos, formas simples y efectos, pero no como arte principal de personajes, salvo la prueba de estilo de la beta (ver `adr/0008-estilo-visual-beta.md`).

## Protagonista y especies
- Piezas independientes con esqueleto: animaciones iniciales de reposo, caminar, atacar, recibir daño, perder una extremidad, sustituir pieza, interactuar y reaccionar.
- Cola quieta por rendimiento (9-nov), con color para identificar a cada IA.
- Especies por familias anatómicas (humanoides, insectoides, gelatinosos, tentaculares, cuadrúpedos, amorfos), sin un esqueleto universal.
- Separar especie, modelo visual e individuo. Variantes por parámetros y componentes: tamaño, proporciones, color, ojos, bocas, extremidades, marcas y accesorios.

## Animación y efectos
Combinar animación esquelética, transformaciones, procedural (colas, tentáculos, vibraciones) y por fotogramas solo donde haga falta. Partículas y shaders para explosiones, humo, salpicaduras, energía, esporas, clima y anomalías.

## Profundidad e iluminación
Ordenación por coordenada Y, sombras simples, luces limitadas, CanvasModulate para día y noche, capas de primer plano y oclusión.

## Objetos, escenarios y organismos
Objetos con estados visuales (cerrado, abierto, activado, dañado, destruido, oculto, descubierto, recogido). TileMapLayer para terrenos repetitivos y escenas para edificios y estructuras, con piezas reutilizables. Bibliotecas de plantas, hongos y organismos.

## Rendimiento
Texturas razonables, atlas, partículas y luces limitadas, nodos justos y carga controlada de zonas. Las piezas de personajes van en `art/beta/atlas/piezas.png` (generada con `tools/art/piece_atlas_gen.gd`: hay que volver a ejecutarla si cambia un SVG de `art/beta/rig/`). Las formas de color estáticas o repetidas se juntan en mallas con `PolyBatch`.

## Herramienta interna
Fábrica de recursos: importar y preparar imágenes, configurar esqueletos y anclajes, validar dimensiones, transparencias, nombres, escalas y orientaciones, y mantener una biblioteca central. Se construye cuando el flujo manual ya esté probado.

## 1. Principios

- Los recursos se producen y validan por paquetes completos antes de integrarlos.
- No generar todo el contenido del juego de una sola vez.
- Un paquete debe estar suficientemente completo para probarse en el juego.
- Mantener consistencia general con variaciones deliberadas.
- Equilibrar detalle visual y fluidez de animación.
- Todo recurso necesario durante la partida debe estar almacenado localmente.
- Claude coordina generación, edición, conversión, integración y validación. No debe asumir que un único modelo puede producir por sí solo todos los recursos finales.

## 2. Paquetes de producción

Orden inicial recomendado:
1. Protagonista y kit de animación.
2. Zona de prueba con tiles/escenarios, colisiones, iluminación y objetos.
3. Primer conjunto de especies y comportamientos.
4. Primer paquete de audio y voces.
5. Primera zona vertical completa.
6. Paquetes sucesivos de zonas, especies, piezas, eventos e historias.

Cada paquete debe incluir:
- Brief y referencias aprobadas.
- Lista de recursos y metadatos.
- Archivos fuente y exportaciones.
- Convenciones de nombres.
- Licencias/procedencia.
- Pruebas de importación.
- Validación dentro del motor.
- Registro de incidencias y versión.

## 3. Dirección artística

- Perspectiva: vista alta inclinada (tipo Zelda), con cámara alta de ángulo fijo. No es isométrica ni cenital pura.
- Mundo alienígena biomecánico.
- Sensación extraña, física, divertida y ocasionalmente grotesca.
- Consistencia de siluetas, escala, paleta, iluminación y articulaciones.
- Se permiten variaciones entre individuos y zonas, pero no deformaciones accidentales que rompan la identidad visual.

Crear una ficha maestra por personaje/especie con:
- Silueta y proporciones.
- Vistas y orientaciones en vista alta inclinada.
- Paleta y materiales.
- Articulaciones y puntos de anclaje.
- Variantes autorizadas.
- Expresiones, gestos y señales.
- Reglas de animación y oclusión.

## 4. Protagonista y animación

- Extremidades independientes con rigging/huesos 2D.
- Cuatro brazos, dos piernas, cabeza y cola.
- Definir anclajes estables por posición.
- Animaciones base reutilizables.
- Movimientos especiales asociados a piezas.
- Animación combinada: huesos, procedimientos y clips específicos.
- Evitar animaciones únicas para cada combinación de piezas.
- Validar todas las combinaciones compatibles prioritarias en vista alta inclinada.
- La cola debe permitir comunicar qué IA habla mediante cambios de color claramente distinguibles.

## 5. Recursos gráficos

Flujo sugerido:
1. Brief visual y ficha de consistencia.
2. Creación del arte en SVG o Godot, tomando como referencia la hoja de diseño del protagonista.
3. Edición y corrección.
4. Construcción de sprites/atlas o recursos riggeables.
5. Preparación de pivotes, anclajes, máscaras y capas.
6. Importación al motor.
7. Pruebas de escala, oclusión, colisión y animación.
8. Aprobación del paquete.

Claude puede usar herramientas locales para procesar imágenes, pero debe registrar versiones, parámetros relevantes y licencias. La partida nunca debe llamar a esos servicios.


## 9. Contenido configurable

Especies, piezas, compatibilidades, eventos, misiones, frases, gestos, sonidos y parámetros deben estar definidos en datos externos siempre que resulte práctico. Los datos deben validarse antes de entrar en el juego.

No permitir que un archivo de contenido ejecute código arbitrario. Los comportamientos nuevos deben componerse mediante reglas y capacidades previamente implementadas.

## 10. Criterio de aceptación de un paquete

Un paquete no está terminado solo porque existan los archivos. Debe:
- Importarse sin errores.
- Respetar la ficha visual/sonora.
- Funcionar en el motor.
- Tener metadatos completos.
- Superar pruebas automáticas y visuales aplicables.
- No romper paquetes existentes.
- Estar documentado y versionado.

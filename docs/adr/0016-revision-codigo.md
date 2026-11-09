# ADR 0016: revisión de código, datos, pruebas y rendimiento (P-24)

Estado: pendiente de aprobación del director.

## Separación de clases
Sin cambios de comportamiento ni de controles.

| Clase | Sale a |
|---|---|
| `Sandbox` | `LevelHud`, `PointerOrders`, `LevelSaveState`, `LevelBounds` (`scenes/level/`) |
| `Guard` | `GuardVisual`, `GuardAttack`, `GuardImpacts` |
| `BetaZone` | `BetaInterface`, `BetaFacades`; el reparto y los objetos salen de datos |

Los componentes son `RefCounted` llamados desde su dueño siempre que se puede, para no alterar el orden de `_physics_process` ni de la entrada.

## Contenido por datos
Solo lo que ya existía. P-23, P-25, P-26 y P-27 siguen fuera.

| Qué | Dónde | Quién lo lee |
|---|---|---|
| Razas: color, arte, material, plural, muñeco, muertes | `actor` en `data/world/species.json` | `SpeciesCatalog` |
| Progenitores | `data/world/progenitors.json` | `ProgenitorCatalog` |
| Zona: razas, hogares, reparto, objetos, convertibles, geometría | `data/zones/beta.json` | `ZoneDefinition`, `BetaLayout` |
| Armas del jugador y de enemigos | `data/combat/weapons.json` | `WeaponCatalog` |
| Tipos de muerte | `data/combat/deaths.json` | `DeathCatalog` |
| Animaciones de enemigos | `data/art/enemy_animations.json` | `EnemyRig` |

Límites actuales:
- Las batallas siguen siendo de dos bandos: usan las dos primeras razas de la zona.
- Una raza nueva necesita su muñeco en `StrategyView` y sus textos en `battles.json`.
- Una zona nueva necesita su JSON y su propio script de retos, como `BetaChallenges`.
- Una muerte con varias opciones usa la semilla de la partida; con una sola no consume números.

## Pruebas
`tests/flows/` añade recorridos completos con enemigos activos (`tools/beta_walker.gd`, compartido con `tools/recorrido_beta.gd`) y flujos desde acciones de entrada. Sin ventana no hay posición de ratón: esas pruebas entran por `PointerOrders.order_at`. Los clics reales están en `tools/probar_pelea.gd`.

## Rendimiento
Medido con `tools/medir_exportado.tscn`, con 43 personajes, en juego exportado (Linux, plantilla oficial 4.7.2) y en editor, comparando versiones alternadas. Máquina de 2 núcleos y gráfica por software: el dibujo solo vale como proporción.

| Medida (exportado, ciudad) | `main` | Esta rama |
|---|---|---|
| Física con ventana, media de 3 | 2,8 ms | 2,6 ms |
| Fotograma con gráfica software, media de 3 | 127 ms | 124 ms |
| Física sin ventana, 4 tandas | 3 a 9 ms | 3 a 4 ms |
| Carga de la zona | 150 a 206 ms | 174 a 202 ms |
| Paquete `.pck` | 19 MB | 20 MB |

La diferencia entra en el ruido, salvo la física con ventana (más baja en las 3 comparaciones). La separación y los datos no empeoran el rendimiento.

Cambios previos a medir en la gráfica real: los bocadillos ocultos dejan de procesarse (46 en la zona), la oclusión de paredes solo se recalcula si el personaje se mueve o se agacha, y la zona visible se calcula una vez por tick.

### Medido en el ordenador del director (Intel HD Graphics 520, Windows, exportado, 1920x1080)

| Caso | `main` | Con círculos por textura y vista de batalla sin lo tapado |
|---|---|---|
| Ciudad | 84 ms | 29 ms |
| Noche | 59 ms | 29 ms |
| Batalla, vista de estrategia | 250 ms | 16 ms |

Apagar partes en `main` mostró que filtro (3 ms), interfaz (4 ms) y resolución (4 ms) casi no cuentan, y que el coste estaba en cada figura suelta: ambiente 38 ms y resto de actores unos 30 ms.

Cambios: `CircleDot` sustituye a `draw_circle` en ambiente, árboles, sombras, atrezo y vista de estrategia (textura compartida, en vez de un polígono por círculo). La vista de estrategia oculta el mundo y las capas que tapa mientras está abierta.

Queda por bajar de 29 ms a los 16,6 de 60 imágenes por segundo. Tras la mejora, apagar personajes o paredes ahorra unos 2,5 ms cada uno; objetos, fachadas y conos, nada medible. Sin los actores son 16 ms: lo que falta apunta al protagonista, dibujado con polígonos en cada fotograma.

## Exportación
`export_presets.cfg`: Linux y Windows finales, sin `addons`, `tests`, `tools` ni `docs`, más «Medicion Linux» con la herramienta de medir. Para medir: exportar ese preajuste y poner junto al ejecutable un `override.cfg` con `[application]` y `run/main_scene="res://tools/medir_exportado.tscn"`. La exportación de Windows no se ha ejecutado.

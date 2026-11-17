# ADR 0035: arte de personajes y delimitadores de caminos

Estado: aceptado por el director el 17-nov-2026. Implementado en la fase
«Arte de personajes y delimitadores de caminos» (rama
`fase/arte-personajes-y-delimitadores`). Cubre P-52, P-51 (incluido P-25),
P-53 y P-54.

## Contexto

El director pidió cuatro mejoras para la fase: los NPCs y el dron pasan de 4
a 8 direcciones (P-52); el protagonista gana más movimientos, terminando la
animación por arma/acción aprobada en P-25 (P-51); los corredores se delimitan
con edificios en vez de muros, tanto en la zona cero como en las 8 zonas del
PR #28 (P-53); y `despliegue_cero` se amplía al tamaño del resto de zonas para
usar los mismos delimitadores en todas las conexiones (P-54).

El director concretó tres decisiones de diseño durante la fase:

- P-52: se aprueba la muestra de estilo de las diagonales del mohócrata, se
  producen el resto, y el espejo de poniente (SO/O/NO) es directo, sin retoques
  deasimetrías (tarjeta, setita del sombrero).
- P-51: todos los gestos se añaden «a la vez»; los tres gestos sociales son
  automáticos en su contexto; provocar salta al hacer clic derecho sobre un
  enemigo en alerta; la muerte del protagonista tiene visual propio, fuera del
  `DeathCatalog`.
- P-54: mantener la ciudad donde está y añadir afueras de bosque; P-53 aplica
  a la zona cero **y** a las 8 zonas del PR #28 (no solo a las nuevas).

## Decisión

### 1. P-52: ocho direcciones para NPCs y dron

Cinco vistas dibujadas por figura — sur, sureste, este, nordeste y norte — y
tres reflejadas — oeste desde este, suroeste desde sureste y noroeste desde
nordeste. El mapeo sigue los 8 octantes de `Player.octant_of()`;
`GuardVisual.is_side(view)` decide si se aplica el espejo horizontal
(`size.x` negativo en el dibujo plano, `rig.scale.x` negativo en el rig).
Vista caída conserva la dirección en la que murió.

`GuardVisual.load_views()` y el dron cargan las 5 texturas. Las diagonales del
rig existen para las 3 especies con esqueleto (jubilado, mohócrata, Don Ramón)
con joints medidos sobre el arte nuevo (no copias de la vista este) y `front`
ajustado en las dos vistas NE donde el brazo cercano es el izquierdo.

**Rendimiento:** de 3 a 5 texturas por especie (~3,7 MiB de VRAM adicionales para las
8 figuras) y de 3 a 5 rigs perezosos por guardia con esqueleto. No hay coste
por fotograma: la selección de vista es el mismo número de operaciones.

### 2. P-51: máquina de gestos del protagonista

`data/art/action_frames.json` pasa de 3 a 14 acciones con `priority`,
`duration` y `holds_movement`/`terminal` opcionales. Los 9 gestos de cuerpo
entero son `rig_only: true` con `frames: []` (sin fotogramas provisionales de
idle): `ProtagonistArt.pose_for(state)` es una función pura que devuelve
inclinación, desplazamiento, escala de balanceo, rotaciones por pieza, cola y
squash. Los 5 fotogramas nuevos del atlas (`lanzar_0..2`, `convertir_0..1`) se
dibujan por código con `Palette`, igual que los 7 de P-25.

`Player` sustituye el temporizador cosmético de 0,5 s por prioridades: un clip
de más prioridad interrumpe, uno igual se encola (tope 2), uno menor se
descarta y uno terminal no vuelve a idle. Se conectan señales reales:
`piece_destroyed` (tambaleo + chispas), `died` (secuencia propia de 1,5 s con
`PROCESS_MODE_ALWAYS` para que se vea detrás del game over), retos completados
y conversación. Los gestos sociales saltan solos; provocar no sustituye al
ataque del clic derecho. El fotograma de ataque se elige con la cadena
**arma → tipo (`gesture_type` en `weapons.json`) → genérico**.

Dos desviaciones conscientes del borrador: convertir no frena el movimiento
(la pausa modal ya inmoviliza y congelar al cerrarla rompería el flujo), y
`idle` de 30 s / rascarse de 15-25 s no cuenta la pausa táctica.

### 3. P-53: corredores delimitados por edificios

`corridors[].facades` es la forma normal; `walls` queda soportado como legacy.
Cada rect se monta como `CorridorFacade` (`StaticBody2D` en `actors`, capa
`PhysicsLayers.WALLS`, frente de 200 u hacia el norte, colisión real, sin
desvanecido, y-sort). No se reutilizó `BuildingFacade` porque es un edificio
transitable sin colisión, con `_process` de translucidez y dependencias de
puerta: meter un «modo muro» dentro habría puesto en riesgo las dos fachadas de
`despliegue_cero`. Los rects entran en `ZoneBase._all_blockers()` para NavGrid.
El fondo BACKDROP de las bocas sur/este se construye con `walls` **o** `facades`.

No se permite declarar ambos delimitadores en un corredor: `validar_datos.py`
lo rechaza y `ZoneDefinition.corridors()` avisa con `push_error`.

Cuatro fachadas SVG genéricas (`fachada_corredor_01..04.svg`, viewBox
400×240) se alternan desde `ZoneBase.CORRIDOR_FACADE_ART`. Están dibujadas con
detalle repetido en vertical y series en horizontal para aguantar el estirado
del frente del pasillo; no llevan texto (ThorVG no lo rasteriza).

**Matiz del director (17-nov):** estos 4 modelos son **solo para
`despliegue_cero`**. Cada zona debe tener edificios, colores y elementos
acordes a su lore, también en los delimitadores de corredores. Las 8 zonas del
PR #28 usan hoy los mismos modelos de forma **provisional** (P-56); el sistema
`facades` ya permite sustituir las texturas por zona sin tocar datos ni lógica.

### 4. P-54: zona cero ampliada

`world_size` [4000,4000], `floor_rect` [100,100,3800,3800]. Ciudad, barrios,
patrullas, retos, items y guardados conservan sus coordenadas. Las afueras del
bosque añaden 9 rocas, 3 restos, 11 copas y 5 matas. Los 5 corredores usan
`facades`; las bocas sur pasan a y=3836 y las este a x=3836. La boca norte usa
fachadas de 336 u de largo (en vez de 400) para no atravesar la muralla de la
ciudad. Las 5 bocas siguen alcanzables desde el inicio (verificado en headless).

## Consecuencias y limitaciones

- **Coste de montaje:** `NavGrid` es O(celdas × blockers); el suelo crece de
  8,64 M a 14,44 M px² y hay 10 blockers más. Montar `despliegue_cero` pasa de
  ~0,23 s a ~1,0 s (medido en headless). `despliegue_cero_robustness_test`,
  que monta la zona unas 50 veces, tarda 17-24 min: vigilar el timeout del job
  `despliegue_cero` del CI. En partida, 1 s queda dentro de la carga de 5 s
  decidida para transiciones.
- **Fragilidad previa de pruebas:** `chat_topics_test` y los tests de guardado
  de `despliegue_cero` fallan de forma intermitente al ejecutar varias carpetas
  en un mismo proceso (estado estático y `user://` compartidos). Reproducido en
  un worktree limpio de `HEAD`, sin los cambios de esta fase. El CI ejecuta
  cada grupo en un job aparte.
- **No validado en partida:** las 8 direcciones de los rigs (especialmente las
  dos NE con `front` cambiado), el aspecto de los pasillos con fachadas, las
  posturas de P-51 y la secuencia de muerte de 1,5 s frente al overlay de game
  over inmediato. El director decide si quiere retrasar el overlay para verla
  entera (sería un cambio de mecánica).
- **Provisional:** umbrales de idle, duraciones de clip, ángulos de pose,
  `IDLE_SEED` y el contenido de vegetación en constantes de
  `despliegue_cero_ambient.gd` (no hay modelo de datos de vegetación).
- **Pendiente menor:** `Provocar` no impide que el clic derecho siga enganchando
  combate; cambiarlo sería una mecánica nueva y requiere aprobación.

## Origen y herramienta de los recursos generados

| Recurso | Origen | Herramienta | Fecha |
|---|---|---|---|
| 14 SVG planos `_se`/`_ne` (7 figuras + dron) | Dibujo propio derivado de los SVG sur/este/norte de cada figura | Edición manual de SVG | 17-nov-2026 |
| 30 piezas de rig en `art/shared/rig/*_{se,ne}/` | Dibujo propio, joints medidos sobre el arte nuevo; mohócrata extraído por corte de su plano aprobado | Edición manual de SVG | 17-nov-2026 |
| 4 SVG `fachada_corredor_0{1..4}.svg` | Dibujo propio, estilo «edificio perdido genérico» | Edición manual de SVG | 17-nov-2026 |
| `art/shared/atlas/piezas.png`, `data/art/atlas_piezas.json` | SVG del rig + fotogramas dibujados por código con `Palette` | `tools/art/piece_atlas_gen.gd`, Godot 4.7.2 (consola) | 17-nov-2026 |
| 9 capturas en `docs/borradores/` (8 direcciones por figura + fachadas) | Composición propia de los SVG | Chromium 158 vía Playwright 1.65.0 | 17-nov-2026 |
| `docs/borradores/P-51_gestos_protagonista.md` | Diseño propio | Agente `gameplay` | 17-nov-2026 |

Sin generadores de imagen ni material de terceros. Tras cada regeneración se
ejecutó `godot --headless --import` y `tools/verificar.py`.

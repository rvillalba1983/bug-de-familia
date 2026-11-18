# P-51: Gestos y movimientos del protagonista

Borrador de diseño. No toca código, datos ni escenas.

## 0. Principios

- Los gestos son **visuales sobre mecánicas existentes** (`02_DECISIONES.md`).
  No se añaden inputs nuevos ni mecánicas de juego.
- Cada gesto es un **estado persistente** (agacharse, correr, sentado)
  o un **clip con duración fija** (lanzar, celebrar).
- Un gesto de más prioridad **interrumpe** al de menos.
- Humor gamberra del juego: gestos exagerados, grotescos y cómicos.
- El protagonista es un Sujeto Sobrante (mitad mono, mitad robot,
  mitad IA): sus gestos reflejan esa híbrida torpeza.

## 1. Inventario de gestos

### 1.1 Acciones base

| ID | Gesto | Disparador | Duración | Tipo | ¿ Interrumpe
  movimiento? | Prioridad |
|----|-------|-----------|----------|------|--------------|-----------|
| B1 | Agacharse | X (toggle) | Sostenido | Estado | No (reduce
  velocidad y altura) | 2 |
| B2 | Correr | Mayús / Bloq Mayús | Sostenido | Estado | No (aumenta
  velocidad y ruido) | 2 |
| B3 | Lanzar chatarra | F hacia ratón | 0,4 s | Clip | Sí (breve
  frenado al lanzar) | 5 |
| B4 | Convertir | Q sobre objetivo | 0,6 s | Clip | Sí (la pausa de
  conversión ya para al jugador) | 5 |
| B5 | Recoger repuesto | Automático al pasar encima | 0,25 s | Clip |
  No | 3 |
| B6 | Ataque cuerpo a cuerpo | Automático en pelea (P-37) | 0,3 s |
  Clip | Sí (auto-engage inmoviliza) | 5 |
| B7 | Acción de pieza | Teclas 1–6 | 0,5 s | Clip | No (la pieza
  se activa mientras se mueve) | 5 |

### 1.2 Reacciones

| ID | Gesto | Disparador | Duración | Tipo | ¿ Interrumpe?
  | Prioridad |
|----|-------|-----------|----------|------|-------------|-----------|
| R1 | Recibir daño | `receive_hit()` | 0,25 s | Clip | Sí
  (knockback) | 8 |
| R2 | Perder extremidad | `piece_destroyed` | 0,6 s | Clip | Sí
  (stagger) | 9 |
| R3 | Morir | `body.died` | 1,5 s + corpse | Clip terminal |
  Sí (terminal) | 10 |
| R4 | Celebrar reto | `challenge_completed` | 1,2 s | Clip | No
  (el jugador puede seguir moviéndose) | 4 |

### 1.3 Gestos sociales

| ID | Gesto | Disparador | Duración | Tipo | ¿ Interrumpe?
  | Prioridad |
|----|-------|-----------|----------|------|-------------|-----------|
| S1 | Provocar | Clic derecho sobre enemigo en
  rango de palabra | 0,8 s | Clip | No | 4 |
| S2 | Saludar | Automático al conversar con NPC
  aliado por primera vez | 0,6 s | Clip | No | 4 |
| S3 | Señalar | Automático al examinar con E
  hacia un punto de interés | 0,5 s | Clip | No | 4 |
| S4 | Sentarse | 10 s idle sin moverse ni input
  | Sostenido | Estado | No | 1 |
| S5 | Rascarse | Idle aleatorio (cada 15–25 s
  si está quieto) | 1,0 s | Clip | No | 1 |

### 1.4 Tabla de prioridades (resume qué gana si coinciden)

```
10  Morir              → terminal, nada lo interrumpe
 9  Perder extremidad  → interrumpe cualquier clip activo
 8  Recibir daño       → interrumpe cualquier clip activo
 7  (reserva)
 6  (reserva)
 5  Lanzar / convertir / atacar / acción pieza → clip activo,
    se encola si ya hay otro clip de prioridad 5 en curso
 4  Celebrar / provocar / saludar / señalar → no interrumpe,
    se descarta si hay un clip de prioridad ≥ 5 activo
 3  Recoger            → clip breve, no interrumpe
 2  Agacharse / correr → estado persistente, convive con clips
 1  Sentarse / rascarse → solo si no hay otro gesto activo
 0  Idle               → por defecto
```

Regla: un clip de prioridad N descarta a cualquier clip activo de
prioridad < N. Los clips de igual prioridad se encolan (el actual
termina y empieza el siguiente). Los estados (agacharse, correr,
sentado) no se interrumpen entre sí salvo por muerte.

## 2. Enfoque técnico por gesto

### 2.1 Criterio de elección

El atlas dibuja cada fotograma a 64 × 64 px, que en pantalla se
muestra a `26 × CharacterScale = 13 × 13 px` (con `CharacterScale =
0,5`). A ese tamaño solo se distinguen siluetas de brazo y arma:
**suficiente para acciones de arma, insuficiente para gestos de
cuerpo entero**.

El rig por piezas (`ProtagonistArt`) dibuja las 7 partes del cuerpo
con rotaciones por pivote. La animación de caminar ya usa `_swing()`
para balancear piernas y brazos. **Los gestos de cuerpo entero se
hacen con transformaciones del rig**, no con fotogramas del atlas.

| Enfoque | Cuándo usarlo |
|---------|---------------|
| Fotograma del atlas (P-25) | Acciones de arma: se ve el
  brazo/arma extendido. 13 px bastan para esa silueta |
| Transformación del rig | Gestos de cuerpo entero: agacharse,
  celebrar, sentarse, rascarse, saludar, señalar |
| Combinado (rig + atlas) | Reacciones: el rig se deforma y el
  atlas muestra un efecto (chispas, humo morado) |

### 2.2 Detalle por gesto

**B1 — Agacharse.** Estado. Ya existe (`is_crouching` reduce
`height_ratio`). Mejora: rotación de piernas hacia afuera (±0,15 rad)
y brazos pegados al cuerpo cuando está agachado. Rig. Sin fotogramas.

**B2 — Correr.** Estado. Ya existe (`is_running()`). Mejora:
`WALK_ANIMATION_SPEED` sube un 40 % y `LEG_SWING`/`ARM_SWING` suben
un 30 % al correr. El cuerpo se inclina hacia adelante (rotación de
base de 0,08 rad). Rig. Sin fotogramas.

**B3 — Lanzar chatarra.** Clip, 0,4 s. El brazo principal derecho se
extiende hacia `facing` (rotación de 0 a −1,2 rad en 3 fotogramas
de rig). **Además**, fotograma de atlas `lanzar_0..2` mostrando la
chatarra saliendo de la mano (3 fotogramas, 8 fps). El atlas aquí sí
aporta porque la chatarra es pequeña y el destello de lanzamiento se
ve a 13 px.

**B4 — Convertir.** Clip, 0,6 s. Ambos brazos principales se levantan
(rotación −0,8 rad, 2 fotogramas de rig). Atlas `convertir_0..1`
con el brillo morado en la mano (2 fotogramas, 4 fps). El brillo
morado es la señal visual clave: visible incluso a 13 px.

**B5 — Recoger.** Clip, 0,25 s. Un brazo baja hacia el suelo
(rotación 0,4 rad). Sin fotograma de atlas: el repuesto ya tiene su
propia animación de recogida en `Interactable`.

**B6 — Ataque cuerpo a cuerpo.** Clip, 0,3 s. Ya usa atlas `ataque`.
Se mantiene. Mejora: el brazo que golpea se rota hacia el objetivo
(rig) en vez de quedarse quieto. El atlas marca el impacto.

**B7 — Acción de pieza.** Clip, 0,5 s. Ya usa atlas `recarga`. Se
mantiene. Mejora: el brazo que activa la pieza se rota hacia adelante
(rig).

**R1 — Recibir daño.** Clip, 0,25 s. Ya existe `react_to_hit()` con
squash, shake, flash y hit-stop. Mejora: el cuerpo se inclina hacia
atrás (rotación de base −0,12 rad) durante el squash. Los brazos se
abren (rotación ±0,2 rad). Sin atlas.

**R2 — Perder extremidad.** Clip, 0,6 s. El cuerpo se tambalea
(rotación base oscilante ±0,1 rad, 3 oscilaciones). La pieza que se
rompe ya desaparece del rig automáticamente. Mejora: un breve
`CircleDot` de chispas en el pivote de la pieza rota
(`combat/death_effect.gd` adaptado, efecto `chispas_miembro`).
Prioridad 9: si se pierde una pierna mientras se lanza, el lanzamiento
se cancela.

**R3 — Morir.** Clip terminal, 1,5 s. **No usa DeathCatalog**: el
protagonista no es una especie del catálogo (es un Sujeto Sobrante)
y su muerte es game-over permanente. Propuesta propia:
- 0,0–0,3 s: el cuerpo se encoge (squash 1,3×0,7) y tiembla.
- 0,3–0,8 s: el cuerpo cae hacia adelante (rotación base de 0 a
  1,2 rad). Las piezas sueltas se separan ligeramente (offset de
  pivote 4 px hacia afuera).
- 0,8–1,5 s: cuerpo en el suelo. Las piezas que estén por debajo de
  20 % de durabilidad se sueltan del todo (desaparecen del rig).
- Se reutiliza `ImpactFx` (flash, shake) y se añade un `DeathEffect`
  con efecto `muerte_protagonista` (color `#8894b5`, duración 1,5 s,
  sin alterar reglas ni colisiones, igual que P-27 para guardias).

**R4 — Celebrar reto.** Clip, 1,2 s. Los cuatro brazos se levantan
(rotación −1,0 rad), el cuerpo da un saltito (offset Y −8 px durante
0,3 s con easing), la cola se agita (amplitud del seno × 2 durante
el clip). Sin atlas: el gesto es de cuerpo entero y la alegría se
lee en la postura, no en un icono. Disparador: conectar la señal
`challenge_completed` de `DespliegueCeroChallenges` con una llamada
a `set_action("celebrar")`.

**S1 — Provocar.** Clip, 0,8 s. Un brazo se extiende hacia el
objetivo (rotación −0,6 rad), la cabeza se inclina (rotación 0,15
rad), la cola se eriza (ancho × 1,3). Sin atlas. Se propone como
opción de diálogo contextual (clic derecho sobre enemigo en rango
de palabra, igual que atacar) o como tecla de acción rápida. **Ver
duda 1**.

**S2 — Saludar.** Clip, 0,6 s. Un brazo principal se levanta y se
mueve lateralmente (rotación de −0,8 a −0,5 rad, oscilación de 0,15
rad, 2 ciclos). La cabeza hace un leve asentimiento. Sin atlas.

**S3 — Señalar.** Clip, 0,5 s. Un brazo se extiende hacia el punto
de interés (rotación −0,4 rad en la dirección de `facing`). La
cabeza gira hacia ese punto. Sin atlas.

**S4 — Sentarse.** Estado sostenido. Las piernas se pliegan
(rotación ±0,6 rad), el cuerpo baja (offset Y 12 px). Se sale del
estado al moverse o pulsar cualquier tecla. Sin atlas.

**S5 — Rascarse.** Clip, 1,0 s. Un brazo llega a la cabeza
(rotación −1,3 rad), la cabeza se inclina hacia el brazo (0,1 rad),
oscilación rápida de 0,05 rad (4 ciclos en 0,6 s). Sin atlas.

### 2.3 Resumen de fotogramas de atlas nuevos

| Acción | Fotogramas | FPS | Total |
|--------|-----------|-----|-------|
| `lanzar` | 3 | 8 | 3 |
| `convertir` | 2 | 4 | 2 |
| **Total nuevos** | | | **5** |

Los gestos B1–B2, B5, R1–R4, S1–S5 usan **solo transformaciones
del rig**. El atlas crece de 7 a 12 fotogramas.

## 3. Conexión con el estado real

### 3.1 Dejar de ser cosmético

P-25 dejó `set_action()` como cosmético (0,5 s y vuelta a idle).
P-51 convierte `set_action()` en la fuente de verdad del gesto
visual. Para ello:

- `ActionFrame` gana un campo `duration: float` (−1 = sostenido,
  0 = clip que vuelve a idle al terminar).
- `Player.tick_action()` ya decrementa `_action_left`; P-51 lo
  generaliza: cada acción declara su duración en el catálogo y
  `tick_action` usa esa duración en vez de `ACTION_SHOW_TIME`.
- Las acciones sostenidas (agacharse, correr, sentado) no pasan por
  `ActionFrame`; son estados del `Player` que modifican el rig
  directamente.

### 3.2 Tabla estado → acción

| Estado del jugador | Acción en catálogo | Quién llama
  `set_action()` | Vuelta a idle |
|-------------------|-------------------|---------------------------|------|
  | Idle | `idle` | `tick_action()` al acabar cualquier clip | Automático |
| Agachado | — (estado del
  rig) | `set_crouching()` modifica el rig directamente | Al
  desactivar `is_crouching` |
| Corriendo | — (estado del
  rig) | `_physics_process` detecta `is_running()` | Al dejar de
  correr |
| Lanzando | `lanzar` | `CombatSystem.throw_at()` → `_mark_action`
  | Al acabar el clip (0,4 s) |
| Convirtiendo | `convertir` |
  `ConversionDirector` al arrancar la conversión | Al acabar la
  conversión |
| Atacando | `ataque` o
  `ataque_<arma>` | `CombatSystem.strike()` → `_mark_action` | Al
  acabar el clip (0,3 s) |
| Acción de pieza | `recarga` |
  `ActionSystem.trigger()` | Al acabar el clip (0,5 s) |
| Recibiendo
  daño | `daño` | `Player.react_to_hit()` | Al acabar el clip
  (0,25 s) |
| Perdiendo extremidad | `perdida` |
  `ModularBody.piece_destroyed` → handler en `Player` | Al acabar
  el clip (0,6 s) |
| Muriendo | `morir` |
  `ModularBody.died` → handler en `Player` | No vuelve (terminal)
  |
| Celebrando | `celebrar` |
  `DespliegueCeroChallenges.challenge_completed` → handler | Al
  acabar el clip (1,2 s) |
| Sentado | — (estado del rig) |
  `_idle_timer` en `Player` al superar 10 s | Al moverse o pulsar
  |
| Provocando | `provocar` | Contextual (ver duda 1) | Al acabar
  el clip (0,8 s) |
| Saludando | `saludar` | `Interactable.activate()` si es
  conversación inicial | Al acabar el clip (0,6 s) |
| Señalando | `señalar` | `Player._interact_nearest()` si el
  objetivo es examinable | Al acabar el clip (0,5 s) |
| Rascándose |
  `rascar` | `_idle_timer` aleatorio en `Player` | Al acabar el
  clip (1,0 s) |

### 3.3 Selección de fotograma según arma equipada

P-25 aprobó «animación por arma y acción». Propuesta pragmática:

1. **Catálogo con sufijos opcionales.** Las claves del catálogo
   admiten sufijo de arma: `ataque_lanzar_0`, `ataque_a101_0`, etc.
2. **Cadena de búsqueda.** Al pedir `ataque` para el arma equipada:
   - Primero busca `ataque_<arma>_N` (ej: `ataque_lanzar_0`).
   - Si no existe, busca `ataque_<tipo>_N` (tipo: `proyectil`,
     `scatter`, `aturdir`, `melee`).
   - Si no existe, usa `ataque_N` (genérico).
3. **Implementación inicial.** Solo dos conjuntos de fotogramas:
   - `ataque` (genérico, ya existe): 3 fotogramas.
   - `lanzar` (propio de chatarra): 3 fotogramas nuevos.
4. **Ampliación futura.** Cada arma nueva puede añadir su propio
   conjunto sin tocar el código de selección; solo datos en
   `action_frames.json` y fotogramas en `piece_atlas_gen.gd`.
5. **El tipo de arma** se declara en `weapons.json` con un campo
   opcional `"gesture_type": "proyectil"` (o `scatter`, `aturdir`).
   Sin campo, se usa el genérico.

### 3.4 Gestos que conviven con el movimiento

Los gestos de prioridad ≤ 4 (celebrar, provocar, saludar, señalar,
recoger) **no bloquean el movimiento**. El jugador puede seguir
andando mientras el clip se reproduce. El rig combina la pose del
gesto con el `walk_phase` del caminar: el balanceo de piernas sigue,
pero los brazos adoptan la pose del gesto.

Los gestos de prioridad ≥ 5 (lanzar, convertir, atacar) **sí bloquean
el movimiento** durante el clip. El `Player` pone `controls_locked =
true` temporalmente (ya existe ese campo) o simplemente ignora el
input de movimiento durante la duración del clip.

## 4. Rendimiento

### 4.1 Tamaño del atlas

| Concepto | Antes P-51 | Tras P-51 |
|----------|-----------|-----------|
| Piezas del rig | 55 | 55 |
| Fotogramas de acción | 7 | 12 |
| **Total entradas** | **62** | **67** |
| Altura usada (2048 px) | ~170 px | ~234 px
  (+64 px, una fila de 64 px) |
| Tamaño PNG estimado | ~80 KB | ~85 KB |

El atlas queda al 11 % de su capacidad. Sin riesgo de saturación.

### 4.2 Draw calls

- Cada fotograma de atlas añade **1 draw call por personaje** que lo
  muestre. El protagonista ya muestra 1 fotograma (P-25): **no cambia
  el total de draw calls**.
- Los gestos de rig no añaden draw calls: modifican las
  transformaciones de las mallas existentes (`_mesh_for`).
- Los efectos de reacción (chispas, muerte) usan `CircleDot.draw()`
  que añade 1 draw call por círculo, igual que los efectos de daño
  actuales. Máximo 3–5 círculos durante 0,6 s: coste despreciable.

### 4.3 Coste de CPU

- Transformaciones del rig: 7 rotaciones adicionales por fotograma,
  cada una es un `sin()`/`cos()` y una multiplicación de `Transform2D`.
  Coste: < 1 µs por fotograma. Despreciable.
- El `_idle_timer` para sentarse y rascarse es un `float` que se
  decrementa en `_physics_process`: coste nulo.
- El `CircleDot` de efectos son 3–5 llamadas a `draw_circle`:
  < 2 µs. Despreciable.

### 4.4 Riesgo en Intel HD 520

La medición real (15-nov) marca **153 ms/fotograma** caminando, con
el cuello de botella en el renderizado de los 36 guardias (~118 ms,
draw_calls 130–158). El protagonista consume un 24 % del fotograma
(~37 ms), pero ese coste es el rig completo del protagonista con
sus 7 piezas, cola, sombra y action frame.

P-51 añade:
- 5 fotogramas nuevos en el atlas (mismo `draw_texture_rect_region`,
  misma textura compartida `PieceAtlas`).
- Transformaciones de rig adicionales (7 rotaciones por pieza,
  mismas mallas cacheadas en `_meshes`).
- Efectos `CircleDot` ocasionales.

**Estimación:** +0 draw calls al protagonista (mismo número de
piezas), +0 al resto de la escena, +< 1 ms de CPU. El riesgo real
sigue siendo el que ya existe: los 36 guardias fuera de pantalla
(P-30, pendiente de culling de renderizado). P-51 no empeora el
rendimiento medible.

## 5. Orden de implementación

Rebanadas verticales. Cada rebanada deja un ejecutable funcional y
se puede probar en partida.

### Rebanada 1: infraestructura de gestos (datos + código)

- **Datos:** ampliar `action_frames.json` con las nuevas acciones
  (`lanzar`, `convertir`, `daño`, `perdida`, `morir`, `celebrar`,
  `provocar`, `saludar`, `señalar`, `rascar`). Con fotogramas
  provisionales (copias de `idle` como marcador).
- **Código:**
  - `ActionFrame` gana campo `duration`.
  - `ActionFrameCatalog` lee la duración.
  - `Player.tick_action()` usa la duración del catálogo en vez de
    `ACTION_SHOW_TIME`.
  - `Player` conecta `body.piece_destroyed` y `body.died` con
    `set_action("perdida")` / `set_action("morir")`.
- **Tests:**
  - `action_frame_test.gd`: las acciones nuevas existen en el
    catálogo, la duración se lee correctamente, la vuelta a idle
    funciona.
  - Prueba de prioridad: un clip de prioridad 8 interrumpe a uno
    de prioridad 5.
- **Validación:** las acciones nuevas se muestran con los fotogramas
  provisionales de `idle`. No se ve arte nuevo, pero la máquina de
  estados funciona.

### Rebanada 2: mejoras del rig por estado

- **Código:**
  - `_swing()` en `ProtagonistArt` gana modificadores por estado:
    `_crouch_swing()`, `_run_swing()`, `_sit_pose()`.
  - `Player` pasa su estado completo a `ProtagonistArt.draw()`
    (ampliando la firma con un `Dictionary` de modificadores de
    pose).
  - `_idle_timer` en `Player` para detectar 10 s de inactividad.
- **Tests:**
  - Verificar que los modificadores de pose se aplican correctamente
    (rotaciones dentro de rango, offsets correctos).
  - Verificar que el timer de idle se resetea al moverse.
- **Validación manual:** el protagonista se ve agachado de forma más
  clara, corre con más ímpetu, se sienta al estar quieto.

### Rebanada 3: arte de fotogramas nuevos

- **Arte:** `piece_atlas_gen.gd` dibuja los 5 fotogramas nuevos
  (`lanzar_0..2`, `convertir_0..1`) con la paleta «Cuñado
  Radiactivo», igual que los 7 actuales.
- **Datos:** se actualizan las claves en `action_frames.json`.
- **Tests:**
  - `action_frame_test.gd`: los fotogramas nuevos existen en el
    atlas (`PieceAtlas.has_entry`).
  - `validar_datos.py`: el conteo de `action_frames` sube a 8
    (antes 3, ahora 3 + 2 nuevas acciones con 5 fotogramas = 8
    acciones en el catálogo... en realidad 3 + 7 nuevas = 10 acciones
    con 12 fotogramas en total).
- **Validación manual:** regenerar atlas, `godot --headless
  --import`, ver los fotogramas nuevos en partida.

### Rebanada 4: reacciones y muerte

- **Código:**
  - `Player.react_to_hit()` añade la inclinación hacia atrás y la
    apertura de brazos.
  - Handler de `piece_destroyed`: stagger del rig + efecto
    `chispas_miembro` (nuevo `DeathEffect`).
  - Handler de `body.died`: secuencia de muerte en 3 fases (ver
    §2.2 R3). Se instancia un `DeathEffect` propio.
- **Tests:**
  - Recibir daño aplica la inclinación (verificar `_squash` y la
    rotación base).
  - Perder una pieza emite `set_action("perdida")`.
  - La muerte emite `set_action("morir")` y bloquea el movimiento
    (`controls_locked` permanente).
- **Validación manual:** jugar hasta recibir daño, perder una pieza
  y morir.

### Rebanada 5: celebrar y gestos sociales

- **Código:**
  - Conectar `challenge_completed` con `player.set_action("celebrar")`.
  - Conectar `Interactable.activate()` de conversación con
    `set_action("saludar")` si es la primera vez.
  - Conectar `_interact_nearest()` con `set_action("señalar")` si
    el objetivo es examinable.
  - Rascarse: `_idle_timer` con RNG local (no consume semilla
    global, igual que P-25).
- **Tests:**
  - Completar un reto dispara `celebrar`.
  - El timer de idle activa `sentado` a los 10 s y `rascar`
    aleatoriamente.
- **Validación manual:** jugar y observar los gestos en contexto.

### Rebanada 6: selección de fotograma por arma

- **Datos:** añadir `"gesture_type"` a `weapons.json`.
- **Código:** `CombatSystem._mark_action()` busca primero el
  fotograma con sufijo de arma, luego el de tipo, luego el genérico.
- **Tests:**
  - Con arma `lanzar` se usa `lanzar_0`.
  - Con arma `a101` se usa `ataque_0` (genérico, por no tener
    fotograma propio).
  - La cadena de búsqueda funciona.
- **Validación manual:** lanzar chatarra y atacar con armas distintas
  deben verse diferentes.

## 6. Dudas abiertas para el director

### Duda 1: ¿Cómo se dispara «provocar/insultar»?

Los controles actuales tienen una tecla por acción (regla del
director, 9-nov). `docs/controles.md` no tiene una tecla libre para
«provocar». Opciones:

- (a) Clic derecho sobre un enemigo en rango de palabra (ya hace
  «atacar» o «hablar» según el estado). Se añade un tercer contexto:
  «provocar» si el enemigo está en alerta pero no en pelea.
- (b) Tecla nueva (rompe la regla de una tecla = una acción).
- (c) Acción numérica (1–6), ligada a una pieza que se desbloquea.

Recomiendo (a): no añade teclas y encaja con el flujo de combate.

### Duda 2: ¿El protagonista usa muertes del DeathCatalog?

El catálogo de P-27 tiene 12 muertes con efectos, repartidas por
especie. El protagonista no es una especie del catálogo. Opciones:

- (a) Muerte propia, fuera del catálogo (propuesta en §2.2 R3).
  Efecto visual exclusivo: las piezas se sueltan y caen alrededor.
- (b) Reutilizar una muerte genérica del catálogo (ej: `trozos`).
  Más barato, pero pierde el impacto dramático del game-over.

Recomiendo (a): la muerte del protagonista es el momento más
importante del juego y merece un tratamiento visual propio.

### Duda 3: ¿Los gestos sociales son automáticos o manuales?

Saludar, señalar y provocar pueden ser automáticos (el juego decide
cuándo) o manuales (el jugador los activa). Opciones:

- (a) Automáticos: más fluido, el jugador no tiene que memorizar
  teclas nuevas. Riesgo: pueden saltar en momentos inesperados.
- (b) Manuales: el jugador controla cuándo usarlos. Riesgo: requiere
  teclas nuevas o reasignación.
- (c) Mixto: saludar y señalar automáticos; provocar manual (clic
  derecho contextual, duda 1).

Recomiendo (c): los gestos «inocuos» son automáticos; el gestos
«agresivo» (provocar) requiere intención del jugador.

### Duda 4: ¿Sentarse y rascarse son opcionales o obligatorios?

Son gestos de «personalidad» que no aportan mecánica. En un juego
de sigilo táctico, un protagonista que se sienta solo puede
despistar al jugador («¿por qué se ha parado?»). Opciones:

- (a) Activados por defecto. El jugador los ve y sabe que son
  coséticos.
- (b) Desactivados por defecto. Solo se ven si el jugador está
  10 s quieto a propósito.
- (c) Con un umbral más alto (30 s en vez de 10) para que no
  salten durante una pausa táctica.

Recomiendo (c): umbral de 30 s para sentarse, 15–25 s para rascarse.
La pausa táctica (Espacio) no cuenta como idle.

### Duda 5: ¿Las mejoras del rig (agacharse, correr) se hacen en
esta fase o en una siguiente?

Las rebanadas 2 y 3 (mejoras del rig y arte de atlas) son
independientes entre sí. Opciones:

- (a) Todo en la misma fase, como pide el director («todo a la
  vez»). Más trabajo de arte, pero el resultado es coherente.
- (b) Primero infraestructura (rebanadas 1, 4, 5, 6) y luego arte
  (rebanadas 2, 3). Permite validar la máquina de estados antes
  de invertir en arte.

Recomiendo (b): la infraestructura se puede probar sin arte nuevo,
y el arte se valida contra una máquina de estados que ya funciona.
Reduce el riesgo de tener que rehacer fotogramas si la máquina de
estados cambia.

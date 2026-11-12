# ADR 0027: infraestructura multi-zona

Estado: propuesto por el director el 11-nov-2026. Pendiente de implementación en la fase de infraestructura post-beta.

## Contexto

El juego completo (fase «Post-beta. Mundo completo» del plan) necesita varias zonas independientes, conectadas por accesos que se descubren explorando, con cargas breves, tres niveles de simulación y persistencia entre visitas. Hoy solo existe la zona beta (`data/zones/beta.json`, escena `scenes/beta/beta_zone.tscn`), que es un escenario único de 3800 × 2600 u.

El director ha definido los parámetros del mundo: **24 zonas** (6 territorios de especie + 1 frontera + 1 nudo neutral + 1 final + 15 zonas intermedias), mundo de 16.700 × 16.700 u (≈ 500 × 500 m reales), formas no rectangulares talladas con zonas bloqueadas, 3–5 especies por zona, 80–150 NPCs por zona, y conexiones por corredores que llevan al borde (cambio de zona al cruzar). El mapa completo está en `art/mapa_zonas_propuesta.svg`.

Las preguntas de arquitectura planteadas el 11-nov quedan resueltas con las decisiones siguientes.

## Decisión

### 1. Estructura de escena por zona: híbrido

Geometría fija en escena Godot (TileMapLayer + nodos con colisiones), población, objetos y parámetros desde el JSON de la zona (`data/zones/<id>.json`). Es lo que ya hace la beta (`scenes/beta/beta_zone.tscn` + `data/zones/beta.json`) y funciona.

Motivo: los nodos físicos (paredes, corredores, puntos de guardado) necesitan colisiones reales en Godot. Generarlos desde JSON es frágil y difícil de depurar visualmente. El híbrido separa lo que el editor maneja bien (geometría) de lo que los datos manejan bien (población, objetos, parámetros).

### 2. Transición entre zonas: carga con 5 s mínimo

Al cruzar un borde por un corredor, se muestra una pantalla de carga con un tiempo mínimo de 5 s (decisión P-26 del 11-nov). Durante la carga se muestran las IAs activas del destino como fantasmas (P-26, opción 1a). El tiempo del mundo avanza durante la carga.

Si alguna zona tarda más de 5 s en cargar, se revisará que los fantasmas impliquen interacción con el jugador (preguntas) para no perder tiempo.

### 3. Estado persistente: híbrido

- La zona actual se mantiene en memoria con todo detalle (entidades, posiciones, estados).
- Las zonas visitadas pero no actuales guardan solo su estado persistente: población por especie, objetos y su estado, cambios producidos (puentes rotos, zonas inundadas), misiones y acontecimientos.
- Al guardar la partida se serializa el estado de todas las zonas conocidas.

Motivo: con 24 zonas y 80–150 NPCs cada una, mantener todo en memoria todo el tiempo es inviable. La zona actual tiene entidades completas; las demás solo datos agregados.

### 4. Nivel de simulación por distancia: por saltos en el grafo

- **Completa**: la zona donde está el jugador (IA, movimiento, interacciones, animación individual).
- **Simplificada**: las zonas conectadas directamente al nodo actual en el grafo (máximo 5, solo en El Enchufe). Se actualizan individuos sin animación ni renderizado.
- **Estadística**: todas las demás zonas conocidas. Solo poblaciones, recursos, relaciones y acontecimientos agregados.

El grafo de 24 nodos ya está planteado en `art/mapa_zonas_propuesta.svg`.

### 5. Simulación simplificada: individuos sin animación

En zonas simplificadas se actualizan posiciones, estados y decisiones de los individuos, pero no se animan ni se renderizan. Esto garantiza que al volver a la zona no se regeneren personas nuevas (persistencia), sin pagar el coste de renderizado.

### 6. Forma de la zona: array de rectángulos (shape_blocks)

En el JSON de la zona, el campo `geometry.shape_blocks` es un array de rectángulos `[[x, y, w, h], ...]` que representan las zonas bloqueadas (fuera de la forma). El `NavGrid` ya acepta `blockers` como `Array[Rect2]`, así que no requiere cambios en el motor.

Motivo: reutiliza código existente, sin riesgo de regresión. Un zigzag de 3 tramos se construye con 4–6 bloques de esquina.

### 7. Corredores de conexión: rectángulos explícitos

En el JSON de la zona, el campo `geometry.corridors` es un array de objetos:

```json
"corridors": [
  {"to": "beta", "edge": "north", "rect": [x, y, w, h]}
]
```

Cada corredor es un rectángulo caminable que llega al borde de la zona. El `NavGrid` trata esas celdas como transitables (no bloqueadas). El cambio de zona ocurre al cruzar el borde por un corredor.

### 8. NavGrid: construido al cargar

El `NavGrid` se construye al entrar en cada zona, desde `floor_rect` y `shape_blocks`. Con 56.100 celdas máximo (zona de 5.000 × 3.200 a 16 px), la construcción tarda menos de 100 ms. No se precalcula ni se comparte entre zonas.

### 9. Población por zona: declarada en el JSON

Cada zona declara sus especies y límites de población en su propio JSON:

```json
"species": ["jubilado", "mohocrata"],
"population": {
  "jubilado": {"start": 40, "target": 50, "max": 75},
  "mohocrata": {"start": 40, "target": 50, "max": 75}
}
```

**Nota importante:** las especies se fijarán en los mismos lugares siempre, para que tengan relación con la historia y el lore. El sistema de generación de contenido debe respetar estas asignaciones y no reubicar especies entre partidas. Los progenitores, facciones y acontecimientos históricos de cada zona se definen en su JSON y no varían.

### 10. Viaje rápido: el tiempo del mundo avanza

Durante el viaje rápido el mundo sigue simulándose (zonas simplificadas y estadísticas se actualizan). El coste de piernas y tokens (ya decidido) compensa la ventaja. Es coherente con «el mundo sigue sin ti».

### 11. Guardado: autoguardado en cada transición

Al cruzar un borde y cambiar de zona, se autoguarda la partida. Con muerte permanente y un solo espacio de partida, esto protege contra cierres inesperados sin ser intrusivo. El coste de serializar la zona actual es bajo.

### 12. Zonas desconocidas: todas se simulan siempre

Todas las zonas conocidas se simulan siempre (incluso las lejanas, en nivel estadístico). Las zonas que el jugador no ha visitado ni de las que ha oído rumores no se simulan. Si hay problema de rendimiento, se revisará este punto.

## Consecuencias y limitaciones

- La decisión 9 implica que el JSON de cada zona debe declarar no solo las especies presentes, sino también su relación con el lore (progenitores, facciones, acontecimientos históricos). Esto debe quedar documentado para que el sistema de generación de contenido respete esas asignaciones.
- La decisión 2 deja abierta la posibilidad de que los fantasmas de carga impliquen interacción (preguntas al jugador) si los tiempos de carga superan los 5 s.
- La decisión 12 puede requerir optimización si 24 zonas simulándose siempre generan tirones. Se medirá en la fase de infraestructura.
- La decisión 11 (autoguardado en transición) requiere que la serialización de la zona actual sea rápida. Se medirá.

## Referencias

- Parámetros de las 24 zonas: `art/mapa_zonas_propuesta.svg`.
- Documento de zonas y contenido: `docs/34_zonas_y_contenido.md`.
- Decisión de viaje rápido y fantasmas: `docs/01_CONFLICTOS_Y_PENDIENTES.md` (P-26).
- Tres niveles de simulación: `docs/15_mundo_tiempo.md`.
- Regla de no inventar el mapa: `docs/02_DECISIONES.md` («Lo que no se puede inventar»). El mapa del mundo lo define el director; los parámetros de zonas se acordaron el 11-nov.

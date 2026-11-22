# ADR 0039: mapa ratificado, rumor de zonas y escala de toda la población (22-nov)

Estado: decisiones del director del 22-nov; en implementación en la rama
`fase/mundo-completo-mapa-y-consecuencias`. Pendiente de aprobación y fusión.

## Contexto

El plan (`docs/40_plan_desarrollo.md`) cierra la fase «Post-beta. Mundo completo»
con el criterio «sin perder ni duplicar nada al cambiar de zona o de nivel».
La infraestructura multi-zona ya está fusionada (ADR 0027), pero quedaban tres
decisiones del 10-nov abiertas (`docs/01_CONFLICTOS_Y_PENDIENTES.md`): qué zonas
y tamaños, si el tiempo avanza durante el viaje y cómo se conoce una zona por
rumor. También estaba abierta la aplicación de la escala visual 30-80 % (P-6).

El director decidió el 22-nov:

1. ratificar las **24 zonas** ya existentes en `data/zones/` y su grafo;
2. el **tiempo del mundo avanza** durante el viaje (confirma ADR 0027, decisión 10);
3. el **viaje rápido a zonas oídas por rumores entra en esta fase**;
4. la escala 30-80 % se aplica a **toda la población**, no solo a nacimientos.

## Decisión

### 1. Mapa: sin cambios de datos

Las 24 zonas de `data/zones/` y `art/mapa_zonas_propuesta.svg` son definitivas:
`world_size` 4000 × 4000 u por zona (mundo 16.700 × 16.700 u) y corredores
existentes. `despliegue_cero` mantiene su `floor_rect` de 3800 × 3800 u dentro
de ese mundo. No se renombran ni se redimensionan zonas en esta fase.

### 2. Tiempo del viaje: confirmado, sin cambio de comportamiento

`ZoneManager.fast_travel()` ya avanza `TRAVEL_SECONDS_PER_HOP` (60 s) por salto
y `_process()` sigue avanzando mientras carga la pantalla de 5 s. Se añaden
pruebas que fijan el comportamiento; no se modifica el código del reloj.

### 3. Conocimiento por rumor

`ZoneRecord` gana `rumored: bool`, persistido en `to_dict()`/`from_dict()`.
`is_known()` pasa a ser `visited or rumored`, y lo usan `can_fast_travel()`,
`travel_destinations()` y `_advance_world()`; por tanto una zona oída por rumor
se puede visitar en viaje rápido y empieza a simularse en nivel estadístico,
con la población inicial declarada en su JSON (ADR 0027, decisión 12).

`ZoneManager.hear_about_zone(id)` marca el rumor, inicializa el registro
estadístico, emite `zone_rumored` y autoguarda. Es idempotente y no altera una
zona ya visitada. Las zonas no conocidas siguen sin simularse.

La propagación al jugador se engancha en `LiveDialogue`: una opción nueva del
diálogo root permite preguntar por otras zonas. Elige de forma determinista
(hash del id del habitante y de la zona actual, **sin consumir RNG**) una zona
vecina del grafo que no sea conocida, llama a `hear_about_zone()` y nombra la
zona en el parlamento. No se tocan los 900 catálogos de conversación P-42.

### 4. Escala visual 30-80 % para toda la población

Los habitantes simulados ya reciben escala al nacer, llegar o generarse
(`WorldSim._assign_visual_scale()`) y la conservan al restaurar la partida;
`LiveWorld` propaga el valor a `GuardVisual.individual_scale`. Se añaden
pruebas que lo demuestran, porque antes no existían.

Los **actores guionados y progenitores** son la excepción detectada: se crean
fuera de `LiveWorld` y quedaban con `individual_scale = 1.0`. Para cumplir la
decisión del director se les asigna una escala adulta estable derivada de su id
(0.55-0.8, sin RNG global), dentro del rango aprobado. Siguen siendo actores
únicos: no entran en `sim.npcs` ni cambian sus diálogos o flags.

**Quedan fuera** los guardias decorativos del Sandbox y cualquier `Guard` de
prueba: no son población del mundo vivo. `CharacterScale.value` sigue siendo
el multiplicador global (0.5); `individual_scale` es el factor individual
según lo ya implementado en P-6. Solo afecta al dibujo: colisiones, detección
y alcances no cambian.

## Consecuencias y limitaciones

- Una zona oída por rumor entra en el listado de viaje rápido sin haber sido
  pisada; su estado es estadístico hasta la primera visita, donde se genera su
  contenido con la semilla derivada de la partida.
- El rumor de zona es deliberadamente distinto del rumor de eventos de
  `RumorEngine`: este último no referencia zonas. No se inventa un campo `zone`
  en los eventos ni se reescriben los catálogos P-42.
- La escala de actores guionados cambia su tamaño en partida: requiere
  validación visual del director, sobre todo en los 15 progenitores.
- El director pidió el 22-nov una pasada de **arte artístico con un modelo de
  generación de imágenes** para los 15 progenitores, recreando también a los dos
  que ya existían antes del generador por script (Don Ramón y El Contestador).
  Queda registrada como P-58 en `01_CONFLICTOS_Y_PENDIENTES.md` y **no se
  ejecuta en esta fase**: los SVG vigentes siguen siendo los generados por
  `tools/art/progenitores_gen.py`.
- `tools/captura_partida.gd` usaba `dialogue.choose(3)` para abrir el diálogo
  del sombrero perdido. La opción nueva de rumor se inserta en el menú root y
  desplaza ese índice, así que la herramienta ahora busca la etiqueta
  «Hablar» (con «Te cuento algo» como respaldo). Así las capturas siguen
  mostrando el mismo diálogo que antes.
- La regresión de medición de pelea del 19-nov sigue documentada y sin
  confirmar; esta fase no toca código de rendimiento ni la referencia.

## Referencias

- `docs/02_DECISIONES.md`, sección «Mundo completo: mapa y consecuencias (22-nov)».
- `docs/01_CONFLICTOS_Y_PENDIENTES.md`, sección «Decidido el 22 de noviembre».
- `docs/adr/0027-multi-zona.md` (infraestructura, decisiones 10 y 12).
- `simulation/zone_manager.gd`, `simulation/zone_record.gd`,
  `simulation/live_dialogue.gd`, `simulation/world_sim.gd`,
  `entities/enemies/guard_visual.gd`.

# ADR 0030: los retos de la zona solo salen en el chat si se conocen

Estado: **en revisión** (15-nov-2026). Rama `fase/p09-p29-p30-p32-p36-p39-p41`.

## Contexto

P-32 (pendiente del director, 9-nov): «Las misiones de la zona solo aparecen en la lista del
chat si se ha recibido información de ellas, hablando con alguien o por las IAs, y se quitan al
completarlas. Hoy la lista del tema del canal sale completa desde el principio.»

El tema del canal (el `topic` del chat de las IAs) se pintaba una sola vez, al montar la
interfaz, con el texto completo de los cuatro retos de `despliegue_cero`. El jugador veía la
lista entera antes de hablar con nadie, así que el objetivo se develaba sin trabajo.

Hay una condición previa que condiciona la solución: las **misiones emergentes** están
decididas sin lista ni marcadores (P-11). Lo que P-32 describe es la lista de **retos de la
zona**, que sí es una lista de tareas fija. Por eso el cambio se limita a esa lista y no toca
el sistema de misiones emergentes.

## Decisión

### 1. «Conocido» es un estado aparte de «completado»

`InvestigationDirector` ya tenía `flags`, que marca lo **hecho** (un reto completado, un
resultado del caso). «Conocido» es otra cosa: el jugador se ha enterado de que el reto existe.
Se añadió un diccionario nuevo, `known`, con tres operaciones y una señal:

- `set_known(key)`: marca como conocido y emite `known_changed`.
- `has_known(key)`: consulta.
- `clear_known(key)`: borra (lo usa `DespliegueCeroChallenges._complete()`).

La separación es deliberada: si se reutilizaran los flags, «completado» y «descubierto» se
mezclarían y la lista del chat no podría distinguir un reto pendiente de uno que el jugador
todavía no sabe que existe.

### 2. El tema del chat lo decide la zona

`ZoneBase` gana dos métodos:

- `chat_topic()`: devuelve el objetivo genérico de la zona (`ZONE_OBJECTIVE`). Por defecto, una
  zona sin retos de lista no cambia de comportamiento.
- `discover_challenge()`: no hace nada en la base.

`DespliegueCeroZone` sobrescribe los dos: `chat_topic()` devuelve la lista de los retos
**conocidos y no completados** (con la conjunción «y» para el último, en español), y
`discover_challenge()` marca como conocido el primer reto pendiente que el jugador todavía
desconoce.

Con esto, el comportamiento pedido queda exacto:

- Al empezar, el jugador no ha hablado con nadie: el chat enseña el objetivo genérico.
- Al hablar con un habitante (`LiveDialogue.open()` llama a `discover_challenge()`), aparece el
  primer reto en la lista.
- Cada conversación nueva enseña el siguiente reto aún desconocido.
- Al completar un reto, `_complete()` borra su entrada de `known` y el tema se reconstruye: el
  reto desaparece de la lista.

### 3. El tema se reconstruye sola

`despliegue_cero_interface._build_chat()` conecta `known_changed` y `flags_changed` a
`irc.set_topic(zone.chat_topic())`. No hace falta recomponer la interfaz: el texto del tema se
recalcula en el momento en que cambia el estado.

### 4. `known` se guarda y se recarga

`InvestigationDirector.to_dict()` incluye `"known": known.keys()` y `restore()` lo reconstruye.
Esto no es un detalle menor: sin ello, recargar la partida perdía los retos ya descubiertos y
la lista del chat volvía al objetivo genérico, lo que rompía dos pruebas de la zona
(`test_all_four_without_killing_and_state_survives_reload` y
`test_war_positions_and_mines_persist`).

## Consecuencias y limitaciones

- El patrón es generalizable: cualquier zona con retos de lista solo tiene que sobrescribir
  `chat_topic()` y `discover_challenge()`. Las zonas que hoy no tienen lista (las 24 del mundo,
  la mayoría esqueleto) no cambian de aspecto.
- Solo se descubren retos al **hablar con un habitante**. El caso de «o por las IAs» (que el
  director mencionó) queda por hacer: las IAs que chatteran en el canal no llaman todavía a
  `discover_challenge()`.
- La lista se arma con los retos de `DespliegueCeroChallenges.ALL_CHALLENGES`, en ese orden.
  Cuando el jugador conoce los cuatro, el tema vuelve al objetivo genérico.
- El texto nuevo (`ZONE_OBJECTIVE_PENDING`, `ZONE_RETO_*`) es provisional, como todo el texto
  del juego.
- Falta la **validación manual en partida**: que la lista se lea bien en el chat y que el ritmo
  de descubrimiento (un reto por conversación) sea el que quiere el director.

## Referencias

- P-32 en `docs/01_CONFLICTOS_Y_PENDIENTES.md`.
- Decisiones del director sobre misiones emergentes (P-11) en `docs/02_DECISIONES.md`.
- Implementación: `investigation/investigation_director.gd`,
  `scenes/zones/zone_base.gd`, `scenes/despliegue_cero/despliegue_cero_zone.gd`,
  `scenes/despliegue_cero/despliegue_cero_challenges.gd`,
  `scenes/despliegue_cero/despliegue_cero_interface.gd`, `simulation/live_dialogue.gd`.

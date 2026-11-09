# ADR 0010: mundo vivo dentro de la zona beta (fase 8)

Estado: pendiente de aprobación del director en partida.

## Alcance
Por decisión del director (9-nov), las zonas nuevas, los tres niveles de simulación y el viaje entre puntos de guardado pasan a una etapa post-beta. La fase 8 se hace en la zona beta.

## Estructura
- `simulation/`: lógica sin nodos (`WorldSim` y sus sistemas), probada sin escena. `LiveWorld` la une a la zona.
- La verdad objetiva (`TruthLog`) solo admite añadidos. Cada personaje guarda su propia creencia con procedencia.
- Guardado versión 2, con migración desde la 1: las partidas viejas generan su mundo al cargarse.
- Semilla del mundo derivada de la de la partida, para no alterar la existente.
- Los habitantes son `Guard` pasivos: reutilizan esqueletos, combate y conversión. Identificadores permanentes `npc_000001`.

## Reglas aplicadas de `02_DECISIONES`
Rumores de 4 minutos que se deforman, solo un fragmento entre especies, cadenas de 4 pasos con enfriamiento, misiones sin lista ni marcadores, festividades con rastro al volver, mundo congelado con el juego cerrado y resumen final de cada cadena hasta donde llegó.

## Valores provisionales
Todas las constantes de `simulation/` y los datos de `data/world/`: frecuencias, alcances, población (8 iniciales, objetivo 10, máximo 14 por especie), plazos de misión, relaciones iniciales y textos. Los 36 textos de festividades y los de sucesos y misiones están pendientes de la crítica del director. Origen: Claude, sin servicios externos.

## Medido (Godot 4.7.2, sin ventana, entorno de pruebas)
| Personajes | Física media | Física peor | Paso del mundo | Guardado |
|---|---|---|---|---|
| 27 | 7,1 ms | 16,3 ms | 0,2 ms | 23 KB |
| 46 | 8,1 ms | 18,3 ms | 1,0 ms | 42 KB |
| 60 | 8,8 ms | 15,9 ms | 1,0 ms | 52 KB |

Sin medir: gráfica real.

## Limitaciones
- Los personajes con nombre de la beta siguen con sus diálogos escritos y no entran en el motor social.
- La distancia decide quién es testigo; las paredes no tapan.
- De noche los Jubilados se apagan en pantalla, pero la lógica de rumores no lo tiene en cuenta.
- Solo dos especies; el resto, en la fase 9.

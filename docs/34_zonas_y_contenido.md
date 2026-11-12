> **Prevalece sobre este documento (8-nov):** nacimientos y llegadas pueden ocurrir también en directo, con el jugador presente; lo demás de "sin generación durante la estancia" sigue vigente para objetos y estructuras. La geometría es fija, con estados diseñados de antemano. Con el juego cerrado el mundo se congela. Al regresar a una zona se aplican los cambios de su nivel de simulación.

# Zonas y contenido

2. Principio fundamental: zonas fijas y contenido aleatorio
Esta decisión condiciona toda la arquitectura gráfica.
2.1. Zonas estáticas
Las zonas del videojuego serán escenarios diseñados y construidos previamente.
Una zona tendrá siempre:
* La misma distribución geográfica.
* Los mismos límites.
* Los mismos caminos.
* Los mismos edificios.
* Las mismas estructuras.
* Los mismos obstáculos permanentes.
* Los mismos accesos.
* La misma distribución de terreno.
* Los mismos elementos estructurales.
Una zona no cambiará su geometría entre partidas.
Por ejemplo, una zona puede tener siempre un lago en el centro, una estructura abandonada al norte, un bosque al oeste y una entrada al sur.
Esta distribución será fija.
No generaremos mapas nuevos aleatoriamente en cada partida.
2.2. Contenido aleatorio por partida
Aunque el escenario sea fijo, su contenido podrá cambiar.
Entre partidas podrán variar:
* Personajes.
* Criaturas.
* Individuos de cada especie.
* Grupos de personajes.
* Objetos.
* Elementos interactivos.
* Recursos.
* Organismos ambientales.
* Situaciones y acontecimientos.
* Elementos temporales.
* Anomalías ambientales, cuando corresponda.
La distribución de estos elementos podrá variar dentro de las zonas autorizadas para ello.
Por ejemplo, el lago siempre estará en el mismo sitio, pero podrán aparecer diferentes criaturas en sus alrededores, distintos objetos en sus orillas y diferentes personajes en las proximidades.
2.3. Sin generación durante la estancia en una zona
No habrá generación procedural de contenido mientras el jugador permanezca dentro de una zona.
El comportamiento será:
1. El jugador entra en una zona.
2. El juego comprueba si ya existe una instancia de esa zona para la partida actual.
3. Si no existe, genera su contenido aleatorio utilizando la configuración y la semilla de la partida.
4. Si ya existe, recupera el estado guardado.
5. Durante la estancia, los personajes y objetos pueden comportarse e interactuar, pero no se regeneran nuevos elementos.
6. Al abandonar la zona, se conserva su estado.
7. Al regresar, se recupera exactamente el estado que tenía.
La generación se produce exclusivamente durante las transiciones o cargas de zona.
No debe existir un sistema que esté creando personajes, objetos o estructuras continuamente mientras el jugador juega.
2.4. Persistencia entre visitas
La aleatoriedad debe ser diferente entre partidas, pero coherente dentro de una misma partida.
Para conseguirlo utilizaremos una semilla global de partida y una semilla derivada para cada zona.
Una vez generada una zona, su composición inicial quedará registrada.
Si el jugador sale y vuelve a entrar, no se volverá a sortear su contenido.
Se conservarán:
* Personajes presentes.
* Posiciones.
* Objetos.
* Estados de los objetos.
* Elementos descubiertos.
* Elementos recogidos.
* Personajes fallecidos.
* Situaciones pendientes.
* Cambios producidos por el jugador.
La generación inicial y la simulación posterior serán responsabilidades independientes.
5. Sistema de producción de zonas
Esta es una de las partes más importantes de la arquitectura gráfica.
No construiremos zonas mediante generación procedural del mapa.
Construiremos escenarios previamente diseñados y utilizaremos un sistema de distribución aleatoria para su contenido.
5.1. Diseño fijo del escenario
Cada zona será un escenario previamente construido en Godot.
Contendrá:
* Terreno.
* Caminos.
* Edificios.
* Ruinas.
* Vegetación permanente.
* Obstáculos.
* Elementos arquitectónicos.
* Límites.
* Accesos.
* Zonas transitables.
* Zonas no transitables.
* Elementos de oclusión.
Estos elementos serán iguales en todas las partidas.
Utilizaremos TileMapLayer para terrenos y elementos repetitivos, y escenas independientes para estructuras y objetos complejos.
5.2. Puntos de aparición
Cada zona tendrá puntos o áreas autorizadas para colocar contenido aleatorio.
Por ejemplo:
* Puntos para personajes.
* Áreas para criaturas.
* Puntos para objetos.
* Áreas para vegetación variable.
* Lugares para acontecimientos.
* Zonas de aparición de grupos.
Estos puntos estarán definidos previamente en el escenario.
El generador no podrá colocar contenido en cualquier lugar del mapa.
Deberá respetar:
* Zonas permitidas.
* Distancias mínimas.
* Colisiones.
* Accesibilidad.
* Capacidad de población.
* Reglas de cada especie.
* Compatibilidad con el entorno.
5.3. Generación inicial de contenido
Cuando se visite una zona por primera vez en una partida:
* Se seleccionarán los personajes.
* Se determinarán sus posiciones.
* Se seleccionarán las especies presentes.
* Se distribuirán los objetos.
* Se establecerán los elementos temporales.
* Se inicializarán los acontecimientos correspondientes.
La generación será controlada mediante reglas y parámetros.
No será una distribución completamente aleatoria.
Cada zona tendrá una identidad y unas condiciones propias.
5.4. Reentrada en una zona
Al regresar a una zona ya visitada:
* No se ejecutará una nueva generación.
* Se recuperarán los personajes existentes.
* Se recuperarán las posiciones.
* Se restaurarán los objetos según su estado real.
* Se mantendrán los cambios producidos.
* Se actualizarán los estados que deban evolucionar con el tiempo.
La zona seguirá siendo la misma instancia lógica durante toda la partida.
5.5. Ampliación futura de zonas
El sistema deberá permitir incorporar nuevas zonas sin modificar las existentes.
Cada nueva zona tendrá:
* Diseño estático.
* Identificador único.
* Configuración propia.
* Puntos de aparición.
* Reglas de población.
* Recursos gráficos.
* Accesos y conexiones.
* Condiciones ambientales.
El sistema de generación de contenido será reutilizable.
Añadir una zona nueva no deberá exigir desarrollar un generador específico desde cero.
14. Mapas
Los mapas representarán las zonas fijas del videojuego.
No se generarán mapas diferentes para cada partida.
Podrán cambiar los indicadores de contenido:
* Personajes conocidos.
* Lugares descubiertos.
* Objetos identificados.
* Zonas de interés.
* Acontecimientos registrados.
La estructura geográfica será siempre la misma.
16. Persistencia y semillas aleatorias
El sistema gráfico y de contenido deberá respetar la persistencia de cada partida.
Utilizaremos:
* Una semilla global por partida.
* Una semilla derivada por zona.
* Una configuración de generación por zona.
* Un registro de contenido generado.
* Un registro de cambios de estado.
La semilla permitirá reproducir la composición inicial de una zona si fuera necesario.
Sin embargo, no dependeremos exclusivamente de regenerar el contenido desde la semilla para recuperar una zona visitada.
La fuente de verdad será el estado persistido.
Esto es importante porque los personajes pueden morir, desplazarse, recoger objetos o modificar el entorno.
> **Multi-zona (11-nov):** la infraestructura multi-zona está definida en `docs/adr/0027-multi-zona.md`. Los parámetros de las 24 zonas (nombres, tamaños, formas, conexiones) están en `art/mapa_zonas_propuesta.svg`. Cada zona es un escenario cuadrado con geometría fija en escena y población/objetos desde JSON. Las formas se tallan con `shape_blocks` (rectángulos bloqueados) y los corredores se declaran en `geometry.corridors`.

> **Mapas de zonas:** `art/mapas_zonas/` contiene 24 SVG (uno por zona, 680×520) con la distribución de edificios, vegetación, montañas, ríos y corredores. Son mapas de diseño (blueprints): en Godot el juego real se construye con nodos separados (suelo, paredes, props, fachadas). Los SVG son importables en Godot (sin texto). La leyenda de cada mapa está en `art/mapas_zonas/README.md`.

## Qué se genera y cuándo
| Elemento | Momento |
|---|---|
| Geometría de zonas, caminos, edificios, terrenos y obstáculos | Desarrollo |
| Bibliotecas de personajes y objetos, animaciones | Desarrollo |
| Distribución de personajes, criaturas, objetos variables y grupos | Primera entrada en la zona |
| Anomalías asignadas a una zona | Generación inicial de la zona |
| Efectos visuales, movimiento de personajes, estados de objetos | Durante la partida |
| Recuperación de zonas visitadas | Al regresar |

Clima y anomalías: pueden determinarse al generar la zona o por reglas de la partida, y su aspecto puede evolucionar mientras estás presente.

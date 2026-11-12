> **Prevalece sobre este documento (8-nov):** nacimientos y llegadas pueden ocurrir tambiÃ©n en directo, con el jugador presente; lo demÃ¡s de "sin generaciÃ³n durante la estancia" sigue vigente para objetos y estructuras. La geometrÃ­a es fija, con estados diseÃ±ados de antemano. Con el juego cerrado el mundo se congela. Al regresar a una zona se aplican los cambios de su nivel de simulaciÃ³n.

# Zonas y contenido

2. Principio fundamental: zonas fijas y contenido aleatorio
Esta decisiÃ³n condiciona toda la arquitectura grÃ¡fica.
2.1. Zonas estÃ¡ticas
Las zonas del videojuego serÃ¡n escenarios diseÃ±ados y construidos previamente.
Una zona tendrÃ¡ siempre:
* La misma distribuciÃ³n geogrÃ¡fica.
* Los mismos lÃ­mites.
* Los mismos caminos.
* Los mismos edificios.
* Las mismas estructuras.
* Los mismos obstÃ¡culos permanentes.
* Los mismos accesos.
* La misma distribuciÃ³n de terreno.
* Los mismos elementos estructurales.
Una zona no cambiarÃ¡ su geometrÃ­a entre partidas.
Por ejemplo, una zona puede tener siempre un lago en el centro, una estructura abandonada al norte, un bosque al oeste y una entrada al sur.
Esta distribuciÃ³n serÃ¡ fija.
No generaremos mapas nuevos aleatoriamente en cada partida.
2.2. Contenido aleatorio por partida
Aunque el escenario sea fijo, su contenido podrÃ¡ cambiar.
Entre partidas podrÃ¡n variar:
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
* AnomalÃ­as ambientales, cuando corresponda.
La distribuciÃ³n de estos elementos podrÃ¡ variar dentro de las zonas autorizadas para ello.
Por ejemplo, el lago siempre estarÃ¡ en el mismo sitio, pero podrÃ¡n aparecer diferentes criaturas en sus alrededores, distintos objetos en sus orillas y diferentes personajes en las proximidades.
2.3. Sin generaciÃ³n durante la estancia en una zona
No habrÃ¡ generaciÃ³n procedural de contenido mientras el jugador permanezca dentro de una zona.
El comportamiento serÃ¡:
1. El jugador entra en una zona.
2. El juego comprueba si ya existe una instancia de esa zona para la partida actual.
3. Si no existe, genera su contenido aleatorio utilizando la configuraciÃ³n y la semilla de la partida.
4. Si ya existe, recupera el estado guardado.
5. Durante la estancia, los personajes y objetos pueden comportarse e interactuar, pero no se regeneran nuevos elementos.
6. Al abandonar la zona, se conserva su estado.
7. Al regresar, se recupera exactamente el estado que tenÃ­a.
La generaciÃ³n se produce exclusivamente durante las transiciones o cargas de zona.
No debe existir un sistema que estÃ© creando personajes, objetos o estructuras continuamente mientras el jugador juega.
2.4. Persistencia entre visitas
La aleatoriedad debe ser diferente entre partidas, pero coherente dentro de una misma partida.
Para conseguirlo utilizaremos una semilla global de partida y una semilla derivada para cada zona.
Una vez generada una zona, su composiciÃ³n inicial quedarÃ¡ registrada.
Si el jugador sale y vuelve a entrar, no se volverÃ¡ a sortear su contenido.
Se conservarÃ¡n:
* Personajes presentes.
* Posiciones.
* Objetos.
* Estados de los objetos.
* Elementos descubiertos.
* Elementos recogidos.
* Personajes fallecidos.
* Situaciones pendientes.
* Cambios producidos por el jugador.
La generaciÃ³n inicial y la simulaciÃ³n posterior serÃ¡n responsabilidades independientes.
5. Sistema de producciÃ³n de zonas
Esta es una de las partes mÃ¡s importantes de la arquitectura grÃ¡fica.
No construiremos zonas mediante generaciÃ³n procedural del mapa.
Construiremos escenarios previamente diseÃ±ados y utilizaremos un sistema de distribuciÃ³n aleatoria para su contenido.
5.1. DiseÃ±o fijo del escenario
Cada zona serÃ¡ un escenario previamente construido en Godot.
ContendrÃ¡:
* Terreno.
* Caminos.
* Edificios.
* Ruinas.
* VegetaciÃ³n permanente.
* ObstÃ¡culos.
* Elementos arquitectÃ³nicos.
* LÃ­mites.
* Accesos.
* Zonas transitables.
* Zonas no transitables.
* Elementos de oclusiÃ³n.
Estos elementos serÃ¡n iguales en todas las partidas.
Utilizaremos TileMapLayer para terrenos y elementos repetitivos, y escenas independientes para estructuras y objetos complejos.
5.2. Puntos de apariciÃ³n
Cada zona tendrÃ¡ puntos o Ã¡reas autorizadas para colocar contenido aleatorio.
Por ejemplo:
* Puntos para personajes.
* Ãreas para criaturas.
* Puntos para objetos.
* Ãreas para vegetaciÃ³n variable.
* Lugares para acontecimientos.
* Zonas de apariciÃ³n de grupos.
Estos puntos estarÃ¡n definidos previamente en el escenario.
El generador no podrÃ¡ colocar contenido en cualquier lugar del mapa.
DeberÃ¡ respetar:
* Zonas permitidas.
* Distancias mÃ­nimas.
* Colisiones.
* Accesibilidad.
* Capacidad de poblaciÃ³n.
* Reglas de cada especie.
* Compatibilidad con el entorno.
5.3. GeneraciÃ³n inicial de contenido
Cuando se visite una zona por primera vez en una partida:
* Se seleccionarÃ¡n los personajes.
* Se determinarÃ¡n sus posiciones.
* Se seleccionarÃ¡n las especies presentes.
* Se distribuirÃ¡n los objetos.
* Se establecerÃ¡n los elementos temporales.
* Se inicializarÃ¡n los acontecimientos correspondientes.
La generaciÃ³n serÃ¡ controlada mediante reglas y parÃ¡metros.
No serÃ¡ una distribuciÃ³n completamente aleatoria.
Cada zona tendrÃ¡ una identidad y unas condiciones propias.
5.4. Reentrada en una zona
Al regresar a una zona ya visitada:
* No se ejecutarÃ¡ una nueva generaciÃ³n.
* Se recuperarÃ¡n los personajes existentes.
* Se recuperarÃ¡n las posiciones.
* Se restaurarÃ¡n los objetos segÃºn su estado real.
* Se mantendrÃ¡n los cambios producidos.
* Se actualizarÃ¡n los estados que deban evolucionar con el tiempo.
La zona seguirÃ¡ siendo la misma instancia lÃ³gica durante toda la partida.
5.5. AmpliaciÃ³n futura de zonas
El sistema deberÃ¡ permitir incorporar nuevas zonas sin modificar las existentes.
Cada nueva zona tendrÃ¡:
* DiseÃ±o estÃ¡tico.
* Identificador Ãºnico.
* ConfiguraciÃ³n propia.
* Puntos de apariciÃ³n.
* Reglas de poblaciÃ³n.
* Recursos grÃ¡ficos.
* Accesos y conexiones.
* Condiciones ambientales.
El sistema de generaciÃ³n de contenido serÃ¡ reutilizable.
AÃ±adir una zona nueva no deberÃ¡ exigir desarrollar un generador especÃ­fico desde cero.
14. Mapas
Los mapas representarÃ¡n las zonas fijas del videojuego.
No se generarÃ¡n mapas diferentes para cada partida.
PodrÃ¡n cambiar los indicadores de contenido:
* Personajes conocidos.
* Lugares descubiertos.
* Objetos identificados.
* Zonas de interÃ©s.
* Acontecimientos registrados.
La estructura geogrÃ¡fica serÃ¡ siempre la misma.
16. Persistencia y semillas aleatorias
El sistema grÃ¡fico y de contenido deberÃ¡ respetar la persistencia de cada partida.
Utilizaremos:
* Una semilla global por partida.
* Una semilla derivada por zona.
* Una configuraciÃ³n de generaciÃ³n por zona.
* Un registro de contenido generado.
* Un registro de cambios de estado.
La semilla permitirÃ¡ reproducir la composiciÃ³n inicial de una zona si fuera necesario.
Sin embargo, no dependeremos exclusivamente de regenerar el contenido desde la semilla para recuperar una zona visitada.
La fuente de verdad serÃ¡ el estado persistido.
Esto es importante porque los personajes pueden morir, desplazarse, recoger objetos o modificar el entorno.
> **Multi-zona (11-nov):** la infraestructura multi-zona estÃ¡ definida en `docs/adr/0027-multi-zona.md`. Los parÃ¡metros de las 24 zonas (nombres, tamaÃ±os, formas, conexiones) estÃ¡n en `art/mapa_zonas_propuesta.svg`. Cada zona es un escenario cuadrado con geometrÃ­a fija en escena y poblaciÃ³n/objetos desde JSON. Las formas se tallan con `shape_blocks` (rectÃ¡ngulos bloqueados) y los corredores se declaran en `geometry.corridors`.

> **Mapas de zonas:** `art/mapas_zonas/` contiene 24 SVG (uno por zona, 680Ã520) con la distribuciÃ³n de edificios, vegetaciÃ³n, montaÃ±as, rÃ­os y corredores. Son mapas de diseÃ±o (blueprints): en Godot el juego real se construye con nodos separados (suelo, paredes, props, fachadas). Los SVG son importables en Godot (sin texto). La leyenda de cada mapa estÃ¡ en `art/mapas_zonas/README.md`.

## QuÃ© se genera y cuÃ¡ndo
| Elemento | Momento |
|---|---|
| GeometrÃ­a de zonas, caminos, edificios, terrenos y obstÃ¡culos | Desarrollo |
| Bibliotecas de personajes y objetos, animaciones | Desarrollo |
| DistribuciÃ³n de personajes, criaturas, objetos variables y grupos | Primera entrada en la zona |
| AnomalÃ­as asignadas a una zona | GeneraciÃ³n inicial de la zona |
| Efectos visuales, movimiento de personajes, estados de objetos | Durante la partida |
| RecuperaciÃ³n de zonas visitadas | Al regresar |

Clima y anomalÃ­as: pueden determinarse al generar la zona o por reglas de la partida, y su aspecto puede evolucionar mientras estÃ¡s presente.

---

## Estado de las zonas (fase contenido-zonas, 12-nov-2026)

### Zonas jugables (mundo vivo completo)

| Zona | Especies | Población | Contenido | Estado |
|---|---|---|---|---|
| beta (Despliegue Cero) | jubilado, mohocrata | 18/20/26 | Completo (beta propia) | Jugable |
| el_enchufe | jubilado, mohocrata | 8/10/14 | Completo (items, convertibles, props, actors) | Jugable |
| lonja | jubilado, grux | 8/10/14 | Completo (items, convertibles, props, actors) | Jugable |

### Zonas pobladas (especies implementadas)

| Zona | Especies | Población |
|---|---|---|
| archivo | jubilado, plegado | 8/10/14 |
| asamblea | mohocrata, plegado | 8/10/14 |
| atajo | manada, mohocrata | 8/10/14 |
| cementerio | grux, jubilado, manada | 6/8/12 |
| colmena | eco, mohocrata | 8/10/14 |
| cumbre | plegado | 10/12/16 |
| desguace | jubilado, manada | 8/10/14 |
| encrucijada | eco, grux, jubilado, plegado | 5/7/10 |
| gran_cruce | eco, grux, jubilado, plegado | 5/7/10 |
| gran_mercado | grux, manada, mohocrata | 6/8/12 |
| paso | jubilado, mohocrata | 8/10/14 |
| poligono | jubilado, manada | 8/10/14 |
| taller | jubilado, mohocrata | 8/10/14 |

### Zonas con solo especies planificadas (sin población real)

| Zona | Especies planificadas |
|---|---|
| antecamara | eco, plegado |
| camara | eco, manada |
| camino | grux, plegado |
| canon | eco, grux |
| instalacion | eco, plegado |
| sendero | manada, plegado |
| ultima_ruta | grux, manada |
| valle | eco, grux, plegado |

### Especies implementadas

| Especie | Color | Material | Sprite |
|---|---|---|---|
| jubilado | #a0a8b8 | nanoacero | jubilado_hierro |
| mohocrata | #8fbf60 | bioceramica | mohocrata |
| plegado | #c8b8e8 | fibra_fotonica | plegado |
| eco | #8fdbd8 | cristal_plasma | eco |
| grux | #d8985a | restos | grux |
| manada | #a8c860 | gel_memoria | manada |

### Pruebas de contenido

- 	ests/zones/content_test.gd: 7 pruebas nuevas
- Total zonas: 35 pruebas, todas pasan

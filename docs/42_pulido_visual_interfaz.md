# Fase 7b: pulido visual e interfaz

Va antes de la fase 8. Empieza cuando el arte de `main` se haya ejecutado en Godot y pasen las pruebas. Aprobada por el director el 9-nov.

## Alcance decidido el 9-nov
La 7b se limita a los cuatro puntos del primer minuto. El resto de las tablas pasa a la fase 9. Al terminarlos se fusiona y se sigue con la fase 8.

## Avance
Hechos en la rama `fase-7b-resto`, pendientes de aprobación en partida (`adr/0009-pulido-primer-minuto.md`): esqueleto de las 3 vistas de Jubilado, Mohócrata y Don Ramón, sensación de impacto, escena de convertir y silueta del cuerpo. El dron sigue con imagen fija.

## Fase 9 (9-nov)
Hecho: grano, viñeta y brillo en los neones, neones que parpadean, flecha de detección fuera de vista, aviso de ruido en los bordes, pausa táctica clara con lo que amenaza marcado, botones con tema común, efectos de texto por IA y opciones básicas.

Sin hacer: óxido y metal disuelto en las piezas, charcos con ondas, copas de árbol a otra velocidad, cables y plantas que se mecen, moscas, humo, cono que cambia según la sospecha y tipografía gamberra, que necesitaría una fuente con licencia.

## Cierre de la beta (9-nov)
Hecho: óxido según desgaste y burbujeo con lluvia ácida, charcos con ondas, copas de árbol a otra velocidad, cables y plantas que se mecen, moscas, humo y borde del cono según la sospecha. Tipografía gamberra: Bangers, aprobada por el director el 9-nov, en títulos, carteles y paneles.

## Orden de trabajo
Primero lo que se nota en el primer minuto de partida:
1. Animación de enemigos.
2. Sensación de impacto.
3. Escena de convertir.
4. Silueta del cuerpo.

Después, el resto de esta lista.

## Estilo visual
| Elemento | Qué incluye |
|---|---|
| Animación de personajes | Andar, reaccionar al ver al jugador y caer, con `AnimationPlayer` y huesos |
| Sensación de impacto | Temblor de cámara, destello blanco, pausa de milésimas y deformación al aterrizar o recibir un golpe |
| Acabado común de pantalla | Shader final con grano, viñeta y brillo en los neones |
| Shaders de material | Contorno de color en lo convertible, óxido que avanza con el desgaste, metal que se disuelve con la lluvia ácida y charcos con ondas |
| Profundidad en el mapa | Copas de árbol a otra velocidad, sombras que tapan a los personajes y luces con sombra real |
| Mundo vivo de fondo | Cables y plantas que se mecen, moscas, humo y neones que parpadean |

## Interfaz
| Elemento | Qué incluye |
|---|---|
| Cuerpo como interfaz principal | Silueta del protagonista con el desgaste de cada pieza, sin barras |
| Cola como indicador | Que baste para saber qué IA habla |
| Convertir con espectáculo | Tiempo parado, fondo oscurecido, objeto destacado, temporizador agresivo y una IA burlándose |
| Lectura del sigilo | Cono que cambia según la sospecha, aviso de ruido en los bordes y flecha si te detectan fuera de vista |
| Pausa táctica clara | Mundo desaturado, y en color solo lo usable y lo que amenaza |
| Tema unificado | `Theme` de Godot, tipografía gamberra, paneles de chapa torcida y transiciones de menú |
| Texto de personaje | Efectos de `RichTextLabel` por IA: temblor, tartamudeo o escritura impecable |
| Opciones básicas | Tamaño de texto, reducir temblores y destellos, y alto contraste para los neones |

## Comprobación técnica previa
El proyecto usa el renderizador Compatibility, con efectos más limitados en brillo y postproceso. Hay que comprobar qué permite en la 4.7. Como el juego es solo para PC, se puede estudiar otro renderizador, midiendo antes en el ordenador del director.

## Criterio de aceptación
El director lo aprueba en partida, el rendimiento no empeora de forma apreciable y las opciones de accesibilidad funcionan.

# Conflictos y pendientes

Nada de esto debe resolverse por suposición. `Bloquea` indica desde qué fase del plan hace falta la respuesta.

Los 13 conflictos entre documentos quedaron resueltos el 8 de noviembre: ver `02_DECISIONES.md`.

## Información que falta
| ID | Qué falta | Por qué importa | Bloquea |
|---|---|---|---|
| P-02 | **Implementado en `cierre-beta`, todo provisional.** Falta tu revisión jugando (`borradores/P-02_compatibilidades.md`, `adr/0014-cierre-beta.md`) | Resto de la conversión | Revisión de la beta |
| P-05 | **Hecho en la fase 9, con valores provisionales** (`adr/0011-ias-y-controles.md`). Falta ajustarlos jugando | Sistema de IAs | Fase 9 |
| P-09 | **En curso: Claude escribe, el director critica.** Lotes 1 y 2 aprobados e integrados: 76 preguntas, motes y comentarios del protagonista (`docs/adr/0007-motes-y-comentarios.md`). Pueden añadirse más lotes; quedan 12 preguntas reservadas para las otras cuatro razas | Humor y conversión | Fase 4 |
| P-23 | **Idea del director para después de la beta (9-nov).** Muchos tipos de objetos extraños y graciosos convertibles en el mundo, y muchos tipos de edificios, muchos en ruinas, con tipos imaginarios e ideas gamberras | Mundo y contenido | Post-beta |
| P-25 | **Pedido por el director para después de la beta (9-nov).** Animación propia, con su fotograma especial, para cada arma y acción. Peleas contra grupos con variantes: te rodean, se ponen en fila de uno en uno, forman triángulo o círculo para atacar, y otras ocurrencias graciosas. Hoy solo hay andar, quieto, alerta y caer, y rastro de los disparos | Combate y arte | Post-beta |
| P-26 | **Idea del director para después de la beta (9-nov).** Las IAs en modo fantasma también en la vista de convertir y en cualquier vista que pare el juego, igual que en la pausa táctica | Interfaz | Post-beta |
| P-27 | **Idea del director para después de la beta (9-nov).** Muertes de NPC bestias: salen volando y aterrizan cerca, a veces se acercan a la cámara, explotan o lloran llamando a su mamá. Claude inventa 100 posibilidades aleatorias según la especie | Combate, arte y humor | Post-beta |
| P-28 | **Pedido por el director para después de la beta (9-nov).** Efectos de texto en el chat de las IAs con `RichTextEffect`: cada IA escribe según su personalidad (la tartamuda con letras que tiemblan y se repiten, la enamorada con letras que laten, la enfadada con texto que vibra, la que se queda sin tokens con caracteres corruptos) | Interfaz y humor | Post-beta |
| P-29 | **Pedido por el director para después de la beta (9-nov).** Sonido con posición (`AudioStreamPlayer2D`) y efectos de audio. Oír de dónde viene un guardia y si está tras una pared, como información de sigilo; timbre propio de cada IA (radio rota, eco, distorsión) sin generar más voces. Requiere añadir sonidos a los personajes, como los pasos | Audio y sigilo | Post-beta |
| P-30 | **Pedido por el director para después de la beta (9-nov).** Repartir el cálculo del mundo vivo entre núcleos con `WorkerThreadPool`, para evitar tirones con los tres niveles de simulación del mundo completo. Hacerlo solo cuando haga falta: complica el código y puede meter fallos difíciles de reproducir | Rendimiento y mundo | Post-beta |

## Resueltos en la revisión de código
P-24: ver `adr/0016-revision-codigo.md`.

## Resueltos en `cierre-beta`
P-20 (controles), P-21 (chat de 4 mensajes) y P-22 (36 habitantes más 7 con nombre): ver `adr/0014-cierre-beta.md`.

## Resueltos en la fase 9
P-19: chapa con F1 y ventana de controles arriba a la izquierda (`adr/0011-ias-y-controles.md`).

## Resueltos en la fase 7
P-01 (mapa y progenitores de la beta) y P-08 (retos y soluciones): ver `41_beta.md` y `02_DECISIONES.md`. P-04, P-10, P-11, P-13, P-14, P-15, P-16, P-17 y P-18: ver `02_DECISIONES.md`.

## Contradicciones ya resueltas
Plataforma, controles, perspectiva, núcleo del juego, guardado, conversión, condiciones de muerte y capas de misiones: por decisiones del 8-nov. Niveles de simulación (dos en *Sistemas*, tres en el Registro, cuatro en *Motor de conversaciones*): rigen los tres del Registro, y los cuatro niveles de actividad son un detalle interno del motor social. Las razas y las IAs aparecían como "por definir" en el PDF, pero el propio documento las define.

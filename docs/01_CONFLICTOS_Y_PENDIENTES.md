# Conflictos y pendientes

Nada de esto debe resolverse por suposición. `Bloquea` indica desde qué fase del plan hace falta la respuesta.

Los 13 conflictos entre documentos quedaron resueltos el 8 de noviembre: ver `02_DECISIONES.md`.

## Información que falta
| ID | Qué falta | Por qué importa | Bloquea |
|---|---|---|---|
| P-02 | **Implementado en `cierre-beta`, todo provisional.** Falta tu revisión jugando (`borradores/P-02_compatibilidades.md`, `adr/0014-cierre-beta.md`) | Resto de la conversión | Revisión de la beta |
| P-05 | **Hecho en la fase 9, con valores provisionales** (`adr/0011-ias-y-controles.md`). Falta ajustarlos jugando | Sistema de IAs | Fase 9 |
| P-09 | **En curso: Claude escribe, el director critica.** Lotes 1 y 2 aprobados e integrados: 76 preguntas, motes y comentarios del protagonista (`docs/adr/0007-motes-y-comentarios.md`). Pueden añadirse más lotes; quedan 12 preguntas reservadas para las otras cuatro razas | Humor y conversión | Fase 4 |
| P-26 | **Idea del director para después de la beta (9-nov).** Las IAs en modo fantasma también en la vista de convertir y en cualquier vista que pare el juego, igual que en la pausa táctica | Interfaz | Post-beta |
| P-28 | **Pedido por el director para después de la beta (9-nov).** Efectos de texto en el chat de las IAs con `RichTextEffect`: cada IA escribe según su personalidad (la tartamuda con letras que tiemblan y se repiten, la enamorada con letras que laten, la enfadada con texto que vibra, la que se queda sin tokens con caracteres corruptos) | Interfaz y humor | Post-beta |
| P-29 | **Pedido por el director para después de la beta (9-nov).** Sonido con posición (`AudioStreamPlayer2D`) y efectos de audio. Oír de dónde viene un guardia y si está tras una pared, como información de sigilo; timbre propio de cada IA (radio rota, eco, distorsión) sin generar más voces. Requiere añadir sonidos a los personajes, como los pasos | Audio y sigilo | Post-beta |
| P-30 | **Pedido por el director para después de la beta (9-nov).** Repartir el cálculo del mundo vivo entre núcleos con `WorkerThreadPool`, para evitar tirones con los tres niveles de simulación del mundo completo. Hacerlo solo cuando haga falta: complica el código y puede meter fallos difíciles de reproducir | Rendimiento y mundo | Post-beta |
| P-31 | **Pedido por el director para después de la beta (9-nov).** La vista de estrategia debe enseñar la ciudad con sus edificios; hoy solo se ve suelo | Interfaz y arte | Post-beta |
| P-32 | **Pedido por el director para después de la beta (9-nov).** Las misiones de la zona solo aparecen en la lista del chat si se ha recibido información de ellas, hablando con alguien o por las IAs, y se quitan al completarlas. Hoy la lista del tema del canal sale completa desde el principio. A aclarar: las misiones emergentes están decididas sin lista ni marcadores (P-11), así que esto se aplica a los retos de la zona salvo que el director diga otra cosa | Interfaz y misiones | Post-beta |
| P-33 | **Pedido por el director para después de la beta (9-nov).** El chat hace algo muy visible cada vez que una IA escribe. Qué efecto, por definir; respetar la opción de reducir destellos y temblores | Interfaz | Post-beta |

## Decidido el 10 de noviembre
Decisiones del director del 10-nov. Faltan por implementar, salvo la de IRCap, ya hecha salvo la revisión estética.

| ID | Decisión | Falta | Bloquea |
|---|---|---|---|
| P-14 | **Decidido el 10-nov.** Límite duro al reparto de un rumor: tope de personajes que cruzan el mapa por un rumor, por zona y tiempo; el resto se entera con retraso. Complementa la decisión de la fase 7; los valores serán provisionales | Reparto de rumores | Post-beta |
| P-23 | **Decidido el 10-nov.** Catálogos de objetos graciosos convertibles propuestos por OpenCode en lotes; el director tacha o aprueba, igual que en P-09 | Implementar en la post-beta | Post-beta |
| P-25 | **Decidido el 10-nov.** Animación por arma y acción con fotogramas dibujados y optimizados para Godot, dentro del atlas SVG→PNG del pipeline actual (`36_pipeline_graficos.md`). Las plantillas de piezas las genera OpenCode | Implementar en la post-beta | Post-beta |
| P-27 | **Decidido el 10-nov.** Son «muertes bestiales» exageradas, gamberras y chocantes (no «muertes de bestias»). Catálogo por lotes, revisado y aprobado por el director, como en P-09 | Implementar en la post-beta | Post-beta |
| P-34 | **Decidido el 10-nov.** El duelo (pena y alegría junto a los muertos) dura unos 20 segundos reales, suficiente para verlo al pasar cerca | Implementar en la post-beta | Post-beta |
| P-35 | **Decidido el 10-nov.** Al agotarse las repeticiones de una pregunta, la pregunta desaparece; si se insiste por otra vía, enfado (y pelea si sigue) | Implementar en la post-beta | Post-beta |
| — | **Decidido el 10-nov.** Jubilados que no se defienden de noche: huyen sin devolver golpes, intentan huir o esconderse, nunca atacan de noche. Confirma lo observado en las pruebas finales | Implementar, provisional hasta jugar | Post-beta |
| — | **Decidido el 10-nov.** IRCap es el plugin Ircap del programa mIRC. Los cambios ya hechos gustan al director; queda una fase de revisión estética para acercarlo más al resultado deseado | Fase de revisión estética | Post-beta |
| — | **Decidido el 10-nov.** Viaje rápido: además de los puntos pisados, se puede viajar a puntos oídos por rumores. Durante la carga de la zona nueva se muestran las IAs «fantasma», como en la pausa táctica (P-26). Queda por definir si el tiempo del mundo avanza durante el viaje | Definir el tiempo del mundo | Post-beta |
| — | **Decidido el 10-nov.** Tamaño de personajes: NPCs de tamaño variable entre el 30 % y el 80 %, para simular adultos y niños. Sustituye el 50 % uniforme actual (provisional) | Implementar, revisar jugando | Post-beta |
| — | **Decidido el 10-nov.** Orden de la post-beta: primero infraestructura (gestor multi-zona, tres niveles de simulación, viaje entre puntos de guardado) y luego contenido. El mapa del mundo del director es prerrequisito | Fijar la fase tras las pruebas finales | Post-beta |

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

# Lotes propuestos: objetos convertibles, muertes bestiales, preguntas/motes/comentarios

Provisional, para tacha del director. Estilo P-09: humor ofensivo con el protagonista y las máquinas, sin ataques a colectivos reales.

## P-23: objetos graciosos convertibles (lote 1)

- Lata de sopa "Sopa de robots" → pieza metálica.
- Calcetín con agujero → pieza textil.
- Llave inglesa oxidada → pieza metálica.
- Cepillo de dientes de madera → pieza orgánica.
- Espejo roto → pieza de vidrio.
- Muelle de colchón → pieza metálica.
- Tapón de corcho → pieza orgánica.
- Antena de radio → pieza metálica.
- Peluca de jubilado → pieza textil.
- Diente postizo → pieza orgánica.

## P-27: muertes bestiales

### Lote 1 (borrador inicial, sustituido)
- Explota en mil pedazos y deja un charco verde.
- Se desmonta como muñeco de trapo y se queda colgado de un árbol. *(descartada: no hay árboles como escenario)*
- Se derrite lentamente dejando solo los ojos flotando.
- Sale disparado como cohete y desaparece en el horizonte.
- Se convierte en estatua de sal y se deshace con la lluvia. *(descartada: no hay lluvia)*
- Se parte por la mitad y las dos mitades siguen andando cada una por su lado.
- Se hincha como globo y revienta en confeti.
- Se queda congelado en una pose ridícula y se cae en pedazos.

### Lote 2 — **aprobado por el director (16-nov-2026)**
Infraestructura ya existente: `core/data/death_catalog.gd` (`pick` con semilla, sin gastar RNG si hay una sola), `data/combat/deaths.json` (solo `caida`), `species.json` con `deaths` por especie y `guard_impacts.gd`/`guard_visual.gd` consumiendo los campos. La caída física reutiliza la animación `caer`; lo gamberro va en un efecto de desaparición dibujado encima (`DeathFx`).

**Genéricas (cualquier especie)**
| id | Muerte | Efecto |
|---|---|---|
| `trozos` | Explota en pedazos y deja un charco del color de su material. |
| `cohete` | Sale disparado, deja estela de humo y desaparece en el horizonte. |
| `confeti` | Se hincha como globo y revienta en confeti de colores. |
| `congelado` | Queda en pose ridícula, se cuartea y se cae en pedazos. |
| `estatua` | Se convierte en estatua y se desmorona en polvo. |
| `muelle` | Se le sale un muelle por la espalda y rebota por la zona. |

**Una propia por especie**
| Especie | id | Gracia |
|---|---|---|
| Jubilado | `apagon` | Se apaga como televisión vieja: línea blanca, fundido, olor a naftalina. |
| Mohócrata | `oxidacion` | Se oxida en dos segundos y queda un montoncito de polvo rojizo. |
| Plegado | `origami` | Se pliega en silencio hasta ser una hoja de papel que se lleva el viento. |
| Eco | `burbujas` | Se rompe en ondas y va repitiendo su propio «¡ay!» hasta apagarse. |
| Grux | `prensa` | Se comprime en un cubo de chatarra con forma de dado. |
| Manada | `dispersion` | Se parte en varias siluetas que salen corriendo a la derecha. |

**Reparto:** 6 genéricas + 1 propia por especie. Implementación prevista para la siguiente conversación/fase (rama nueva, ADR, pruebas en `tests/combat/deaths_test.gd` con semilla 1234).

## P-09: preguntas/motes/comentarios (lote 3, 12 reservadas otras razas)

- "¿Por qué los robots nunca se jubilan? Porque no tienen pensión."
- "¿Cuántos mohócratas hacen falta para cambiar una bombilla? Ninguno, se quedan mirando."
- Mote: "Chatarra con patas".
- Mote: "El que huele a aceite".
- Comentario: "Otro que se cree protagonista."
- Comentario: "Vuelve cuando tengas piernas."
- Pregunta: "¿Es verdad que los jubilados se apagan por la noche?" (verifica)
- Pregunta: "¿Los mohócratas comen chatarra?" (verifica)
- Comentario: "No te acerques a los jubilados de noche, que muerden."
- Mote: "El desguace andante".
- Comentario: "Ya viene el experimento fallido."
- Pregunta: "¿Don Ramón arregla cosas o las rompe?" (verifica)

Pendiente revisión del director: tachar o aprobar cada entrada.

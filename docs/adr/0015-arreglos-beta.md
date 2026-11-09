# ADR 0015: arreglos tras probar la beta

Estado: aprobado por el director el 9-nov.

## Vista de piezas
La pieza puesta lleva halo amarillo, fondo más claro y pestaña «PUESTA», separada de los repuestos, que se atenúan. El marco sigue indicando el nivel. Los repuestos se iluminan al pasar el ratón.

## Rendimiento
Medido con `tools/medir_por_partes.gd`, en la zona real con 43 personajes, apagando cada parte (ventana con gráfica software llvmpipe: valen las proporciones, no los valores; física sin ventana).

| Caso | Antes | Después |
|---|---|---|
| Fotograma de día | 188 ms | 134 ms |
| Fotograma de noche | 302 ms | 140 ms |
| Física | 7,2 ms | 2,3 ms |

Coste medido antes de optimizar: filtro de pantalla 69 ms; luces de noche 110 ms; conos 15 ms de fotograma y unos 5 ms de física; animaciones dentro del ruido de medida (unos ±10 ms). Con 59 personajes la física se queda en 2,3 ms sin ventana.

Cambios:
- El filtro solo calcula la niebla durante la pausa táctica.
- Las farolas son halos sumados (`Sprite2D`) en vez de `PointLight2D`. Aspecto casi igual; intensidad provisional.
- No se calculan conos de quienes no los enseñan (habitantes pasivos) ni los de fuera de pantalla. La detección no cambia.
- Fuera de pantalla no se anima a los personajes ni se redibujan.

Sin medir en una gráfica real: el director puede lanzar la misma herramienta en su ordenador.

## Pelea con habitantes (aprobado el 9-nov: A, B, C y D)
- **A.** Clic izquierdo y derecho usan el mismo selector: la persona más cercana al clic, con el cuerpo entero, cabeza incluida. Un habitante ya alerta se ataca con clic derecho sin seleccionarlo.
- **B.** Al seleccionar aparece «Clic derecho: atacar».
- **C.** En la conversación, tras insultar, «Insultar» pasa a ser «Pegarle» (teclas 1-6). También se ofrece cuando el habitante se niega a hablar. Cierra la charla y ataca.
- **D.** Al golpear a un habitante, los de su especie a 250 o menos (provisional) se unen a la pelea. Quien esté en una batalla no se distrae.
- Los que persiguen cuerpo a cuerpo buscan un hueco a 34 del jugador (provisional) para no apilarse en un punto. No son formaciones: eso sigue en P-25.

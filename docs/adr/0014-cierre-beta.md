# ADR 0014: cierre de la beta

Estado: pendiente de aprobación del director.

## Población (P-22)
36 habitantes más 7 personajes con nombre o de patrulla: 43 a la vez, y hasta 59 con el máximo. Medido sin ventana (CPU, 300 muestras, `tools/medir_rendimiento.gd`):

| Caso | Personajes | Física media | Física p99 | Proceso medio | Proceso p99 |
|---|---|---|---|---|---|
| Normal | 23 (antes) | 3,66 ms | 3,77 ms | 0,91 ms | 1,28 ms |
| Normal | 43 | 4,66 ms | 5,41 ms | 0,72 ms | 0,75 ms |
| Batalla | 43 | 5,18 ms | 5,42 ms | 1,90 ms | 2,01 ms |
| Normal | 59 | 4,83 ms | 5,76 ms | 1,06 ms | 1,10 ms |
| Pausa | 59 | 0,03 ms | 0,03 ms | 6,81 ms | 9,28 ms |
| Batalla | 59 | 5,86 ms | 6,45 ms | 1,99 ms | 2,32 ms |

Sin medir el dibujo en una gráfica real.

## Catálogo (P-02)
9 materiales, 14 objetivos con sus zonas del cuerpo, 50 propiedades y 104 acciones en `data/conversion/catalog.json`. Las acciones activas se describen con datos (`do`) y las pasivas con efectos (`fx`). Todo provisional.

Lo que en la beta no puede ser literal se ha simplificado, y la descripción de la pieza dice lo que hace de verdad:
- No hay saltos, techos ni rendijas: esas acciones saltan por encima de coberturas bajas (nunca atraviesan paredes) o esconden un rato.
- No hay animales, fuego, líquidos, Grux ni Manada: se sustituyen por marcar enemigos, aguante o señuelos.
- «Caminar con las manos» no evita la muerte sin piernas, que es una decisión vigente: solo acelera con una pierna.
- Materiales: Jubilados y robots nanoacero, Mohócratas biocerámica, minas antimateria, antenas fibra fotónica, cajas madera, cajas rotas restos, Contestador gel de memoria con propiedad fija.

## Narcisa 9 y Lumi
Con Narcisa activa los disfraces duran un 60 % más y engañan mejor. Lumi deja un corrillo de seguidores visible 9 s que hace ruido.

## Pendientes de la beta
- Don Ramón suelda una pieza de Defensa al contarte la verdad, una sola vez.
- Don Ramón y El Contestador, al morir, dejan un rastro guardado y un suceso del que se habla. Los demás personajes con nombre no pueden morir hoy.
- Consecuencias al salir de la zona: no se pueden hacer sin zonas nuevas, porque no hay salida. Cerrar y volver ya conserva el estado.

## Recursos
`art/beta/props/antena.svg`: escrito a mano por Claude, 9-nov, sin herramientas externas.

## Recorrido real
`tools/recorrido_beta.gd` juega con enemigos activos, sin teletransporte ni pegar a nadie (variables RUTA, SEMILLA y FECHA).

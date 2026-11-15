# ADR 0017: optimización en gráfica integrada

Estado: aprobado por el director el 9-nov.

## Problema
El juego va lento en una Intel HD 520 a 1920x1080. La causa medida en P-24 son las muchas figuras sueltas por fotograma.

## Cambios sin alterar el aspecto
| Qué | Cómo |
|---|---|
| Protagonista | Una malla por pieza (`PolyBatch`), en caché por vista, variante y desgaste. Conserva zancada y piezas intercambiables |
| Silueta del HUD | Una sola malla, rehecha solo cuando cambia |
| Paredes | Una malla por pared, hecha una vez |
| Grietas, líneas, cráteres y charcos del suelo | Dos mallas |
| Personajes con huesos | Piezas en una hoja única (`PieceAtlas`), con la sombra incluida. Se mantiene `AnimationPlayer` |
| Destello de golpe | El material solo existe mientras dura: con material propio no se agrupan |

Se usan mallas en vez de texturas para el protagonista: mismo objetivo, sin 1.700 combinaciones de imágenes ni pérdida de nitidez con el zoom. Para los personajes se hornean las piezas y no los fotogramas, para conservar transiciones y animación continua.

## Cambios pedidos por el director
Ver `02_DECISIONES.md`, «Optimización en gráfica integrada». `CharacterScale.value` fija el tamaño; drones, cámaras y objetos no cambian. Las zonas de clic tampoco, así que son mayores que el dibujo. La variable ESCALA de `tools/medir_exportado.gd` permite comparar.

## Medido
Llamadas de dibujo en gráfica por software, que no dependen de la gráfica:

| Caso | Antes | Después |
|---|---|---|
| Ciudad | 990 | 112 |
| Caminando | 1231 | 115 |
| Pelea con 6 | 1021 | 136 |
| Pausa táctica | 1398 | 250, ya con solo las 3 IAs activas |

Medido por el director, con OpenGL directo, mediana de fotograma en ms antes y después: ciudad 12,7 y 7,2; caminando 118 y 18,6; pelea 30 y 11,2; pausa 20 y 16,4. Al 100 % de tamaño, ciudad da 9,7 ms y caminando 18,5: el 50 % aporta poco. La física al caminar ronda los 21 ms por paso y es el siguiente cuello de botella. El recurso `art/shared/atlas/piezas.png` se genera con `tools/art/piece_atlas_gen.gd` (Godot 4.7.2, a partir de los SVG propios de `art/shared/rig/`).

## Medir
`tools/medir_windows/MEDIR.bat` y `override.cfg`, con el preajuste «Medicion Windows». `override.cfg` solo cambia la escena principal. La exportación de Windows se genera, pero no se ha ejecutado en Windows desde este entorno.

## OpenGL directo en la HD 520 (medido por el director, antes de los demás cambios)
Godot obligaba a usar ANGLE en cualquier «Intel HD Graphics». Mediana de fotograma en ms, directo frente a ANGLE: ciudad 12,7 y 28,2; caminando 118 y 715; pelea 30 y 463; pausa 20 y 143. La lista de `project.godot` deja de forzar ANGLE en las HD modernas y lo mantiene en las generaciones antiguas (2000 a 6000). Sin el protagonista, caminando bajaba de 118 a 30 ms: era el principal coste.

## Medición del 15-nov (juego completo)
La medición de la fase de tareas críticas (PR #11, 15-nov) dio: ciudad 34,08 ms, caminando 153,11 ms, pelea 51,36 ms, pausa 52,82 ms (medianas, en la Intel HD 520 del director). El caminando sigue siendo el cuello de botella (6,5 fps). El desglose por partes muestra que **el coste está distribuido**: quitar personajes baja un 28 % y quitar el protagonista un 24 %, pero la física (`fisica_media`) solo consume ~35 ms del fotograma de 153 ms; el resto es renderizado (draw_calls ~130-158). La referencia anterior (7,20 / 18,60 / 11,20 / 16,40) era de la beta con una sola zona y no era comparable. La nueva referencia es esta medición (`tools/medir_windows/referencia.txt`). **Consecuencia:** la decisión de no aplicar `WorkerThreadPool` (P-30) se revierte; ahora sí hay medición que lo justifica.
Controles, cuerpo y chat comparten ancho en un panel uniforme. Junto a la silueta: estado, nivel y repuestos de cada zona, sin mostrar estadísticas (ver `02_DECISIONES.md`).

## Pausa táctica
Solo aparecen las tres IAs activas, como fantasmas de colores, con ojos y boca propios (`data/art/ai_faces.json`, `AiFace`). P-26 sigue fuera.

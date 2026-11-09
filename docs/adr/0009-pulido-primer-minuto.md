# ADR 0009: pulido del primer minuto (fase 7b reducida)

Estado: pendiente de aprobación del director en partida.

## Renderizador
Se mantiene Compatibility. Comprobado en Godot 4.7.2 ejecutando el juego con OpenGL 3 por software:
- Funcionan los shaders `canvas_item` por material (destello), `use_parent_material` en cadena para un esqueleto entero y la lectura de pantalla con `hint_screen_texture` en una capa superior (fondo de convertir).
- Según la documentación de 4.7, Compatibility no admite HDR 2D ni MSAA 2D. Ningún efecto de estos cuatro puntos los necesita. Afecta al brillo de neones de la fase 9, que habrá que resolver con shader o reconsiderar el renderizador midiendo en el ordenador del director.
- Sin medir: rendimiento en una gráfica real. El entorno de pruebas dibuja por software.

## Decisiones
- Esqueletos: una vista, un `EnemyRig`, creado al necesitarlo. Articulaciones en `entities/art/enemy_rig_data.gd`. El oeste refleja al este. De perfil, la pierna se duplica para poder andar. El Mohócrata no tiene piernas: anda balanceándose.
- `tools/art/rig_split.py` genera `art/beta/rig/` a partir de los SVG de `art/beta/`. Origen: Claude, sin servicios externos.
- Impacto: `core/impact_fx.gd`. La pausa usa `Engine.time_scale` y solo lo restaura si nadie lo ha cambiado. No se usa la semilla de la partida. Como el juego no tiene saltos, «aterrizar» es el golpe contra el suelo al caer un enemigo.
- Convertir: el mundo parado se ve a oscuras y sin color, con foco en el objeto. Las burlas son el evento `taunt` de `data/ai/personalities.json`; se eligen sin gastar la semilla.
- Silueta: `BodyHud` pinta cada pieza según su desgaste (verde, amarillo, rojo), con parpadeo por debajo del 25 %, blanco si recibe un golpe y solo contorno si falta. Sustituye a las barras.

## Valores provisionales
Tiempos, amplitudes, zancada, temblor, deformación, colores de desgaste y los 12 textos de burla (P-09: los critica el director).

## Queda para la fase 9
Opciones de reducir temblores y destellos, y el resto de la lista de `42_pulido_visual_interfaz.md`.

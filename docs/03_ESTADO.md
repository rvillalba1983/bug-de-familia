# Estado del desarrollo

Se actualiza cada vez que una fase se fusiona en `main`.

| Fase | Estado |
|---|---|
| 0 a 7 | Fusionadas en `main` y probadas por el usuario |
| Arte | En paralelo. Necesita las imágenes del usuario |
| 8. Mundo vivo | Siguiente. Sus preguntas de diseño están cerradas en `02_DECISIONES.md` |
| 9. Contenido y pulido | Sin empezar |

## Pendiente de respuesta del usuario (no bloquea)
- Tono de las 16 preguntas de conversión.
- Textos provisionales del caso y de las IAs.

## Tras la fase 6
- Los valores de daño, alcance y recarga del combate son provisionales (`docs/adr/0005-combate.md`).
- Los disparos solo afectan a guardias y tiradores, no a drones ni cámaras.

## Tras la fase 7
- Valores provisionales de la beta: `docs/adr/0006-zona-beta.md`.
- Las rutas de sigilo con enemigos activos no tienen prueba automática: las ha probado el usuario en partida.
- Sin hacer: viaje entre puntos de guardado, consecuencias al salir de la zona, la pieza que suelda Don Ramón y huella visible al morir un aliado único. Lo decidido está en `02_DECISIONES.md`.
- El siguiente pendiente más útil es P-09 (preguntas, motes y comentarios).

## Preparar el entorno en una conversación nueva
1. Clonar `rvillalba1983/bug-de-familia`. Si la copia es superficial, usar `git fetch origin main` y `FETCH_HEAD`.
2. Descargar `Godot_v4.7.2-stable_linux.x86_64.zip` de `github.com/godotengine/godot-builds/releases/download/4.7.2-stable/`.
3. Importar: `godot --headless --import`.
4. Probar siempre con `timeout` y `</dev/null`, porque un error de script abre un `debug>` que se queda colgado:
   `timeout 300 godot --headless -s -d res://addons/gdUnit4/bin/GdUnitCmdTool.gd --ignoreHeadlessMode -a res://tests -c 2>&1 </dev/null`
5. Capturas: `LIBGL_ALWAYS_SOFTWARE=1 xvfb-run -a -s "-screen 0 1920x1080x24" godot --rendering-driver opengl3 --path . -s script.gd`

## Forma de trabajar con Git
- Una rama por fase. Se fusiona en `main` con `--ff-only` y solo cuando el usuario lo aprueba.
- Las ramas remotas las borra el usuario.
- Los documentos cambiados se copian al proyecto de Claude, en `Videojuego/Desarrollo/`. El repositorio manda.

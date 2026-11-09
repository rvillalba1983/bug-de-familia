# Estado del desarrollo

Se actualiza cada vez que una fase se fusiona en `main`.

| Fase | Estado |
|---|---|
| 0 a 7 | Fusionadas en `main` y probadas por el usuario |
| Arte | Estilo de la beta fusionado en `main`, ejecutado en Godot 4.7.2 el 9-nov: 187 pruebas pasan y el director aprobó capturas y vídeo reales. Ver `adr/0008-estilo-visual-beta.md` |
| 7b. Pulido visual e interfaz | Fusionada en `main` y aprobada por el director el 9-nov, con los cuatro puntos del primer minuto (animación de enemigos, impacto, convertir y silueta). 203 pruebas pasan. Ver `adr/0009-pulido-primer-minuto.md`. El resto de la lista pasa a la fase 9, incluidas las opciones de reducir temblores y destellos |
| 8. Mundo vivo (zona beta) | Fusionada en `main` el 9-nov y aprobada por el director. 229 pruebas pasan. Ver `adr/0010-mundo-vivo-beta.md` |
| 9. Contenido y pulido | Fusionada en `main` el 9-nov y aprobada por el director. 255 pruebas pasan. Ver `adr/0011-ias-y-controles.md`, `adr/0012-batallas.md` y `adr/0013-audio-y-rendimiento.md` |
| Cierre de la beta | Fusionada en `main` el 9-nov con aprobación del director. 261 pruebas pasan. Ver `adr/0014-cierre-beta.md` |
| Revisión de código y pruebas (P-24) | Siguiente fase |
| Post-beta. Mundo completo | Después, tras revisar la beta: otras cuatro razas, 13 progenitores, zonas nuevas, tres niveles de simulación y viaje entre puntos de guardado |

## Pendiente de respuesta del usuario (no bloquea)
- Textos provisionales del caso y de las IAs.

## Tras la fase 6
- Los valores de daño, alcance y recarga del combate son provisionales (`docs/adr/0005-combate.md`).
- Los disparos solo afectan a guardias y tiradores, no a drones ni cámaras.

## Tras la fase 7
- Valores provisionales de la beta: `docs/adr/0006-zona-beta.md`.
- Las rutas de sigilo con enemigos activos no tienen prueba automática: las ha probado el usuario en partida.
- Sin hacer: viaje entre puntos de guardado, consecuencias al salir de la zona, la pieza que suelda Don Ramón y huella visible al morir un aliado único. Lo decidido está en `02_DECISIONES.md`.

## Tras P-09 (lotes 1 y 2)
- 76 preguntas de conversión, motes y comentarios del protagonista integrados. Valores provisionales: `docs/adr/0007-motes-y-comentarios.md`.
- Los comentarios solo salen en la zona beta y nadie los ha probado aún en partida.
- Esperan a su sistema: comentarios de Cupido_Beta enamorada y del viaje rápido, motes de las 14 IAs no jugables y las 12 preguntas reservadas de las otras cuatro razas (`docs/borradores/P-09_lote_2.md`).

## Tras la fase 7b
- Tiempos, temblor, zancada, deformación y colores de desgaste son provisionales. Los 12 textos de burla de las IAs están pendientes de la crítica del director (P-09).
- Rendimiento sin medir en una gráfica real: las pruebas dibujan por software.
- Sin revisar: cuadrado gris a los pies de Don Ramón.

## Tras la fase 8
- Toda la población, los sucesos, las misiones y los textos de `data/world/` son provisionales. El director puede tachar festividades.
- Sin medir en una gráfica real. Sin probar a mano en partida: terminar una misión y reventar una fiesta.
- Los personajes con nombre siguen con diálogos escritos, fuera del motor social.
- P-19: proponer opciones para mostrar los controles, que ahora salen en el chat de las IAs.
- Capturas de partida real con `tools/captura_partida.gd` (variables CAPTURAS, SALIDA, FECHA, ACCION y SUCESO).

## Tras la fase 9
- 20 IAs, batallas, vista de estrategia, 100 melodías y 40 perfiles de voz sintéticos. Las voces no son acentos reales. Valores y textos provisionales.
- Sin medir en una gráfica real. Una batalla en curso no se guarda.
- Pruebas de rendimiento con `tools/medir_rendimiento.gd` (variables CASO y EXTRA). Audio con `tools/audio/gen_audio.py`.

## Tras el cierre de la beta
- P-02 implementado y provisional, a revisar jugando. Población, catálogo y textos son provisionales.
- El director no ha jugado aún la beta entera con estos cambios. Sin medir en una gráfica real.
- Recorridos reales con `tools/recorrido_beta.gd` (variables RUTA, SEMILLA y FECHA).
- Siguiente fase: P-24, revisión de código y más pruebas funcionales. Ideas post-beta: P-23, P-25, P-26 y P-27.

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

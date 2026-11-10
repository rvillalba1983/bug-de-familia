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
| Arreglos tras probar la beta | Fusionada en `main` el 9-nov con aprobación del director. 266 pruebas pasan. Ver `adr/0015-arreglos-beta.md` |
| Revisión de código, pruebas y rendimiento (P-24) | Fusionada en `main` el 9-nov con aprobación del director. 293 pruebas pasan. Ver `adr/0016-revision-codigo.md` |
| Optimización en gráfica integrada | Fusionada en `main` el 9-nov con aprobación del director. 308 pruebas pasan. Ver `adr/0017-optimizacion-integrada.md` |
| Pruebas finales de la beta y dudas | Fusionada en `main` el 9-nov con aprobación del director. 311 pruebas pasan. Las pruebas del director en Windows siguen pendientes: hará lista de lo raro durante la semana |
| Post-beta. Mundo completo | Tras la fase de pruebas finales: otras cuatro razas, 13 progenitores, zonas nuevas, tres niveles de simulación y viaje entre puntos de guardado |

## Pendiente de respuesta del usuario (no bloquea)
- Textos provisionales del caso y de las IAs.

## Tras la fase 6
- Los valores de daño, alcance y recarga del combate son provisionales (`docs/adr/0005-combate.md`).
- Los disparos solo afectan a guardias y tiradores, no a drones ni cámaras.

## Tras la fase 7
- Valores provisionales de la beta: `docs/adr/0006-zona-beta.md`.
- Las rutas de sigilo con enemigos activos tienen prueba automática en `tests/flows/beta_routes_test.gd`; el usuario además las ha probado en partida.
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
- Sin medir en una gráfica real. Terminar una misión y reventar una fiesta tienen prueba automática en `tests/flows/beta_routes_test.gd`; falta probarlos a mano en partida.
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

## Tras los arreglos de la beta
- Rendimiento medido solo con gráfica por software: falta confirmarlo en el ordenador del director. Medir con `tools/medir_por_partes.gd` (variables NOCHE, EXTRA y CAPAS).
- La pelea contra grupos no la ha probado el director a mano. Radio de reacción (250) y hueco alrededor del jugador (34), provisionales.
- Clics reales de pelea con `tools/probar_pelea.gd`.

## Tras la revisión de código (P-24)
- Razas, zona, progenitores, armas, animaciones y muertes viven en datos: ver `adr/0016-revision-codigo.md`.
- Medido en la gráfica del director (Intel HD 520): ciudad de 84 a unos 30 ms, batalla de 250 a 16-28 ms. Para 60 imágenes por segundo aún faltan protagonista en textura, paredes en bloques y atlas de personajes.
- Medir el juego exportado con `tools/medir_exportado.tscn` y el preajuste «Medicion Windows».
- Al ejecutar dos Godot a la vez, usar un `XDG_DATA_HOME` distinto: comparten `user://`.

## Tras la optimización en gráfica integrada
- En la Intel HD 520 del director, con OpenGL directo: ciudad 7 ms, caminando 19, pelea 11 y pausa 16 (medido antes de los últimos ajustes). La física al caminar, unos 21 ms por paso, es el siguiente cuello de botella.
- Sin probar en Windows por Claude. Plugins de estilo IRCap confirmados por el director el 10-nov: los quiere, con fase de revisión estética después. Sin confirmar todavía: provocar peleas y autocolocación de piezas.
- El director vio personajes desaparecer al hablar mal de la otra raza; no se ha reproducido. Queda por vigilar.
- Provisionales: retroceso de 80 unidades, tres frases para provocar batalla, y tamaño de personajes al 50 %.

## Tras las pruebas finales de la beta
- Grupos engañados (respuestas «chatarra al norte» y «sombreros en el sur»): antes se esfumaban; ahora se van andando y desaparecen al llegar. Salida y velocidad provisionales.
- Investigado: tras un rumor, casi toda una raza puede irse andando a contárselo a la otra. Es P-14 exagerado: el director decide si se limita.
- De noche, los Jubilados apagados no se defienden en una batalla (8 caídos sin devolver un golpe en la prueba): decisión pendiente.
- Ejecutado aquí con capturas: provocar por malmeter, autocolocación, aviso al recoger, retroceso y chat. Sin confirmar por el director, igual que OpenGL directo y el `.exe` en Windows. Sin probar en partida: batalla por recado insultante.
- Herramientas: `tools/seguir_personajes.gd`, `tools/probar_pendientes.gd` y `tools/probar_desvio.gd`.
- Preguntas abiertas de la post-beta: P-23, P-25 a P-31, mapa, orden de razas, guardar batallas, rendimiento objetivo y textos provisionales.

## Herramientas y CI (rama de configuración, pendiente de fusión)

- Entorno local gratuito en `opencode_projects`: Godot 4.7.2, Python 3.12.10, ffmpeg, Inkscape 1.4.4 y plantillas de exportación; todos en el PATH de usuario. Audacity ya estaba instalado.
- Scripts deterministas: `tools/verificar.py` (entrada única), `tools/validar_datos.py` (46 comprobaciones), `tools/formatear.py`, `tools/comparar_medicion.py`. Estado hoy: 0 errores en datos y en 255 archivos de texto; 64 avisos de líneas largas, deuda anterior.
- Al crear el formateador se corrigieron 12 archivos que incumplían la norma de línea final (9 JSON de `data/` y 3 pruebas). No se debilitó ninguna comprobación.
- GitHub Actions: `pruebas.yml` (verificaciones deterministas + 311 pruebas gdUnit4, con `timeout` y `</dev/null`) y `exportar.yml` (`.exe` y `.pck` como artefactos). Sin ejecutar todavía en Actions: es la validación pendiente.
- Estudiado y descartado: servidores MCP (coste de contexto y dependencias), LSP (sin servidor para GDScript), plugins de marketplace de terceros, y el generador de imágenes de OpenCode (de pago, sin fondos). Ver `adr/0019-herramientas-ci-y-mcp.md`.
- Plantillas de mohócrata: SVG por código con la paleta y el rig actual, no integradas aún en el juego (ejemplo para el director).

## Preparar el entorno en una conversación nueva
1. Clonar `rvillalba1983/bug-de-familia`. Si la copia es superficial, usar `git fetch origin main` y `FETCH_HEAD`.
2. Descargar `Godot_v4.7.2-stable_linux.x86_64.zip` de `github.com/godotengine/godot-builds/releases/download/4.7.2-stable/`.
3. Importar: `godot --headless --import`. Plantillas de exportación: `Godot_v4.7.2-stable_export_templates.tpz`, en `~/.local/share/godot/export_templates/4.7.2.stable/`.
4. Probar siempre con `timeout` y `</dev/null`, porque un error de script abre un `debug>` que se queda colgado:
   `timeout 300 godot --headless -s -d res://addons/gdUnit4/bin/GdUnitCmdTool.gd --ignoreHeadlessMode -a res://tests -c 2>&1 </dev/null`
5. Capturas: `LIBGL_ALWAYS_SOFTWARE=1 xvfb-run -a -s "-screen 0 1920x1080x24" godot --rendering-driver opengl3 --path . -s script.gd`

## Forma de trabajar con Git
- Una rama por fase. Se fusiona en `main` con `--ff-only` y solo cuando el usuario lo aprueba.
- Las ramas remotas las borra el usuario.
- Los documentos cambiados se copian al proyecto de Claude, en `Videojuego/Desarrollo/`. El repositorio manda.

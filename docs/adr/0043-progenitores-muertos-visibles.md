# ADR 0043: progenitores muertos siguen visibles en la zona (23-nov)

Estado: decidido por el director el 23-nov; **pendiente de implementar** en la
siguiente fase (población interactiva y actividades de las 24 zonas).

## Contexto
El director probó en partida el arte definitivo de los 15 progenitores (ADR
0041) y aprobó cómo se ven en pantalla. En cambio, al elegir «Insultar» el
progenitor desaparece y le pareció que eso «no va bien».

La investigación (solo lectura, 23-nov) confirmó que no es un fallo nuevo,
sino la consecuencia ya aprobada de la mortalidad del 22-nov (ADR 0038 y la
fila «Mortalidad» de `docs/01_CONFLICTOS_Y_PENDIENTES.md`):

- El insulto abre el nodo `insultado`, cuya opción «Golpear» (`action: hit`,
  `data/conversation/progenitors.json`) deriva en pelea
  (`simulation/live_dialogue.gd:407-419`).
- Los 14 progenitores que son `Guard` caen con `Guard._fall()`
  (`entities/enemies/guard.gd:371-386`): ocultan el modelo y, pasados 25 s,
  `Sandbox._on_corpse_expired()` los libera (`scenes/sandbox/sandbox.gd:293-301`,
  `:649-651`).
- El Contestador es `Interactable`: `ZoneBase.kill_progenitor()`
  (`scenes/zones/zone_base.gd:628-633`) hace `visible = false` al instante, sin
  cadáver ni efecto de muerte.

Tampoco interviene el culling de rigs (ADR 0036): los progenitores se dibujan
con `art_views`, no con `rig_root`.

## Decisión
**Mantener el encuentro completo aprobado** — saludo, pista, insulto, enfado,
pelea y mortalidad con su consecuencia de lore (`flag
progenitor_<id>_muerto` y frase `death`) — **pero evitar la desaparición
visual**: un progenitor muerto debe seguir presente en la zona, sin poder
reanudar el diálogo ni volver a pelear.

Se descartan las otras dos alternativas planteadas al director:

- Quitar insulto y pelea: contradice la fila «Alcance del encuentro» y el ADR
  0038, y deja la mortalidad sin vía de juego.
- Hacerlos inmortales: contradice «pueden morir ya» y deja las frases `death`
  sin uso en partida.

## Consecuencias
- Esta decisión **sustituye solo** la parte de «ocultar al actor al morir» de
  la fila «Mortalidad» y del ADR 0038. Siguen vigentes la mortalidad, el flag
  de investigación y la frase de lore.
- Hay que decidir en la implementación si el cuerpo queda permanente o con
  otra representación, siempre sin `queue_free` y sin `visible = false`, y
  comprobar el coste de dejar 15 actores más en escena.
- Hay que bloquear la re-interacción: hoy el Contestador «muerto» puede volver
  a abrir su diálogo porque no es `Guard` y no pasa por la guarda `is_down()`.
- Hay que añadir cobertura: `tests/zones/progenitor_encounter_test.gd` solo
  comprueba que insultar abre «Golpear» y que el flag se marca con
  `_on_progenitor_fell()`; no cubre la desaparición ni la re-interacción.
- No se toca nada de esta decisión en la fase de cierre de consistencia; se
  implementa en la fase nueva de zonas y se valida en partida con el director.

## Referencias
- `docs/adr/0038-encuentros-progenitores-y-arte.md`: encuentro y mortalidad
  aprobados el 22-nov (hecho que se conserva).
- `docs/adr/0041-arte-definitivo-progenitores-p58.md`: arte aprobado en pantalla.
- `docs/01_CONFLICTOS_Y_PENDIENTES.md`: P-61 (decisión registrada) y fila
  «Mortalidad» (22-nov, ahora matizada por este ADR).

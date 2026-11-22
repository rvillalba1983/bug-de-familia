# ADR 0038: arte propio y encuentros de los 15 progenitores (22-nov)

Estado: aplicado en la rama `fase/postbeta-progenitores-arte-encuentros`.
Pendiente de aprobación del director y fusión en `main`.

## Contexto
La fase anterior dejó a los 15 progenitores repartidos por sus zonas como actores
pasivos, pero con dos carencias: usaban arte de su especie (o el círculo de color
cuando faltaba la vista) y no tenían encuentro propio. El director decidió que:

- los 13 progenitores nuevos **son mortales ya**, y hay que escribir desde ahora
  la consecuencia de lore de cada muerte;
- el encuentro mínimo es **saludo + pista + opción de seguir o insultar**;
- el insulto puede derivar en enfado y pelea, coherente con la mortalidad aprobada.

## Decisión
### Arte
`tools/art/progenitores_gen.py` genera 75 SVG (15 progenitores × 5 vistas:
`""`, `_se`, `_e`, `_ne`, `_n`) en `art/shared/progenitores/`, con procedencia
registrada en cada archivo. `tools/conectar_arte_progenitores.py` añadió el campo
`art: "progenitores/<id>"` a los 15 progenitores de `data/world/progenitors.json`.
`GuardVisual` sigue tolerando una vista ausente: cae al círculo de `body_color`
sin `ERROR`, así que el arte nuevo es una mejora y no un requisito de arranque.

### Encuentro
`data/conversation/progenitors.json` contiene 15 árboles con `species`, `death`
(consecuencia de lore de la muerte) y `nodes`. `ProgenitorDialogues` los carga
con `DataFile`. `LiveDialogue` gana un modo progenitor (`open_progenitor()`) que
reutiliza el panel, las opciones y las acciones ya existentes (`gift_piece`,
`hit`, `provoke_battle`, `praise`, `insult`) más `contestador_bobina` para la
bobina del Contestador.

`ZoneBase` engancha un `Interactable` y un `SpeechBubble` directamente al `Guard`
del progenitor, y registra `kill_progenitor()` con el flag
`progenitor_<id>_muerto`. **No** se crea `NpcState` en `sim.npcs` ni se añade a
`LiveWorld.citizens`: `LiveWorld.start()`, `_direct_all()`, `_crowded()` y
`_sync_positions()` indexan `sim.npcs[id]` por cada ciudadano, así que meter a
los progenitores sin entrada en `sim` provocaría fallos. La burbuja y el
`Interactable` se crean en `_spawn_actor()` porque en ese momento `live_world`
todavía es `null` (`_build_enemies()` corre antes que `_build_investigation()`);
la referencia al diálogo se resuelve al activarse.

Don Ramón y El Contestador usan su enganche en `despliegue_cero_zone.gd`. El
Contestador conserva la bobina de `data/investigation/case_beta.json`: matar al
progenitor no bloquea la investigación.

### Datos y validación
Se corrigió `data/zones/lonja.json`: el actor `fiador` era de especie `grux` y
no tenía el marcador `progenitor`, así que no montaba su arte propio. Ahora es
un actor pasivo como los otros 13. `tools/validar_datos.py` comprueba los 15
árboles (nodos obligatorios, `next` existentes, acciones conocidas, consecuencia
de muerte), que cubran exactamente el catálogo y las cinco vistas de cada arte;
`tools/referencia_datos.json` incorpora los conteos nuevos (15 y 75).

## Consecuencias
- Cada progenitor tiene saludo, su versión del misterio, una pista, respuesta al
  insulto y una frase de muerte; el jugador puede seguir escuchando o insultar.
- La muerte es definitiva y queda registrada en el flag de zona; la consecuencia
  de lore ya está escrita en el JSON, no queda para una fase posterior.
- El `.pck` crece con 75 SVG nuevos; no se han generado texturas ni audio.
- Pruebas nuevas: `tests/zones/progenitor_encounter_test.gd` (6 casos) y
  `tests/despliegue_cero/progenitor_dialogue_test.gd` (3 casos), semilla 1234.
- Validación manual pendiente: ver a los progenitores en partida y abrir su
  diálogo (en especial el insulto → pelea y la bobina del Contestador).

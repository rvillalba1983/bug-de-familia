# ADR 0026: la pelea comienza sola (P-37)

Estado: implementado por el director el 11-nov-2026.

## Contexto
P-37 pedía que, cuando empieza una pelea, el protagonista ataca automáticamente y usa
sus ataques de forma automática siempre en modo pelea. Durante la fase post-beta el
manual de validación puso el punto en el peor lugar: sin orden del jugador (clic o
conversación) el protagonista no pegaba hasta que el jugador pulsaba con el ratón.

## Decisión
Al confirmar la pre-pausa y pasar a la fase `FIGHTING`, el `FightDirector` arranca el
combate con el nuevo `start_combat()` (`stealth/fight_director.gd`), que auto-engancha al
guardia objetivo en el `CombatSystem` (`combat.engage`). El auto-ataque sale del propio
`CombatSystem`: acercamiento al objetivo y golpes en rango cuando está en medio.
El orden manual por clic o conversación sigue funcionando como objetivo (`PointerOrders`,
`BetaZone.attack_citizen`).

## Consecuencias y limitaciones
- La pelea arranca sola: el protagonista se pone a pelear sin orden previo.
- Las dudas de P-37 quedan abiertas: sustitución del ataque manual, alcance de armas y
  acciones del catálogo de combate (`data/combat/`), desactivación en opciones y encaje
  con el sigilo (atacar solo podría delatar la posición).

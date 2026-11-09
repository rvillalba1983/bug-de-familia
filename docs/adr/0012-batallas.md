# ADR 0012: batallas entre facciones (fase 9)

Estado: pendiente de aprobación del director.

- `scenes/beta/battle_director.gd` organiza la batalla; `ui/battle_offer.gd` ofrece unirse, mirar o pasar; `ui/strategy_view.gd` es la vista de estrategia.
- Empieza al estallar la guerra de la investigación (una vez por partida) o, con la relación entre razas muy baja, por azar.
- Luchan hasta 8 habitantes por bando. Los golpes entre ellos no se atribuyen al jugador. Los caídos se pueden convertir, y si te ve uno de su bando lo recuerda.
- x2 y x4 usan `Engine.time_scale`, y se restaura al salir. Si empieza una pelea con el jugador, la vista se cierra sola.
- Valores provisionales en las constantes de `BattleDirector`. Textos de Claude en `data/world/battles.json`, sin servicios externos.

## Limitaciones
- Una batalla en curso no se guarda; las muertes sí.
- Sin sonido de batalla hasta el bloque de audio.

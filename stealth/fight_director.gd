class_name FightDirector
extends Node
## Controla la pausa inicial antes de pelear y cuándo se ha terminado la pelea.

signal pre_fight_started
signal fight_ended

enum Phase { CALM, PRE_FIGHT, FIGHTING }

## Valor provisional.
const END_DELAY: float = 3.0

var phase: Phase = Phase.CALM
var body: ModularBody
var combat: CombatSystem

var _guards: Array[Guard] = []
var _calm_time: float = 0.0
var _alerting_guard: Guard = null  # guardia que disparó la alerta (P-39: evitar bajas ajenas)


func track(guard: Guard) -> void:
	_guards.append(guard)
	guard.alert_started.connect(func() -> void: _on_alert_started(guard))
	guard.tree_exiting.connect(func() -> void: _guards.erase(guard))


func confirm_pre_fight() -> void:
	if phase == Phase.PRE_FIGHT:
		phase = Phase.FIGHTING
		body.context = ModularBody.Context.FIGHTING
		_calm_time = 0.0
		start_combat()


## La pelea arranca sola: el protagonista se pone a pelear sin necesidad de que el
## jugador le de la orden con el ratón (clic o conversación). Se acerca al oponente y el
## propio CombatSystem se encarga de los golpes en rango.
func start_combat() -> void:
	if combat == null or combat.target != null:
		return
	# Enganchar primero al guardia que disparó la alerta (P-39: evita bajas
	# ajenas por pelea automática). Si no es válido, el primero disponible.
	if is_instance_valid(_alerting_guard) and not _alerting_guard.passive and not _alerting_guard.is_down():
		combat.engage(_alerting_guard)
		return
	for guard: Guard in _guards:
		if is_instance_valid(guard) and not guard.passive and not guard.is_down():
			combat.engage(guard)
			return


func _physics_process(delta: float) -> void:
	if phase != Phase.FIGHTING:
		return
	if _any_alert():
		_calm_time = 0.0
		return
	_calm_time += delta
	if _calm_time >= END_DELAY:
		phase = Phase.CALM
		body.context = ModularBody.Context.FREE
		_alerting_guard = null
		fight_ended.emit()


func _any_alert() -> bool:
	for guard: Guard in _guards:
		if guard.is_alert():
			return true
	return false


func _on_alert_started(guard: Guard) -> void:
	if phase == Phase.CALM:
		_alerting_guard = guard
		phase = Phase.PRE_FIGHT
		body.context = ModularBody.Context.PRE_FIGHT
		pre_fight_started.emit()

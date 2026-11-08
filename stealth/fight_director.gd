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

var _guards: Array[Guard] = []
var _calm_time: float = 0.0


func track(guard: Guard) -> void:
	_guards.append(guard)
	guard.alert_started.connect(_on_alert_started)


func confirm_pre_fight() -> void:
	if phase == Phase.PRE_FIGHT:
		phase = Phase.FIGHTING
		body.context = ModularBody.Context.FIGHTING
		_calm_time = 0.0


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
		fight_ended.emit()


func _any_alert() -> bool:
	for guard: Guard in _guards:
		if guard.is_alert():
			return true
	return false


func _on_alert_started() -> void:
	if phase == Phase.CALM:
		phase = Phase.PRE_FIGHT
		body.context = ModularBody.Context.PRE_FIGHT
		pre_fight_started.emit()

class_name AcidRain
extends Node
## Lluvia ácida ocasional: desgasta las piezas metálicas de quien no esté a cubierto.

signal warning
signal started
signal ended

## Valores provisionales, a ajustar al probar.
const DRY_TIME_MIN: float = 120.0
const DRY_TIME_MAX: float = 480.0
const RAIN_TIME: float = 30.0
const WARNING_TIME: float = 10.0
const WEAR_PER_SECOND: float = 0.4

const ACID_VISUAL_TIME: float = 0.4

var player: Player
var shelters: Array[Rect2] = []
var raining: bool = false

var rng: RandomNumberGenerator

var _time_left: float = 0.0
var _warned: bool = false


func _ready() -> void:
	_time_left = _next_dry_time()


func _physics_process(delta: float) -> void:
	_time_left -= delta
	if not raining and not _warned and _time_left <= WARNING_TIME:
		_warned = true
		warning.emit()
	if _time_left <= 0.0:
		_set_raining(not raining)
	if raining and not is_sheltered():
		wear(delta)


func is_sheltered() -> bool:
	for shelter: Rect2 in shelters:
		if shelter.has_point(player.global_position):
			return true
	return false


func wear(delta: float) -> void:
	player.body.acid_time = ACID_VISUAL_TIME
	for slot: int in ModularBody.Slot.values():
		var piece: BodyPiece = player.body.equipped(slot as ModularBody.Slot)
		if piece != null and piece.metallic and not piece.effects.has("acid_proof"):
			player.body.wear_piece(slot as ModularBody.Slot, WEAR_PER_SECOND * delta)


## La lluvia llega por sorpresa, sin un ritmo que aprender.
func _next_dry_time() -> float:
	return rng.randf_range(DRY_TIME_MIN, DRY_TIME_MAX)


func _set_raining(value: bool) -> void:
	raining = value
	_time_left = RAIN_TIME if raining else _next_dry_time()
	if raining:
		started.emit()
	else:
		ended.emit()

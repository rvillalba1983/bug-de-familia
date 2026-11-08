class_name AcidRain
extends Node
## Lluvia ácida ocasional: desgasta las piezas metálicas de quien no esté a cubierto.

signal started
signal ended

## Valores provisionales, a ajustar al probar.
const DRY_TIME: float = 300.0
const RAIN_TIME: float = 30.0
const WEAR_PER_SECOND: float = 0.4

var player: Player
var shelters: Array[Rect2] = []
var raining: bool = false

var _time_left: float = DRY_TIME


func _physics_process(delta: float) -> void:
	_time_left -= delta
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
	for slot: int in ModularBody.Slot.values():
		var piece: BodyPiece = player.body.equipped(slot as ModularBody.Slot)
		if piece != null and piece.metallic:
			player.body.wear_piece(slot as ModularBody.Slot, WEAR_PER_SECOND * delta)


func _set_raining(value: bool) -> void:
	raining = value
	_time_left = RAIN_TIME if raining else DRY_TIME
	if raining:
		started.emit()
	else:
		ended.emit()

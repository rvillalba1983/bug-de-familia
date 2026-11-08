class_name SavePoint
extends Node2D
## Punto de guardado: guarda al entrar y sirve de destino de viaje más adelante.

signal entered

const RADIUS: float = 50.0
const COLOR_RING: Color = Color("#6fd0ff")

var _inside: bool = true


func _draw() -> void:
	draw_arc(Vector2.ZERO, RADIUS, 0.0, TAU, 32, COLOR_RING, 2.0)


func track(character_position: Vector2) -> void:
	var is_inside: bool = global_position.distance_to(character_position) <= RADIUS
	if is_inside and not _inside:
		entered.emit()
	_inside = is_inside

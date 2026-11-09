class_name SavePoint
extends Node2D
## Punto de guardado: guarda al entrar y sirve de destino de viaje más adelante.

signal entered

const RADIUS: float = 50.0
const ART: Array = ["guardado", 110.0, 65.0]

var _inside: bool = true


func _draw() -> void:
	PropArt.draw_entry(self, ART)


func track(character_position: Vector2) -> void:
	var is_inside: bool = global_position.distance_to(character_position) <= RADIUS
	if is_inside and not _inside:
		entered.emit()
	_inside = is_inside

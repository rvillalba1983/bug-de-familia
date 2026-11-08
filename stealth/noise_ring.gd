class_name NoiseRing
extends Node2D
## Onda provisional que muestra hasta dónde llega un ruido.

const LIFETIME: float = 0.5
const COLOR_RING: Color = Color(1.0, 0.85, 0.3, 0.8)

var _radius: float = 0.0
var _age: float = 0.0


func setup(origin: Vector2, radius: float) -> void:
	position = origin
	_radius = radius


func _process(delta: float) -> void:
	_age += delta
	if _age >= LIFETIME:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var progress: float = _age / LIFETIME
	var color: Color = COLOR_RING
	color.a *= 1.0 - progress
	draw_arc(Vector2.ZERO, _radius * progress, 0.0, TAU, 48, color, 3.0)

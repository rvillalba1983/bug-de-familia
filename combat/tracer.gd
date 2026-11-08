class_name Tracer
extends Node2D
## Línea breve que muestra un lanzamiento o un disparo.

const LIFETIME: float = 0.18

var _from: Vector2
var _to: Vector2
var _color: Color
var _age: float = 0.0


func setup(from: Vector2, to: Vector2, color: Color) -> void:
	_from = from
	_to = to
	_color = color


func _process(delta: float) -> void:
	_age += delta
	if _age >= LIFETIME:
		queue_free()


func _draw() -> void:
	draw_line(_from, _to, _color, 3.0)

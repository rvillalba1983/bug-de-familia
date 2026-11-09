class_name CameraZoom
extends Camera2D
## Cámara de ángulo fijo con zoom por rueda. Funciona también en pausa.

const MIN_ZOOM: float = 1.5
const START_ZOOM: float = 1.75
const MAX_ZOOM: float = 2.6
const ZOOM_STEP: float = 0.1
const SHAKE_DECAY: float = 60.0

var _shake: float = 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	zoom = Vector2(START_ZOOM, START_ZOOM)


func _process(delta: float) -> void:
	if _shake <= 0.0:
		return
	_shake = maxf(_shake - SHAKE_DECAY * delta, 0.0)
	offset = Vector2.ZERO if _shake <= 0.0 else Vector2.from_angle(randf() * TAU) * _shake


## Temblor de cámara. No usa la semilla de la partida: es solo visual.
func shake(strength: float) -> void:
	_shake = maxf(_shake, strength)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"zoom_in"):
		apply_zoom_step(1.0)
	elif event.is_action_pressed(&"zoom_out"):
		apply_zoom_step(-1.0)


func apply_zoom_step(direction: float) -> void:
	var value: float = next_zoom(zoom.x, direction)
	zoom = Vector2(value, value)


static func next_zoom(current: float, direction: float) -> float:
	return clampf(current + ZOOM_STEP * direction, MIN_ZOOM, MAX_ZOOM)

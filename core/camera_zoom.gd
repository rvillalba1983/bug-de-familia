class_name CameraZoom
extends Camera2D
## Cámara de ángulo fijo con zoom por rueda. Funciona también en pausa.

const MIN_ZOOM: float = 1.0
const MAX_ZOOM: float = 2.5
const ZOOM_STEP: float = 0.1


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


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

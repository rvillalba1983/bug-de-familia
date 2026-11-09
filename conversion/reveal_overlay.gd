class_name RevealOverlay
extends CanvasLayer
## Marca un rato lo que descubre una pieza de visión o sentidos.

const COLOR_ENEMY: Color = Color("#ff4a3a")
const COLOR_MINE: Color = Color("#ffd24a")
const COLOR_PICKUP: Color = Color("#7fe07f")
const RANGE: float = 900.0
const RING: float = 30.0

var _level: Sandbox
var _what: String = ""
var _left: float = 0.0
var _canvas: Control


func setup(level: Sandbox, what: String, duration: float) -> void:
	_level = level
	_what = what
	_left = duration
	layer = 3


func _ready() -> void:
	_canvas = Control.new()
	_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_canvas.draw.connect(_paint)
	add_child(_canvas)


func _process(delta: float) -> void:
	_left -= delta
	if _left <= 0.0:
		queue_free()
		return
	_canvas.queue_redraw()


func marks() -> Array[Vector2]:
	var result: Array[Vector2] = []
	for entry: Array in _targets():
		result.append(entry[0])
	return result


func _targets() -> Array:
	var feet: Vector2 = _level.player.global_position
	var found: Array = []
	if _what in ["enemies", "all"]:
		for guard: Guard in _level.guards():
			if not guard.is_down() and guard.global_position.distance_to(feet) <= RANGE:
				found.append([guard.global_position, COLOR_ENEMY])
	if _what in ["mines", "all"]:
		for node: Node in _level.get_tree().get_nodes_in_group(&"mina"):
			if (node as Node2D).global_position.distance_to(feet) <= RANGE:
				found.append([(node as Node2D).global_position, COLOR_MINE])
	if _what in ["pickups", "all"]:
		for node: Node in _level.get_tree().get_nodes_in_group(Interactable.GROUP):
			var item: Interactable = node as Interactable
			if item.is_pickup() and not item.used and item.global_position.distance_to(feet) <= RANGE:
				found.append([item.global_position, COLOR_PICKUP])
	return found


func _paint() -> void:
	var view: Transform2D = _level.get_viewport().get_canvas_transform()
	for entry: Array in _targets():
		var at: Vector2 = view * (entry[0] as Vector2)
		_canvas.draw_arc(at, RING, 0.0, TAU, 28, Color.BLACK, 7.0)
		_canvas.draw_arc(at, RING, 0.0, TAU, 28, entry[1], 4.0)

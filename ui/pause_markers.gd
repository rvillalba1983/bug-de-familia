class_name PauseMarkers
extends Control
## En la pausa táctica, marca en color lo que amenaza y lo que se puede usar.

const COLOR_THREAT: Color = Color("#ff4a3a")
const COLOR_MINE: Color = Color("#ffd24a")
const COLOR_USABLE: Color = Color("#c060ff")
const RING: float = 34.0

var level: DespliegueCeroZone


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false


func set_shown(shown: bool) -> void:
	visible = shown
	queue_redraw()


func _process(_delta: float) -> void:
	if visible:
		queue_redraw()


func _draw() -> void:
	var view: Transform2D = get_viewport().get_canvas_transform()
	for guard: Guard in level.guards():
		if not guard.is_down() and not guard.passive:
			_ring(view * guard.global_position, COLOR_THREAT)
	for node: Node in get_tree().get_nodes_in_group(Convertible.GROUP):
		var convertible: Convertible = node as Convertible
		if not convertible.get_parent() is Guard:
			_ring(view * convertible.global_position, COLOR_USABLE)
	for node: Node in get_tree().get_nodes_in_group(&"mina"):
		_ring(view * (node as Node2D).global_position, COLOR_MINE)


func _ring(at: Vector2, color: Color) -> void:
	draw_arc(at, RING, 0.0, TAU, 28, Color.BLACK, 7.0)
	draw_arc(at, RING, 0.0, TAU, 28, color, 4.0)

class_name KeyHint
extends Node2D
## Tecla pequeña sobre lo que se puede usar ahora mismo. Solo el aviso, sin descripciones.

const SIZE: float = 26.0
const HEIGHT: float = 104.0

var player: Player

var _target: Interactable


func _ready() -> void:
	z_index = 45


func _process(_delta: float) -> void:
	var best: Interactable = player.nearest_interactable()
	if best != _target:
		_target = best
		queue_redraw()
	if is_instance_valid(_target):
		visible = true
		global_position = _target.global_position + Vector2(0.0, -HEIGHT)
	else:
		visible = false


func _draw() -> void:
	draw_key(self, Vector2.ZERO, "E")


static func draw_key(node: CanvasItem, center: Vector2, letter: String) -> void:
	var box: Rect2 = Rect2(center - Vector2(SIZE, SIZE) * 0.5, Vector2(SIZE, SIZE))
	node.draw_rect(Rect2(box.position + Vector2(3.0, 4.0), box.size), Palette.INK)
	node.draw_rect(box, Color("#FFD400"))
	node.draw_rect(box, Palette.INK, false, 3.0)
	node.draw_string(
		ThemeDB.fallback_font, box.position + Vector2(0.0, 20.0), letter,
		HORIZONTAL_ALIGNMENT_CENTER, SIZE, 18, Palette.INK
	)

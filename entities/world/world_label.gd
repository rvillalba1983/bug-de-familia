class_name WorldLabel
extends RefCounted
## Texto provisional dibujado junto a un elemento del escenario.

const FONT_SIZE: int = 16
const BOX_WIDTH: float = 320.0
const COLOR_TEXT: Color = Color(1.0, 1.0, 1.0, 0.9)


static func draw_on(node: CanvasItem, text: String, center_bottom: Vector2) -> void:
	var origin: Vector2 = center_bottom - Vector2(BOX_WIDTH * 0.5, 0.0)
	var font: Font = ThemeDB.fallback_font
	node.draw_string(
		font, origin, text, HORIZONTAL_ALIGNMENT_CENTER, BOX_WIDTH, FONT_SIZE, COLOR_TEXT
	)

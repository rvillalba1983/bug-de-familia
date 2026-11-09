class_name KeyboardMap
extends Control
## Dibujo del teclado: en amarillo las teclas que se usan, con lo que hacen.

const UNIT: float = 66.0
const GAP: float = 5.0
const ROW_HEIGHT: float = 56.0
const COLOR_USED: Color = Color("#ffcf40")
const COLOR_FREE: Color = Color("#3a404c")
const COLOR_INK: Color = Color("#1b0e2a")
const COLOR_FREE_TEXT: Color = Color("#7a8290")
const LABEL_SIZE: int = 17
const ACTION_SIZE: int = 12
const NOTES_SIZE: int = 21


func _draw() -> void:
	var font: Font = UiStyle.FONT_LOUD
	var y: float = 0.0
	var rows: Array = ControlsPanel.load_rows("keyboard")
	for row: Variant in rows:
		var x: float = 0.0
		for cap: Variant in row:
			var width: float = float(cap[1]) * UNIT - GAP
			if not str(cap[0]).is_empty():
				_draw_cap(font, Rect2(x, y, width, ROW_HEIGHT), str(cap[0]), str(cap[2]))
			x += float(cap[1]) * UNIT
		y += ROW_HEIGHT + GAP
	y += 28.0
	for note: Variant in ControlsPanel.load_rows("notes"):
		draw_string(font, Vector2(0.0, y), str(note), HORIZONTAL_ALIGNMENT_LEFT, -1, GameSettings.font_size(NOTES_SIZE), Color.WHITE)
		y += 34.0


func _draw_cap(font: Font, area: Rect2, label: String, action: String) -> void:
	var used: bool = not action.is_empty()
	draw_rect(area, COLOR_USED if used else COLOR_FREE)
	draw_rect(area, COLOR_INK, false, 2.0)
	var color: Color = COLOR_INK if used else COLOR_FREE_TEXT
	draw_string(font, area.position + Vector2(0.0, 22.0), label, HORIZONTAL_ALIGNMENT_CENTER, area.size.x, LABEL_SIZE, color)
	if used:
		draw_string(font, area.position + Vector2(0.0, 45.0), action, HORIZONTAL_ALIGNMENT_CENTER, area.size.x, ACTION_SIZE, color)

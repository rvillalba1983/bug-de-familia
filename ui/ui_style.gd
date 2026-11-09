class_name UiStyle
extends RefCounted
## Tema común de chapa para botones y paneles.

const COLOR_PLATE: Color = Color("#2b2f38")
const COLOR_HOVER: Color = Color("#3d4250")
const COLOR_EDGE: Color = Color("#ff9a3c")


static func make_theme() -> Theme:
	var theme: Theme = Theme.new()
	theme.set_stylebox(&"normal", &"Button", _box(COLOR_PLATE, COLOR_EDGE))
	theme.set_stylebox(&"hover", &"Button", _box(COLOR_HOVER, Color.WHITE))
	theme.set_stylebox(&"pressed", &"Button", _box(COLOR_EDGE, Color.WHITE))
	theme.set_stylebox(&"focus", &"Button", StyleBoxEmpty.new())
	theme.set_color(&"font_pressed_color", &"Button", Color.BLACK)
	return theme


static func _box(fill: Color, edge: Color) -> StyleBoxFlat:
	var box: StyleBoxFlat = StyleBoxFlat.new()
	box.bg_color = fill
	box.border_color = edge
	box.set_border_width_all(3)
	box.set_corner_radius_all(3)
	box.set_content_margin_all(8.0)
	return box

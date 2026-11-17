class_name MenuButtonStyle
extends RefCounted
## Carteles de menú compartidos por la carga y la historia.
## Paleta «Cuñado Radiactivo»: tinta gruesa, acento cian/butano y Bangers.
## No se usan colores fuera de Palette ni el tema por defecto de Godot.

const FONT_SIZE: int = 34
const INSET: float = 6.0

static func make_button(container: Control, index: int, label: String, callback: Callable, \
		size: Vector2, icon_path: String = "") -> Button:
	var accent: Color = Palette.CIAN if index % 2 == 0 else Palette.BUTANO
	var row: Control = Control.new()
	row.custom_minimum_size = size

	# Borde de tinta con franja de acento: acabado de cartel de art/shared/fuentes.
	var ring: Panel = Panel.new()
	ring.size = size
	ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var ring_normal: StyleBoxFlat = ring_box(accent)
	var ring_hover: StyleBoxFlat = ring_box(Palette.OBRA)
	var ring_pressed: StyleBoxFlat = ring_box(Palette.HUESO)
	ring.add_theme_stylebox_override(&"panel", ring_normal)
	row.add_child(ring)

	var btn: Button = Button.new()
	btn.position = Vector2(INSET, INSET)
	btn.size = size - Vector2(INSET * 2.0, INSET * 2.0)
	btn.text = label
	btn.alignment = HORIZONTAL_ALIGNMENT_CENTER
	btn.add_theme_font_override(&"font", UiStyle.FONT_LOUD)
	btn.add_theme_font_size_override(&"font_size", FONT_SIZE)
	btn.add_theme_color_override(&"font_color", Palette.HUESO)
	btn.add_theme_color_override(&"font_hover_color", Palette.OBRA)
	btn.add_theme_color_override(&"font_pressed_color", Palette.INK)
	btn.add_theme_color_override(&"font_hover_pressed_color", Palette.INK)
	btn.add_theme_color_override(&"font_disabled_color", Palette.HIERRO)
	btn.add_theme_color_override(&"font_outline_color", Palette.INK)
	btn.add_theme_color_override(&"icon_disabled_color", Palette.HIERRO)
	btn.add_theme_constant_override(&"outline_size", 5)
	btn.add_theme_constant_override(&"h_separation", 14)
	btn.add_theme_stylebox_override(&"normal", face_box(Palette.MORA))
	btn.add_theme_stylebox_override(&"hover", face_box(Palette.BERENJENA))
	btn.add_theme_stylebox_override(&"pressed", face_box(Palette.BUTANO))
	btn.add_theme_stylebox_override(&"disabled", face_box(Palette.INK))
	btn.add_theme_stylebox_override(&"focus", StyleBoxEmpty.new())

	if not icon_path.is_empty():
		var icon: Texture2D = load(icon_path) as Texture2D
		if icon != null:
			btn.icon = icon
			btn.expand_icon = false
			btn.add_theme_constant_override(&"icon_max_width", 64)

	btn.mouse_entered.connect(func() -> void: _hover_ring(btn, ring, ring_hover))
	btn.mouse_exited.connect(func() -> void: set_ring(ring, ring_normal))
	btn.button_down.connect(func() -> void: set_ring(ring, ring_pressed))
	btn.button_up.connect(func() -> void: _hover_ring(btn, ring, ring_hover))
	if callback.is_valid():
		btn.pressed.connect(callback)
	row.add_child(btn)
	container.add_child(row)
	return btn


static func _hover_ring(btn: Button, ring: Panel, box: StyleBoxFlat) -> void:
	if not btn.disabled:
		set_ring(ring, box)


static func set_ring(ring: Panel, box: StyleBoxFlat) -> void:
	ring.add_theme_stylebox_override(&"panel", box)


static func backing_box() -> StyleBoxFlat:
	var box: StyleBoxFlat = StyleBoxFlat.new()
	box.bg_color = Color(Palette.INK.r, Palette.INK.g, Palette.INK.b, 0.72)
	box.border_color = Palette.INK
	box.set_border_width_all(4)
	box.set_corner_radius_all(14)
	return box


static func ring_box(accent: Color) -> StyleBoxFlat:
	var box: StyleBoxFlat = StyleBoxFlat.new()
	box.bg_color = accent
	box.border_color = Palette.INK
	box.set_border_width_all(6)
	box.set_corner_radius_all(12)
	box.shadow_color = Color(Palette.INK.r, Palette.INK.g, Palette.INK.b, 0.8)
	box.shadow_size = 10
	box.shadow_offset = Vector2(4.0, 6.0)
	return box


static func face_box(fill: Color) -> StyleBoxFlat:
	var box: StyleBoxFlat = StyleBoxFlat.new()
	box.bg_color = fill
	box.border_color = Palette.INK
	box.set_border_width_all(4)
	box.set_corner_radius_all(8)
	box.set_content_margin_all(8)
	return box

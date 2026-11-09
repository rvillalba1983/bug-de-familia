class_name ConversionScreen
extends CanvasLayer
## Pantallas de la conversión. Solo presenta; las reglas están en el director.
## Tiempo parado: el mundo se ve quieto y sin color, con el objeto iluminado.
## Valores provisionales, a ajustar al probar.

const BACKDROP_SHADER: Shader = preload("res://conversion/conversion_backdrop.gdshader")
const VIEW_SIZE: Vector2 = Vector2(1920.0, 1080.0)
const PANEL_HALF_WIDTH: float = 540.0
const PANEL_MARGIN: float = 34.0
const FADE_TIME: float = 0.18
const TWO_COLUMNS_FROM: int = 5
const TIME_LIMIT_SHOWN: float = 5.0
const PANIC_FRACTION: float = 0.45
const PANIC_SHAKE: float = 9.0
const VERDICT_SHAKE: float = 16.0
const SHAKE_DECAY: float = 60.0

var buttons: Array[Button] = []

var _backdrop: ColorRect
var _shaker: Control
var _panel: PanelContainer
var _box: VBoxContainer
var _options: GridContainer
var _bar: ColorRect
var _count: Label
var _taunt: PanelContainer
var _panel_style: StyleBoxFlat
var _shake: float = 0.0
var _theme: Theme


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 15
	visible = false


func _process(delta: float) -> void:
	if _shaker == null:
		return
	_shake = maxf(_shake - SHAKE_DECAY * delta, 0.0)
	_shaker.position = Vector2.from_angle(randf() * TAU) * _shake


## Para el mundo en pantalla e ilumina el objeto. La posición va en coordenadas de lienzo.
func begin(focus: Vector2) -> void:
	_ensure_backdrop()
	var material_used: ShaderMaterial = _backdrop.material
	material_used.set_shader_parameter(&"focus", focus / VIEW_SIZE)
	material_used.set_shader_parameter(&"amount", 0.0)
	create_tween().tween_property(material_used, "shader_parameter/amount", 1.0, FADE_TIME)


## Cada entrada es [texto, Callable].
func show_choices(title: String, entries: Array, with_timer: bool = false) -> void:
	_reset(title)
	if with_timer:
		_add_timer()
	_add_options(entries.size())
	for entry: Array in entries:
		_add_button(entry[0] as String, entry[1] as Callable)


func show_message(title: String, body: String) -> void:
	_reset(title)
	var label: Label = Label.new()
	label.text = body
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_box.add_child(label)
	_add_options(1)


## Resultado de una pregunta: el panel se tiñe y, si has fallado, tiembla.
func show_verdict(correct: bool, title: String, body: String) -> void:
	show_message(title, body)
	_panel_style.border_color = Palette.ACIDO if correct else Palette.ROSA
	(_box.get_child(0).get_child(0) as Label).add_theme_color_override(
		&"font_color", Palette.ACIDO if correct else Palette.ROSA
	)
	if not correct:
		_shake = VERDICT_SHAKE


func add_accept(text: String, on_accept: Callable) -> void:
	_add_button(text, on_accept)


## Inhabilita una opción y añade un comentario, como el de una IA.
func add_remark(text: String, disabled_option: int) -> void:
	var label: Label = Label.new()
	label.text = text
	label.add_theme_color_override(&"font_color", Palette.OBRA)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_box.add_child(label)
	if disabled_option >= 0 and disabled_option < buttons.size():
		buttons[disabled_option].disabled = true


## Una IA se burla desde un bocadillo torcido sobre el panel.
func show_taunt(speaker: String, text: String, color: Color) -> void:
	_taunt = PanelContainer.new()
	_taunt.add_theme_stylebox_override(&"panel", _flat(Palette.HUESO, color, 4, 12.0))
	var label: Label = Label.new()
	label.text = "%s: %s" % [speaker, text]
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(620.0, 0.0)
	label.add_theme_color_override(&"font_color", Palette.INK)
	label.add_theme_font_size_override(&"font_size", 26)
	_taunt.add_child(label)
	_shaker.add_child(_taunt)
	_taunt.position = Vector2(1240.0, 150.0)
	_taunt.rotation = deg_to_rad(-3.0)
	_taunt.scale = Vector2.ZERO
	_taunt.pivot_offset = Vector2(310.0, 40.0)
	create_tween().tween_property(_taunt, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## Cuenta atrás: cuanto menos queda, más roja, más grande y más nerviosa.
func set_time_fraction(fraction: float) -> void:
	if _bar == null:
		return
	var left: float = clampf(fraction, 0.0, 1.0)
	_bar.scale.x = left
	var danger: float = clampf(1.0 - left / PANIC_FRACTION, 0.0, 1.0)
	var color: Color = Palette.OBRA.lerp(Palette.ROSA, 1.0 - left)
	_bar.color = color
	_count.text = ("%.1f" % (left * TIME_LIMIT_SHOWN)).replace(".", ",")
	_count.add_theme_color_override(&"font_color", color)
	_count.scale = Vector2.ONE * (1.0 + 0.3 * danger * absf(sin(left * 40.0)))
	_shake = maxf(_shake, PANIC_SHAKE * danger)


func close() -> void:
	visible = false
	_clear()
	if _backdrop != null:
		_backdrop.queue_free()
		_backdrop = null


func _ensure_backdrop() -> void:
	if _backdrop != null:
		return
	_backdrop = ColorRect.new()
	_backdrop.size = VIEW_SIZE
	var made: ShaderMaterial = ShaderMaterial.new()
	made.shader = BACKDROP_SHADER
	made.set_shader_parameter(&"aspect", VIEW_SIZE.aspect())
	made.set_shader_parameter(&"focus", Vector2(-2.0, -2.0))
	_backdrop.material = made
	add_child(_backdrop)
	move_child(_backdrop, 0)


func _reset(title: String) -> void:
	_clear()
	visible = true
	buttons.clear()
	_ensure_backdrop()
	_shaker = Control.new()
	_shaker.size = VIEW_SIZE
	_shaker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_shaker.theme = _screen_theme()
	add_child(_shaker)
	_panel = PanelContainer.new()
	_panel_style = _flat(Palette.INK, Palette.BERENJENA, 5, 18.0)
	_panel.add_theme_stylebox_override(&"panel", _panel_style)
	_panel.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_panel.offset_left = -PANEL_HALF_WIDTH
	_panel.offset_right = PANEL_HALF_WIDTH
	_panel.offset_bottom = -PANEL_MARGIN
	_panel.offset_top = -PANEL_MARGIN
	_shaker.add_child(_panel)
	_box = VBoxContainer.new()
	_box.add_theme_constant_override(&"separation", 12)
	_panel.add_child(_box)
	var header: HBoxContainer = HBoxContainer.new()
	_box.add_child(header)
	var heading: Label = Label.new()
	heading.text = title
	heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.add_theme_font_size_override(&"font_size", 30)
	header.add_child(heading)


func _add_timer() -> void:
	_count = Label.new()
	_count.custom_minimum_size = Vector2(130.0, 0.0)
	_count.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_count.add_theme_font_size_override(&"font_size", 58)
	_count.pivot_offset = Vector2(90.0, 40.0)
	_box.get_child(0).add_child(_count)
	var track: ColorRect = ColorRect.new()
	track.color = Palette.MORA
	track.custom_minimum_size = Vector2(0.0, 16.0)
	_box.add_child(track)
	_bar = ColorRect.new()
	_bar.set_anchors_preset(Control.PRESET_FULL_RECT)
	track.add_child(_bar)
	set_time_fraction(1.0)


func _add_options(count: int) -> void:
	_options = GridContainer.new()
	_options.columns = 2 if count >= TWO_COLUMNS_FROM else 1
	_options.add_theme_constant_override(&"h_separation", 12)
	_options.add_theme_constant_override(&"v_separation", 8)
	_box.add_child(_options)


func _add_button(text: String, on_press: Callable) -> void:
	var button: Button = Button.new()
	button.text = text
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.pressed.connect(on_press)
	_options.add_child(button)
	buttons.append(button)


func _screen_theme() -> Theme:
	if _theme != null:
		return _theme
	_theme = Theme.new()
	_theme.set_font_size(&"font_size", &"Label", 24)
	_theme.set_font_size(&"font_size", &"Button", 24)
	_theme.set_color(&"font_color", &"Label", Palette.HUESO)
	_theme.set_color(&"font_color", &"Button", Palette.HUESO)
	_theme.set_color(&"font_hover_color", &"Button", Palette.INK)
	_theme.set_color(&"font_focus_color", &"Button", Palette.HUESO)
	_theme.set_color(&"font_pressed_color", &"Button", Palette.INK)
	_theme.set_color(&"font_disabled_color", &"Button", Palette.HIERRO_OSCURO)
	_theme.set_stylebox(&"normal", &"Button", _flat(Palette.MORA, Palette.BERENJENA, 3, 8.0))
	_theme.set_stylebox(&"hover", &"Button", _flat(Palette.ACIDO, Palette.HUESO, 3, 8.0))
	_theme.set_stylebox(&"pressed", &"Button", _flat(Palette.OBRA, Palette.HUESO, 3, 8.0))
	_theme.set_stylebox(&"focus", &"Button", _flat(Color.TRANSPARENT, Palette.CIAN, 3, 8.0))
	_theme.set_stylebox(&"disabled", &"Button", _flat(Palette.INK, Palette.MORA, 3, 8.0))
	return _theme


func _flat(fill: Color, border: Color, width: int, margin: float) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(width)
	style.set_corner_radius_all(6)
	style.set_content_margin_all(margin)
	return style


func _clear() -> void:
	_bar = null
	_count = null
	_taunt = null
	_options = null
	_box = null
	_panel = null
	_shake = 0.0
	if _shaker != null:
		_shaker.queue_free()
		_shaker = null

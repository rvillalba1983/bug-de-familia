class_name ControlsPanel
extends CanvasLayer
## Chapa torcida con el teclado y el ratón dibujados. F1 la abre, Esc la cierra, y pausa mientras se lee.

const DATA_PATH: String = "res://data/ui/controls.json"
const PLATE: Rect2 = Rect2(230.0, 120.0, 1460.0, 840.0)
const OPTIONS_X: float = 980.0
const TILT: float = -0.012
const COLOR_DIM: Color = Color(0.0, 0.0, 0.0, 0.6)
const COLOR_PLATE: Color = Color("#2b2f38")
const COLOR_EDGE: Color = Color("#ff9a3c")
const COLOR_RIVET: Color = Color("#8a93a3")
const COLOR_KEY: Color = Color("#ffcf40")

signal filter_changed

var pause: TacticalPause
var is_open: bool = false

var _plate: Control
var _options: VBoxContainer


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 11
	visible = false


func _ready() -> void:
	var dim: ColorRect = ColorRect.new()
	dim.color = COLOR_DIM
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)
	_plate = Control.new()
	_plate.position = PLATE.position
	_plate.size = PLATE.size
	_plate.pivot_offset = PLATE.size * 0.5
	_plate.rotation = TILT
	_plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_plate.draw.connect(_draw_plate)
	add_child(_plate)
	_build_rows()
	_build_options()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_echo():
		return
	var wanted: StringName = &"close_panel" if is_open else &"help"
	if event.is_action_pressed(wanted) and (is_open or not get_tree().paused):
		toggle()
		get_viewport().set_input_as_handled()


func toggle() -> void:
	is_open = not is_open
	visible = is_open
	if is_open:
		pause.begin_modal()
	else:
		pause.end_modal()


static func load_rows(section: String) -> Array:
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH))
	if not data is Dictionary or not (data as Dictionary).has(section):
		push_error("Falta la sección %s en %s" % [section, DATA_PATH])
		return []
	return data[section]


func _build_rows() -> void:
	var title: Label = Label.new()
	title.text = "CONTROLES (o cómo no morir por pulsar lo que no es)"
	title.position = Vector2(48.0, 30.0)
	title.add_theme_font_override(&"font", UiStyle.FONT_LOUD)
	title.add_theme_font_size_override(&"font_size", 30)
	title.add_theme_color_override(&"font_color", COLOR_EDGE)
	_plate.add_child(title)
	var keyboard: KeyboardMap = KeyboardMap.new()
	keyboard.position = Vector2(40.0, 92.0)
	_plate.add_child(keyboard)
	var mouse: MouseMap = MouseMap.new()
	mouse.position = Vector2(OPTIONS_X, 400.0)
	_plate.add_child(mouse)


func _build_options() -> void:
	GameSettings.ensure_loaded()
	_options = VBoxContainer.new()
	_options.position = Vector2(OPTIONS_X, 96.0)
	_options.custom_minimum_size = Vector2(430.0, 0.0)
	_options.theme = UiStyle.make_theme()
	_options.add_theme_constant_override(&"separation", 12)
	_plate.add_child(_options)
	_refresh_options()


func _refresh_options() -> void:
	for child: Node in _options.get_children():
		child.queue_free()
	_add_option("Texto: %d %%" % roundi(GameSettings.text_scale * 100.0), _cycle_text)
	_add_option("Reducir temblores y destellos: %s" % ("sí" if GameSettings.reduce_motion else "no"), _toggle_motion)
	_add_option("Alto contraste: %s" % ("sí" if GameSettings.high_contrast else "no"), _toggle_contrast)
	_add_option("Música: %d %%" % roundi(GameSettings.music_volume * 100.0), _cycle_music)
	_add_option("Voces: %d %%" % roundi(GameSettings.voice_volume * 100.0), _cycle_voice)


func _add_option(text: String, action: Callable) -> void:
	var button: Button = Button.new()
	button.text = text
	button.add_theme_font_size_override(&"font_size", 22)
	button.pressed.connect(action)
	_options.add_child(button)


func _changed() -> void:
	GameSettings.save()
	AudioMixer.apply_settings()
	filter_changed.emit()
	_refresh_options()


func _cycle_text() -> void:
	GameSettings.text_scale = GameSettings.cycle(GameSettings.TEXT_SCALES, GameSettings.text_scale)
	_changed()


func _toggle_motion() -> void:
	GameSettings.reduce_motion = not GameSettings.reduce_motion
	_changed()


func _toggle_contrast() -> void:
	GameSettings.high_contrast = not GameSettings.high_contrast
	_changed()


func _cycle_music() -> void:
	GameSettings.music_volume = GameSettings.cycle(GameSettings.VOLUMES, GameSettings.music_volume)
	_changed()


func _cycle_voice() -> void:
	GameSettings.voice_volume = GameSettings.cycle(GameSettings.VOLUMES, GameSettings.voice_volume)
	_changed()


func _cell(text: String, color: Color) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.add_theme_font_size_override(&"font_size", 25)
	label.add_theme_color_override(&"font_color", color)
	return label


func _draw_plate() -> void:
	var area: Rect2 = Rect2(Vector2.ZERO, PLATE.size)
	_plate.draw_rect(area, COLOR_PLATE)
	_plate.draw_rect(area, COLOR_EDGE, false, 5.0)
	for corner: Vector2 in [Vector2(18, 18), Vector2(PLATE.size.x - 18, 18),
			Vector2(18, PLATE.size.y - 18), PLATE.size - Vector2(18, 18)]:
		_plate.draw_circle(corner, 7.0, COLOR_RIVET)

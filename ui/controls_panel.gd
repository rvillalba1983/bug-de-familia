class_name ControlsPanel
extends CanvasLayer
## Chapa torcida con todos los controles. F1 la abre y la cierra, y pausa mientras se lee.

const DATA_PATH: String = "res://data/ui/controls.json"
const PLATE: Rect2 = Rect2(440.0, 120.0, 1040.0, 840.0)
const TILT: float = -0.012
const COLOR_DIM: Color = Color(0.0, 0.0, 0.0, 0.6)
const COLOR_PLATE: Color = Color("#2b2f38")
const COLOR_EDGE: Color = Color("#ff9a3c")
const COLOR_RIVET: Color = Color("#8a93a3")
const COLOR_KEY: Color = Color("#ffcf40")

var pause: TacticalPause
var is_open: bool = false

var _plate: Control


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


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"help") and not event.is_echo():
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
	title.add_theme_font_size_override(&"font_size", 30)
	title.add_theme_color_override(&"font_color", COLOR_EDGE)
	_plate.add_child(title)
	var grid: GridContainer = GridContainer.new()
	grid.columns = 2
	grid.position = Vector2(48.0, 96.0)
	grid.add_theme_constant_override(&"h_separation", 44)
	grid.add_theme_constant_override(&"v_separation", 8)
	_plate.add_child(grid)
	for row: Variant in load_rows("full"):
		grid.add_child(_cell(str(row[0]), COLOR_KEY))
		grid.add_child(_cell(str(row[1]), Color.WHITE))


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

class_name BattleOffer
extends CanvasLayer
## Al estallar una batalla: unirte a un bando, mirarla o pasar. Teclas 1 a 4 o clic.

signal chosen(option: int)

const PANEL: Rect2 = Rect2(560.0, 300.0, 800.0, 440.0)
const OPTION_COUNT: int = 4

var is_open: bool = false

var _root: Control
var _director: BattleDirector


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 12


func open(director: BattleDirector) -> void:
	if is_open:
		return
	_director = director
	is_open = true
	director.level.pause.begin_modal()
	_build()


func close() -> void:
	if not is_open:
		return
	is_open = false
	_root.queue_free()
	_director.level.pause.end_modal()


func _unhandled_input(event: InputEvent) -> void:
	if not is_open:
		return
	if event.is_action_pressed(&"close_panel") and not event.is_echo():
		get_viewport().set_input_as_handled()
		chosen.emit(OPTION_COUNT - 1)
		return
	for index: int in range(OPTION_COUNT):
		if event.is_action_pressed(StringName("action_%d" % (index + 1))) and not event.is_echo():
			get_viewport().set_input_as_handled()
			chosen.emit(index)
			return


func _build() -> void:
	var data: Dictionary = _director.data
	_root = Control.new()
	_root.theme = UiStyle.make_theme()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_root)
	var dim: ColorRect = ColorRect.new()
	dim.color = Color(0.0, 0.0, 0.0, 0.6)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.add_child(dim)
	var plate: ColorRect = ColorRect.new()
	plate.color = Color("#2b2f38")
	plate.position = PANEL.position
	plate.size = PANEL.size
	plate.rotation = -0.012
	_root.add_child(plate)
	var title: Label = Label.new()
	title.text = str(data["offer_title"])
	title.position = Vector2(50.0, 36.0)
	title.add_theme_font_size_override(&"font_size", 40)
	title.add_theme_color_override(&"font_color", Color("#ff9a3c"))
	plate.add_child(title)
	var names: Dictionary = data["names"]
	var texts: Array[String] = [
		str(data["offer_join"]) % names["jubilado"], str(data["offer_join"]) % names["mohocrata"],
		str(data["offer_watch"]), str(data["offer_leave"]),
	]
	for index: int in range(texts.size()):
		var button: Button = Button.new()
		button.text = "%d. %s" % [index + 1, texts[index]]
		button.position = Vector2(50.0, 130.0 + float(index) * 72.0)
		button.size = Vector2(700.0, 60.0)
		button.add_theme_font_size_override(&"font_size", 26)
		button.pressed.connect(func() -> void: chosen.emit(index))
		plate.add_child(button)

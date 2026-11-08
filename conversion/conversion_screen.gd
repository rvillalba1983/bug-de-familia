class_name ConversionScreen
extends CanvasLayer
## Pantallas de la conversión. Solo presenta; las reglas están en el director.

var buttons: Array[Button] = []

var _box: VBoxContainer
var _bar: ProgressBar
var _backdrop: ColorRect


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 15
	visible = false


## Cada entrada es [texto, Callable].
func show_choices(title: String, entries: Array, with_timer: bool = false) -> void:
	_reset(title)
	if with_timer:
		_bar = ProgressBar.new()
		_bar.show_percentage = false
		_bar.max_value = 1.0
		_bar.custom_minimum_size = Vector2(0.0, 12.0)
		_box.add_child(_bar)
	for entry: Array in entries:
		var button: Button = Button.new()
		button.text = entry[0]
		button.pressed.connect(entry[1] as Callable)
		_box.add_child(button)
		buttons.append(button)


func show_message(title: String, body: String) -> void:
	_reset(title)
	var label: Label = Label.new()
	label.text = body
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_box.add_child(label)


func add_accept(text: String, on_accept: Callable) -> void:
	var button: Button = Button.new()
	button.text = text
	button.pressed.connect(on_accept)
	_box.add_child(button)
	buttons.append(button)


## Inhabilita una opción y añade un comentario, como el de una IA.
func add_remark(text: String, disabled_option: int) -> void:
	var label: Label = Label.new()
	label.text = text
	_box.add_child(label)
	if disabled_option >= 0 and disabled_option < buttons.size():
		buttons[disabled_option].disabled = true


func set_time_fraction(fraction: float) -> void:
	if _bar != null:
		_bar.value = fraction


func close() -> void:
	visible = false
	_clear()


func _reset(title: String) -> void:
	_clear()
	visible = true
	buttons.clear()
	_backdrop = ColorRect.new()
	_backdrop.color = Color(0.05, 0.05, 0.08, 0.9)
	_backdrop.size = Vector2(1920.0, 1080.0)
	add_child(_backdrop)
	_box = VBoxContainer.new()
	_box.position = Vector2(460.0, 300.0)
	_box.custom_minimum_size = Vector2(1000.0, 0.0)
	_box.add_theme_constant_override(&"separation", 14)
	add_child(_box)
	var heading: Label = Label.new()
	heading.text = title
	heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	heading.add_theme_font_size_override(&"font_size", 28)
	_box.add_child(heading)


func _clear() -> void:
	_bar = null
	if _box != null:
		_box.queue_free()
		_box = null
		_backdrop.queue_free()
		_backdrop = null

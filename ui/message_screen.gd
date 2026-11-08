class_name MessageScreen
extends CanvasLayer
## Pantalla con un título y opciones, para el menú inicial y el fin de partida.

var options: Array[Button] = []


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 20


## Cada opción es [clave de texto, Callable].
func setup(title_key: String, entries: Array) -> void:
	var backdrop: ColorRect = ColorRect.new()
	backdrop.color = Color(0.05, 0.05, 0.08, 0.92)
	backdrop.size = Vector2(1920.0, 1080.0)
	add_child(backdrop)
	var box: VBoxContainer = VBoxContainer.new()
	box.position = Vector2(760.0, 400.0)
	box.custom_minimum_size = Vector2(400.0, 0.0)
	box.add_theme_constant_override(&"separation", 16)
	add_child(box)
	var title: Label = Label.new()
	title.text = tr(title_key)
	title.add_theme_font_size_override(&"font_size", 34)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	for entry: Array in entries:
		var button: Button = Button.new()
		button.text = tr(entry[0] as String)
		button.pressed.connect(entry[1] as Callable)
		box.add_child(button)
		options.append(button)

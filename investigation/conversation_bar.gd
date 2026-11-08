class_name ConversationBar
extends CanvasLayer
## Opciones del jugador en la parte inferior, sin ventana intrusiva.

var buttons: Array[Button] = []

var _box: VBoxContainer


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 12


## Cada entrada es [texto, Callable].
func show_options(entries: Array) -> void:
	clear()
	_box = VBoxContainer.new()
	_box.position = Vector2(420.0, 800.0)
	_box.custom_minimum_size = Vector2(1080.0, 0.0)
	add_child(_box)
	var number: int = 1
	for entry: Array in entries:
		var button: Button = Button.new()
		button.text = "%d. %s" % [number, entry[0]]
		button.pressed.connect(entry[1] as Callable)
		_box.add_child(button)
		buttons.append(button)
		number += 1


func clear() -> void:
	buttons.clear()
	if _box != null:
		_box.queue_free()
		_box = null

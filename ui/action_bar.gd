class_name ActionBar
extends Label
## Muestra las acciones activas y su tecla.

var body: ModularBody:
	set(value):
		body = value
		body.changed.connect(refresh)
		refresh()


func _ready() -> void:
	position = Vector2(24.0, 1000.0)
	add_theme_font_size_override(&"font_size", 20)


func refresh() -> void:
	var parts: Array[String] = []
	var actions: Array = body.active_actions()
	for index: int in range(mini(actions.size(), ActionSystem.MAX_KEYS)):
		parts.append("%d %s" % [index + 1, actions[index]["name"]])
	text = "   ".join(parts)

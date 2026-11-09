class_name PauseFog
extends CanvasLayer
## Niebla y oscuridad sobre el mundo durante la pausa táctica, por debajo de la interfaz.

const SHADER: Shader = preload("res://ui/pause_fog.gdshader")
const FADE_TIME: float = 0.2

var material: ShaderMaterial


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 1
	visible = false


func _ready() -> void:
	var rect: ColorRect = ColorRect.new()
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	material = ShaderMaterial.new()
	material.shader = SHADER
	rect.material = material
	add_child(rect)


func _set_strength(value: float) -> void:
	material.set_shader_parameter(&"strength", value)


func set_shown(shown: bool) -> void:
	var visible_before: bool = visible
	visible = true
	var fade: Tween = create_tween()
	var start: float = float(material.get_shader_parameter(&"strength")) if visible_before else 0.0
	fade.tween_method(_set_strength, start, 1.0 if shown else 0.0, FADE_TIME)
	if not shown:
		fade.tween_callback(hide)

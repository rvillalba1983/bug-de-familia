class_name ScreenFilter
extends CanvasLayer
## Acabado común del mundo (grano, viñeta, brillo) y niebla de la pausa táctica,
## siempre por debajo de la interfaz.

const SHADER: Shader = preload("res://ui/screen_filter.gdshader")
const FADE_TIME: float = 0.2

var material: ShaderMaterial

var _strength: float = 0.0


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 1


func _ready() -> void:
	var rect: ColorRect = ColorRect.new()
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	material = ShaderMaterial.new()
	material.shader = SHADER
	rect.material = material
	add_child(rect)
	apply_settings()


func apply_settings() -> void:
	material.set_shader_parameter(&"grain", 0.0 if GameSettings.reduce_motion else 0.035)
	material.set_shader_parameter(&"contrast", 1.28 if GameSettings.high_contrast else 1.0)


func _set_strength(value: float) -> void:
	_strength = value
	material.set_shader_parameter(&"strength", value)


func set_shown(shown: bool) -> void:
	create_tween().tween_method(_set_strength, _strength, 1.0 if shown else 0.0, FADE_TIME)

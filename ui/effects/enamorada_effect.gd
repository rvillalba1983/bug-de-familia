class_name EnamoradaEffect
extends RichTextEffect
## Letras que laten (provisional).
var bbcode: String = "enamorada"


func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	if GameSettings.reduce_motion:
		return true
	var t: float = char_fx.elapsed_time
	var pulse: float = absf(sin(t * 4.0 + float(char_fx.relative_index) * 0.5))
	char_fx.offset = Vector2(0.0, -pulse * 4.0)
	char_fx.color = char_fx.color.lerp(Color("#ff66b2"), pulse * 0.4)
	return true

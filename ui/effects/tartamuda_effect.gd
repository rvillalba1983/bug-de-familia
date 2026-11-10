class_name TartamudaEffect
extends RichTextEffect
## Letras que tiemblan y se repiten (provisional).
var bbcode: String = "tartamuda"


func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	if GameSettings.reduce_motion:
		return true
	var t: float = char_fx.elapsed_time
	var shake: float = sin(t * 40.0 + float(char_fx.relative_index) * 7.0) * 3.0
	char_fx.offset = Vector2(shake, sin(t * 30.0 + float(char_fx.relative_index)) * 2.0)
	return true

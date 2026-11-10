class_name EnfadadaEffect
extends RichTextEffect
## Texto que vibra (provisional).
var bbcode: String = "enfadada"


func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	if GameSettings.reduce_motion:
		return true
	var t: float = char_fx.elapsed_time
	var vib: float = sin(t * 60.0 + float(char_fx.relative_index) * 11.0) * 4.0
	char_fx.offset = Vector2(vib, vib * 0.5)
	return true

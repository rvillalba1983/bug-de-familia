class_name CorruptoEffect
extends RichTextEffect
## Caracteres corruptos, como al quedarse sin tokens (provisional).
## Azar propio y determinista: no toca el RNG global de la partida.
var bbcode: String = "corrupto"


func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	if GameSettings.reduce_motion:
		return true
	var indice: float = float(char_fx.relative_index)
	var t: float = char_fx.elapsed_time
	var semi: float = sin(indice * 12.9898 + floorf(t * 8.0) * 78.233) * 43758.5453
	var ruido: float = semi - floorf(semi)
	char_fx.offset = Vector2((ruido - 0.5) * 6.0, sin(indice * 3.7 + t * 9.0) * 2.0)
	if ruido < 0.15:
		char_fx.color = Color("#00ff00")
	return true

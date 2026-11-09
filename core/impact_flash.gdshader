shader_type canvas_item;
// Destello blanco de los golpes. Pinta encima del color, también sobre los tonos oscuros.
uniform float flash : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	COLOR.rgb = mix(COLOR.rgb, vec3(1.0), flash);
}

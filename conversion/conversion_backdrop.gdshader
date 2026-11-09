shader_type canvas_item;
// Fondo de convertir: el mundo parado, sin color y a oscuras, salvo el objeto elegido.
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform vec2 focus = vec2(0.5);
uniform float aspect = 1.7778;
uniform float amount : hint_range(0.0, 1.0) = 1.0;
uniform float radius = 0.1;
uniform vec3 ring_color = vec3(0.75, 0.38, 1.0);

void fragment() {
	vec3 world = texture(screen_texture, SCREEN_UV).rgb;
	float grey = dot(world, vec3(0.3, 0.59, 0.11));
	vec2 offset = (SCREEN_UV - focus) * vec2(aspect, 1.0);
	float distance_to_focus = length(offset);
	float lit = 1.0 - smoothstep(radius * 0.8, radius * 1.05, distance_to_focus);
	float pulse = 0.5 + 0.5 * sin(TIME * 7.0);
	float ring = smoothstep(0.012 + 0.006 * pulse, 0.0, abs(distance_to_focus - radius));
	vec3 dark = mix(vec3(grey) * vec3(0.26, 0.2, 0.36), world * 1.12, lit);
	dark += ring_color * ring * (0.65 + 0.35 * pulse);
	COLOR = vec4(mix(world, dark, amount), 1.0);
}

shader_type canvas_item;
// Pausa táctica: mundo sin color, oscuro y con niebla moviéndose.

uniform sampler2D screen_texture : hint_screen_texture, filter_linear;
uniform float strength : hint_range(0.0, 1.0) = 0.0;
uniform vec3 fog_color : source_color = vec3(0.28, 0.2, 0.46);

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(
		mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x),
		mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

float fbm(vec2 p) {
	float total = 0.0;
	float amp = 0.5;
	for (int i = 0; i < 4; i++) {
		total += noise(p) * amp;
		p *= 2.1;
		amp *= 0.5;
	}
	return total;
}

void fragment() {
	vec3 scene = texture(screen_texture, SCREEN_UV).rgb;
	float grey = dot(scene, vec3(0.299, 0.587, 0.114));
	vec3 dull = mix(scene, vec3(grey), 0.88) * 0.52;
	vec2 p = UV * vec2(5.0, 3.0);
	float fog = fbm(p + vec2(TIME * 0.09, TIME * 0.04) + fbm(p - TIME * 0.05));
	vec3 fogged = mix(dull, fog_color, smoothstep(0.3, 0.8, fog) * 0.5);
	float vignette = smoothstep(0.35, 0.95, distance(UV, vec2(0.5)));
	fogged *= 1.0 - 0.55 * vignette;
	COLOR = vec4(mix(scene, fogged, strength), 1.0);
}

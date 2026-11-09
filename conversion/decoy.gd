class_name Decoy
extends Node2D
## Holograma, clon o corrillo de seguidores de Lumi: hace ruido de vez en cuando y atrae miradas.

const NOISE_RADIUS: float = 360.0
const NOISE_INTERVAL: float = 2.2
const SPREAD: float = 46.0
const COLOR_HOLOGRAM: Color = Color(0.2, 0.9, 1.0, 0.65)
const COLOR_FOLLOWER: Color = Color("#ff4fb0")
const COLOR_PHONE: Color = Color("#fff36a")

## Si es mayor que 0, dibuja a ese número de seguidores en vez del holograma.
var followers: int = 0

var _left: float = 0.0
var _next_noise: float = 0.0
var _bus: NoiseBus
var _clock: float = 0.0


func setup(at: Vector2, duration: float, bus: NoiseBus) -> void:
	position = at
	_left = duration
	_bus = bus


func _process(delta: float) -> void:
	_left -= delta
	_clock += delta
	if _left <= 0.0:
		queue_free()
		return
	_next_noise -= delta
	if _next_noise <= 0.0:
		_next_noise = NOISE_INTERVAL
		_bus.emit_noise(global_position, NOISE_RADIUS)
	queue_redraw()


func _draw() -> void:
	if followers > 0:
		for index: int in range(followers):
			var angle: float = TAU * float(index) / float(followers) + _clock * 0.4
			_draw_follower(Vector2.from_angle(angle) * Vector2(SPREAD, SPREAD * 0.55), index)
		return
	var flicker: float = 0.7 + 0.3 * sin(_clock * 18.0)
	var color: Color = Color(COLOR_HOLOGRAM, COLOR_HOLOGRAM.a * flicker)
	draw_circle(Vector2(0.0, 2.0), 22.0, Color(COLOR_HOLOGRAM, 0.25))
	draw_rect(Rect2(-14.0, -58.0, 28.0, 40.0), color)
	draw_circle(Vector2(0.0, -68.0), 13.0, color)
	draw_line(Vector2(-10.0, -18.0), Vector2(-12.0, 0.0), color, 8.0)
	draw_line(Vector2(10.0, -18.0), Vector2(12.0, 0.0), color, 8.0)


func _draw_follower(at: Vector2, index: int) -> void:
	var bob: float = sin(_clock * 7.0 + float(index)) * 3.0
	draw_circle(at + Vector2(0.0, 2.0), 12.0, Color(0.0, 0.0, 0.0, 0.3))
	draw_rect(Rect2(at + Vector2(-9.0, -34.0 + bob), Vector2(18.0, 32.0)), COLOR_FOLLOWER)
	draw_circle(at + Vector2(0.0, -42.0 + bob), 10.0, COLOR_FOLLOWER.lightened(0.3))
	draw_rect(Rect2(at + Vector2(10.0, -44.0 + bob), Vector2(7.0, 13.0)), COLOR_PHONE)

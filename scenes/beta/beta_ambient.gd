class_name BetaAmbient
extends Node2D
## Vida de fondo, solo visual: charcos con ondas, moscas, humo, cables y plantas que se mecen
## y copas de árbol que se mueven a otra velocidad. Se dibuja solo cerca del jugador.

const REDRAW: float = 0.05
const NEAR: float = 1200.0
const PUDDLES: Array[Vector2] = [Vector2(1400.0, 1290.0), Vector2(2150.0, 1360.0), Vector2(900.0, 1500.0), Vector2(2900.0, 1250.0)]
const FLIES: Array[Vector2] = [Vector2(1500.0, 1120.0), Vector2(2320.0, 1740.0), Vector2(1880.0, 1480.0)]
const SMOKE: Array[Vector2] = [Vector2(1700.0, 640.0), Vector2(2050.0, 1480.0), Vector2(2600.0, 760.0)]
const CABLES: Array[Array] = [
	[Vector2(1320.0, 1160.0), Vector2(1560.0, 1140.0)], [Vector2(1900.0, 1140.0), Vector2(2140.0, 1160.0)],
	[Vector2(1340.0, 1500.0), Vector2(1600.0, 1520.0)],
]
const PLANTS: Array[Vector2] = [Vector2(1180.0, 1000.0), Vector2(1120.0, 1560.0), Vector2(2260.0, 1100.0), Vector2(860.0, 1240.0), Vector2(2780.0, 1500.0)]
const CANOPIES: Array[Vector2] = [Vector2(220.0, 420.0), Vector2(440.0, 1100.0), Vector2(260.0, 1900.0), Vector2(640.0, 2300.0), Vector2(3480.0, 500.0), Vector2(3600.0, 2100.0), Vector2(860.0, 280.0)]
const CANOPY_PARALLAX: float = 0.09
const CANOPY_CLEAR: float = 170.0
const COLOR_WATER: Color = Color(0.3, 0.8, 0.9, 0.55)
const COLOR_FLY: Color = Color("#1b0e2a")
const COLOR_SMOKE: Color = Color(0.75, 0.72, 0.85, 0.26)
const COLOR_CABLE: Color = Color("#1b0e2a")
const COLOR_PLANT: Color = Color("#2fbf71")
const COLOR_CANOPY: Color = Color(0.1, 0.32, 0.22, 0.72)

var follow: Node2D

var _clock: float = 0.0
var _wait: float = 0.0


func _ready() -> void:
	z_index = 1
	z_as_relative = false


func _process(delta: float) -> void:
	_clock += delta
	_wait -= delta
	if _wait <= 0.0:
		_wait = REDRAW
		queue_redraw()


func _draw() -> void:
	if not is_instance_valid(follow):
		return
	var feet: Vector2 = follow.global_position
	var calm: bool = GameSettings.reduce_motion
	var clock: float = 0.0 if calm else _clock
	for at: Vector2 in PUDDLES:
		if at.distance_to(feet) < NEAR:
			_puddle(at, clock)
	for at: Vector2 in FLIES:
		if at.distance_to(feet) < NEAR:
			_flies(at, clock)
	for at: Vector2 in SMOKE:
		if at.distance_to(feet) < NEAR:
			_smoke(at, clock)
	for cable: Array in CABLES:
		if (cable[0] as Vector2).distance_to(feet) < NEAR:
			_cable(cable[0], cable[1], clock)
	for at: Vector2 in PLANTS:
		if at.distance_to(feet) < NEAR:
			_plant(at, clock)
	var drift: Vector2 = (feet - BetaLayout.world_size * 0.5) * CANOPY_PARALLAX
	for index: int in range(CANOPIES.size()):
		var top: Vector2 = CANOPIES[index] - drift
		if top.distance_to(feet) < NEAR * 1.3:
			_canopy(top, index, clock, _canopy_alpha(top, feet))


func _puddle(at: Vector2, clock: float) -> void:
	draw_set_transform(at, 0.0, Vector2(1.0, 0.4))
	CircleDot.draw(self, Vector2.ZERO, 62.0, Color(0.18, 0.3, 0.4, 0.55))
	for ring: int in range(3):
		var phase: float = fmod(clock * 0.5 + float(ring) / 3.0, 1.0)
		draw_arc(Vector2.ZERO, 8.0 + 52.0 * phase, 0.0, TAU, 24, Color(COLOR_WATER, COLOR_WATER.a * (1.0 - phase)), 2.0)
	draw_set_transform(Vector2.ZERO)


func _flies(at: Vector2, clock: float) -> void:
	for index: int in range(6):
		var seed_value: float = float(index) * 1.7
		var spot: Vector2 = at + Vector2(sin(clock * 3.1 + seed_value) * 26.0, cos(clock * 4.3 + seed_value * 2.0) * 16.0 - 30.0)
		CircleDot.draw(self, spot, 2.0, COLOR_FLY)


func _smoke(at: Vector2, clock: float) -> void:
	for index: int in range(7):
		var phase: float = fmod(clock * 0.12 + float(index) / 7.0, 1.0)
		var spot: Vector2 = at + Vector2(sin(phase * 7.0 + float(index)) * 20.0 + phase * 30.0, -phase * 150.0)
		CircleDot.draw(self, spot, 10.0 + phase * 24.0, Color(COLOR_SMOKE, COLOR_SMOKE.a * (1.0 - phase)))


func _cable(from: Vector2, to: Vector2, clock: float) -> void:
	var sway: float = sin(clock * 1.4 + from.x) * 8.0
	var points: PackedVector2Array = PackedVector2Array()
	for index: int in range(13):
		var step: float = float(index) / 12.0
		var sag: float = (40.0 + sway) * 4.0 * step * (1.0 - step)
		points.append(from.lerp(to, step) + Vector2(sway * 0.3 * sin(step * PI), sag - 90.0))
	draw_polyline(points, COLOR_CABLE, 3.0)


func _plant(at: Vector2, clock: float) -> void:
	for blade: int in range(5):
		var lean: float = float(blade - 2) * 0.28 + sin(clock * 1.8 + at.x + float(blade)) * 0.12
		var tip: Vector2 = at + Vector2.UP.rotated(lean) * (32.0 + 7.0 * float(blade % 3))
		draw_line(at, tip, COLOR_FLY, 6.0)
		draw_line(at, tip, COLOR_PLANT, 3.0)


## Nunca tapa al protagonista: al acercarse, la copa se vuelve casi transparente.
func _canopy_alpha(top: Vector2, feet: Vector2) -> float:
	return lerpf(0.08, COLOR_CANOPY.a, clampf((top.distance_to(feet) - CANOPY_CLEAR) / CANOPY_CLEAR, 0.0, 1.0))


func _canopy(at: Vector2, index: int, clock: float, alpha: float) -> void:
	var wobble: float = sin(clock * 0.6 + float(index)) * 5.0
	for blob: int in range(5):
		var angle: float = TAU * float(blob) / 5.0 + float(index)
		CircleDot.draw(self, at + Vector2.from_angle(angle) * (54.0 + wobble), 62.0, Color(COLOR_CANOPY, alpha))

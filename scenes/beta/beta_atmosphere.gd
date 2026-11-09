class_name BetaAtmosphere
extends Node2D
## Ambiente de la beta: noche por hora real, farolas, esporas y lluvia ácida.
## Solo es visual: no influye en las reglas del juego.

const DAY_COLOR: Color = Color.WHITE
## Provisional: lo bastante oscuro para ambientar sin perder de vista a los enemigos.
const NIGHT_COLOR: Color = Color(0.64, 0.6, 0.88)
const NIGHT_START: int = 21
const NIGHT_END: int = 8
const CHECK_SECONDS: float = 30.0
const LAMPS: Array[Vector2] = [
	Vector2(1500.0, 760.0), Vector2(1900.0, 1020.0), Vector2(2200.0, 820.0),
	Vector2(1500.0, 1700.0), Vector2(1900.0, 1860.0), Vector2(2120.0, 1560.0),
	Vector2(1700.0, 1320.0), Vector2(2450.0, 1320.0),
]
const RAIN_AHEAD: float = 700.0

var hour_source: Callable = func() -> int: return Time.get_time_dict_from_system().hour
var player: Player

var _tint: CanvasModulate
var _lamps: Array[PointLight2D] = []
var _rain: GPUParticles2D
var _check_left: float = 0.0


func _ready() -> void:
	_tint = CanvasModulate.new()
	add_child(_tint)
	var glow: GradientTexture2D = _radial(256)
	for index: int in range(LAMPS.size()):
		var lamp: PointLight2D = PointLight2D.new()
		lamp.texture = glow
		lamp.position = LAMPS[index]
		lamp.color = Palette.NEONES[index % Palette.NEONES.size()]
		lamp.texture_scale = 2.2
		add_child(lamp)
		_lamps.append(lamp)
	add_child(_build_spores())
	_rain = _build_rain()
	add_child(_rain)
	_apply_hour()


func _process(delta: float) -> void:
	_check_left -= delta
	if _check_left <= 0.0:
		_check_left = CHECK_SECONDS
		_apply_hour()
	if is_instance_valid(player):
		_rain.global_position = player.global_position + Vector2(80.0, -RAIN_AHEAD)


func set_raining(value: bool) -> void:
	_rain.emitting = value


func is_night() -> bool:
	var hour: int = hour_source.call()
	return hour >= NIGHT_START or hour < NIGHT_END


func _apply_hour() -> void:
	var night: bool = is_night()
	_tint.color = NIGHT_COLOR if night else DAY_COLOR
	for lamp: PointLight2D in _lamps:
		lamp.enabled = night


func _radial(size: int) -> GradientTexture2D:
	var gradient: Gradient = Gradient.new()
	gradient.set_color(0, Color.WHITE)
	gradient.set_color(1, Color(1.0, 1.0, 1.0, 0.0))
	var texture: GradientTexture2D = GradientTexture2D.new()
	texture.gradient = gradient
	texture.width = size
	texture.height = size
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(1.0, 0.5)
	return texture


func _build_spores() -> GPUParticles2D:
	var area: Rect2 = BetaLayout.SOUTH_QUARTER
	var process: ParticleProcessMaterial = ParticleProcessMaterial.new()
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	process.emission_box_extents = Vector3(area.size.x * 0.5, area.size.y * 0.5, 0.0)
	process.gravity = Vector3(0.0, -8.0, 0.0)
	process.direction = Vector3(1.0, -0.3, 0.0)
	process.spread = 180.0
	process.initial_velocity_min = 4.0
	process.initial_velocity_max = 22.0
	process.scale_min = 0.04
	process.scale_max = 0.14
	process.color = Palette.ACIDO
	var particles: GPUParticles2D = GPUParticles2D.new()
	particles.process_material = process
	particles.texture = _radial(64)
	particles.amount = 180
	particles.lifetime = 9.0
	particles.preprocess = 9.0
	particles.visibility_rect = Rect2(-area.size * 0.6, area.size * 1.2)
	particles.position = area.get_center()
	return particles


func _build_rain() -> GPUParticles2D:
	var process: ParticleProcessMaterial = ParticleProcessMaterial.new()
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	process.emission_box_extents = Vector3(1200.0, 20.0, 0.0)
	process.direction = Vector3(-0.22, 1.0, 0.0)
	process.spread = 2.0
	process.gravity = Vector3.ZERO
	process.initial_velocity_min = 1100.0
	process.initial_velocity_max = 1500.0
	process.color = Color(Palette.ACIDO, 0.45)
	process.set_particle_flag(ParticleProcessMaterial.PARTICLE_FLAG_ALIGN_Y_TO_VELOCITY, true)
	var streak: GradientTexture2D = _radial(32)
	streak.width = 3
	streak.height = 30
	var particles: GPUParticles2D = GPUParticles2D.new()
	particles.process_material = process
	particles.texture = streak
	particles.amount = 320
	particles.lifetime = 1.1
	particles.local_coords = true
	particles.visibility_rect = Rect2(-1400.0, -200.0, 2800.0, 2000.0)
	particles.emitting = false
	particles.z_index = 10
	return particles

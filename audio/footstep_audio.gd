class_name FootstepAudio
extends AudioStreamPlayer2D
## Pasos posicionales: se reproducen al moverse, con variación aleatoria.
##
## P-29: si hay una pared entre el oyente y quien hace el paso, el sonido
## suena tapado (bus con filtro de agudos y menos volumen). Así el jugador
## oye de dónde viene un guardia y si está al otro lado de un muro.

const LIBRARY_PATH: String = "res://data/audio/library.json"
const WALK_INTERVAL: float = 0.48
const RUN_INTERVAL: float = 0.3
const CROUCH_INTERVAL: float = 0.62
const MIN_SPEED: float = 8.0
## Loss de volumen extra cuando el paso llega a través de un muro.
const MUFFLED_LOSS_DB: float = -7.0
## Un paso tapado suena un poco más grave: parece venir de más lejos.
const MUFFLED_PITCH: float = 0.88

var _streams: Array[AudioStream] = []
var _cooldown: float = 0.0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
## P-29: quien escucha (el jugador). Sin él no hay oclusión.
var listener: Node2D = null
## P-29: si es cierto, se comprueba si hay pared entre el oyente y el paso.
var occludable: bool = false


func _ready() -> void:
	_rng.randomize()
	max_distance = 900.0
	attenuation = 1.7
	panning_strength = 1.0
	AudioMixer.ensure_buses()
	bus = AudioMixer.bus_for_steps(false)
	_load_streams()


func _load_streams() -> void:
	if not FileAccess.file_exists(LIBRARY_PATH):
		return
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(LIBRARY_PATH))
	if not data is Dictionary:
		return
	for entry: Variant in data.get("sfx", []):
		if not entry is Dictionary:
			continue
		if str(entry.get("kind", "")) != "step":
			continue
		var stream: AudioStream = load(str(entry.get("file", ""))) as AudioStream
		if stream != null:
			_streams.append(stream)


func tick(delta: float, speed: float, running: bool, crouching: bool) -> void:
	_cooldown = maxf(_cooldown - delta, 0.0)
	if speed < MIN_SPEED or _streams.is_empty():
		return
	if _cooldown > 0.0:
		return
	_cooldown = _interval(running, crouching)
	var pick: AudioStream = _streams[_rng.randi_range(0, _streams.size() - 1)]
	stream = pick
	var base_pitch: float = _rng.randf_range(0.92, 1.08)
	var base_volume: float = -10.0 if crouching else (-3.5 if running else -6.0)
	var muffled: bool = is_muffled()
	if muffled:
		base_pitch *= MUFFLED_PITCH
		base_volume += MUFFLED_LOSS_DB
	pitch_scale = base_pitch
	volume_db = base_volume
	bus = AudioMixer.bus_for_steps(muffled)
	play()


## P-29: ¿hay una pared entre el oyente y este paso?
func is_muffled() -> bool:
	if not occludable or listener == null or not is_instance_valid(listener):
		return false
	var world: World2D = get_world_2d()
	if world == null:
		return false
	var from: Vector2 = listener.global_position
	var to: Vector2 = global_position
	if from.distance_to(to) < 1.0:
		return false
	return Detector.ray_end(from, to, world, PhysicsLayers.WALLS) != to


func _interval(running: bool, crouching: bool) -> float:
	if crouching:
		return CROUCH_INTERVAL
	if running:
		return RUN_INTERVAL
	return WALK_INTERVAL

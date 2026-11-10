class_name FootstepAudio
extends AudioStreamPlayer2D
## Pasos posicionales: se reproducen al moverse, con variación aleatoria.

const LIBRARY_PATH: String = "res://data/audio/library.json"
const WALK_INTERVAL: float = 0.48
const RUN_INTERVAL: float = 0.3
const CROUCH_INTERVAL: float = 0.62
const MIN_SPEED: float = 8.0

var _streams: Array[AudioStream] = []
var _cooldown: float = 0.0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()
	max_distance = 900.0
	attenuation = 1.7
	panning_strength = 1.0
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
	pitch_scale = _rng.randf_range(0.92, 1.08)
	volume_db = -10.0 if crouching else (-3.5 if running else -6.0)
	play()


func _interval(running: bool, crouching: bool) -> float:
	if crouching:
		return CROUCH_INTERVAL
	if running:
		return RUN_INTERVAL
	return WALK_INTERVAL

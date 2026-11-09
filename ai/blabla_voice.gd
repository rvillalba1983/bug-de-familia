class_name BlablaVoice
extends AudioStreamPlayer
## Voz de "blabla" sintetizada; cada IA tiene su tono. No usa archivos ni red.

const MIX_RATE: int = 22050
const LIBRARY_PATH: String = "res://data/audio/library.json"
const TAKES: int = 3
const SYLLABLES: int = 6
const SYLLABLE_SECONDS: float = 0.09

var _fallback: AudioStreamWAV
var _profiles: Array = []
var _loaded: Dictionary = {}
var _take: int = 0


func _ready() -> void:
	_fallback = _build_stream()
	stream = _fallback
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(LIBRARY_PATH))
	if data is Dictionary:
		_profiles = data["voices"]
	volume_db = -14.0
	bus = AudioMixer.BUS_VOICES


## Con key usa el perfil de voz grabado de esa IA; sin ella, el tono sintetizado.
func speak(pitch: float, key: String = "") -> void:
	if key.is_empty() or _profiles.is_empty():
		stream = _fallback
		pitch_scale = pitch
	else:
		stream = _clip(key)
		pitch_scale = clampf(sqrt(pitch), 0.8, 1.35)
	play()


func _clip(key: String) -> AudioStream:
	var profile: String = _profiles[posmod(_stable_hash(key), _profiles.size())]
	_take = (_take + 1) % TAKES
	var path: String = "res://audio/voices/%s_%d.ogg" % [profile, _take]
	if not _loaded.has(path):
		_loaded[path] = load(path)
	return _loaded[path]


func _stable_hash(text: String) -> int:
	var total: int = 0
	for index: int in range(text.length()):
		total += (index + 1) * text.unicode_at(index)
	return total


func _build_stream() -> AudioStreamWAV:
	var samples: int = int(MIX_RATE * SYLLABLE_SECONDS)
	var data: PackedByteArray = PackedByteArray()
	data.resize(samples * SYLLABLES)
	var tones: Array[float] = [190.0, 240.0, 170.0, 260.0, 205.0, 150.0]
	for syllable: int in range(SYLLABLES):
		for index: int in range(samples):
			var time: float = float(index) / MIX_RATE
			var envelope: float = sin(PI * float(index) / samples)
			var wave: float = sign(sin(TAU * tones[syllable] * time)) * envelope * 0.5
			data.encode_s8(syllable * samples + index, int(wave * 127.0))
	var wav: AudioStreamWAV = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_8_BITS
	wav.mix_rate = MIX_RATE
	wav.data = data
	return wav

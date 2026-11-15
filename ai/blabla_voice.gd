class_name BlablaVoice
extends AudioStreamPlayer
## Voz de "blabla" sintetizada; cada IA tiene su tono. No usa archivos ni red.
##
## P-29: además del tono, cada IA tiene un timbre (radio, eco, distorsión).
## El timbre se aplica con el bus de voz: el filtro lo pone `AudioMixer`.

const MIX_RATE: int = 22050
const LIBRARY_PATH: String = "res://data/audio/library.json"
const TAKES: int = 3
const SYLLABLES: int = 6
const SYLLABLE_SECONDS: float = 0.09
## La radio se desajusta un poco al hablar.
const RADIO_JITTER_MIN: float = 0.86
const RADIO_JITTER_MAX: float = 1.14

var _fallback: AudioStreamWAV
var _profiles: Array = []
var _loaded: Dictionary = {}
var _take: int = 0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	_rng.seed = 1234
	_fallback = _build_stream()
	stream = _fallback
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(LIBRARY_PATH))
	if data is Dictionary:
		_profiles = data["voices"]
	volume_db = -14.0
	AudioMixer.ensure_buses()
	bus = AudioMixer.BUS_VOICES


## Con key usa el perfil de voz grabado de esa IA; sin ella, el tono sintetizado.
## El timbre decide el bus (y con él, el filtro) y el ajuste de tono.
func speak(pitch: float, key: String = "", timbre: String = AudioMixer.TIMBRE_NORMAL) -> void:
	bus = AudioMixer.bus_for_timbre(timbre)
	var ajuste: float = pitch
	if timbre == AudioMixer.TIMBRE_RADIO:
		ajuste = pitch * _rng.randf_range(RADIO_JITTER_MIN, RADIO_JITTER_MAX)
	if key.is_empty() or _profiles.is_empty():
		stream = _fallback
		pitch_scale = ajuste
	else:
		stream = _clip(key)
		pitch_scale = clampf(sqrt(ajuste), 0.8, 1.35)
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

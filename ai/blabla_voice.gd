class_name BlablaVoice
extends AudioStreamPlayer
## Voz de "blabla" sintetizada; cada IA tiene su tono. No usa archivos ni red.

const MIX_RATE: int = 22050
const SYLLABLES: int = 6
const SYLLABLE_SECONDS: float = 0.09


func _ready() -> void:
	stream = _build_stream()
	volume_db = -14.0


func speak(pitch: float) -> void:
	pitch_scale = pitch
	play()


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

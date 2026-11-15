class_name AudioMixer
extends RefCounted
## Buses de audio y volúmenes de las opciones.
##
## P-29: el sonido con posición informa de si hay una pared de por medio
## (`Pasos` y `PasosTapados`), y cada IA tiene su timbre (`Voces` y las tres
## variantes con filtro).

const BUS_MUSIC: StringName = &"Musica"
const BUS_VOICES: StringName = &"Voces"
const BUS_STEPS: StringName = &"Pasos"
const BUS_STEPS_MUFFLED: StringName = &"PasosTapados"
const BUS_VOICE_RADIO: StringName = &"VocesRadio"
const BUS_VOICE_ECHO: StringName = &"VocesEco"
const BUS_VOICE_DISTORTED: StringName = &"VocesDistorsionada"
const SILENT_DB: float = -80.0

## Timbres que puede tener una IA. El bus decide cómo suena.
const TIMBRE_NORMAL: String = "normal"
const TIMBRE_RADIO: String = "radio"
const TIMBRE_ECHO: String = "eco"
const TIMBRE_DISTORTED: String = "distorsion"
const TIMBRES: Array[String] = [TIMBRE_NORMAL, TIMBRE_RADIO, TIMBRE_ECHO, TIMBRE_DISTORTED]


static func ensure_buses() -> void:
	_ensure_bus(BUS_MUSIC)
	_ensure_bus(BUS_VOICES)
	_ensure_bus(BUS_STEPS)
	_ensure_bus(BUS_STEPS_MUFFLED)
	_ensure_bus(BUS_VOICE_RADIO)
	_ensure_bus(BUS_VOICE_ECHO)
	_ensure_bus(BUS_VOICE_DISTORTED)
	_effects_steps_muffled()
	_effects_voice_radio()
	_effects_voice_echo()
	_effects_voice_distorted()


static func apply_settings() -> void:
	ensure_buses()
	GameSettings.ensure_loaded()
	_apply_bus(BUS_MUSIC, GameSettings.music_volume)
	_apply_bus(BUS_VOICES, GameSettings.voice_volume)
	## Las cuatro voces comparten el ajuste de volumen de la voz.
	for bus: StringName in [BUS_VOICE_RADIO, BUS_VOICE_ECHO, BUS_VOICE_DISTORTED]:
		_apply_bus(bus, GameSettings.voice_volume)


## Bus de voz según el timbre de la IA. Sin timbre conocido, la voz normal.
static func bus_for_timbre(timbre: String) -> StringName:
	match timbre:
		TIMBRE_RADIO:
			return BUS_VOICE_RADIO
		TIMBRE_ECHO:
			return BUS_VOICE_ECHO
		TIMBRE_DISTORTED:
			return BUS_VOICE_DISTORTED
		_:
			return BUS_VOICES


## Bus de pasos: el tapado suena a través de la pared.
static func bus_for_steps(muffled: bool) -> StringName:
	return BUS_STEPS_MUFFLED if muffled else BUS_STEPS


static func _ensure_bus(bus: StringName) -> void:
	if AudioServer.get_bus_index(bus) >= 0:
		return
	AudioServer.add_bus()
	var index: int = AudioServer.bus_count - 1
	AudioServer.set_bus_name(index, bus)
	AudioServer.set_bus_send(index, &"Master")


static func _apply_bus(bus: StringName, volume: float) -> void:
	var db: float = SILENT_DB if volume <= 0.0 else linear_to_db(volume)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus), db)


## Un muro atenúa los agudos: el paso de detrás suena apagado, no igual de fuerte.
static func _effects_steps_muffled() -> void:
	var index: int = AudioServer.get_bus_index(BUS_STEPS_MUFFLED)
	if index < 0 or AudioServer.get_bus_effect_count(index) > 0:
		return
	var filtro: AudioEffectLowPassFilter = AudioEffectLowPassFilter.new()
	filtro.cutoff_hz = 900.0
	filtro.resonance = 0.1
	AudioServer.add_bus_effect(index, filtro)


## Radio de bolsillo: banda estrecha y algo de rugido.
static func _effects_voice_radio() -> void:
	var index: int = AudioServer.get_bus_index(BUS_VOICE_RADIO)
	if index < 0 or AudioServer.get_bus_effect_count(index) > 0:
		return
	var banda: AudioEffectBandPassFilter = AudioEffectBandPassFilter.new()
	banda.cutoff_hz = 1700.0
	banda.resonance = 1.1
	AudioServer.add_bus_effect(index, banda)
	## LOFI baja la calidad como una radio de bolsillo vieja.
	var rugido: AudioEffectDistortion = AudioEffectDistortion.new()
	rugido.mode = AudioEffectDistortion.MODE_LOFI
	AudioServer.add_bus_effect(index, rugido)


## Eco: la voz rebota en una sala vacía.
static func _effects_voice_echo() -> void:
	var index: int = AudioServer.get_bus_index(BUS_VOICE_ECHO)
	if index < 0 or AudioServer.get_bus_effect_count(index) > 0:
		return
	var eco: AudioEffectReverb = AudioEffectReverb.new()
	eco.room_size = 0.9
	eco.damping = 0.6
	eco.dry = 0.5
	eco.wet = 0.7
	eco.predelay_msec = 110.0
	AudioServer.add_bus_effect(index, eco)


## Distorsión: la voz sale saturada.
static func _effects_voice_distorted() -> void:
	var index: int = AudioServer.get_bus_index(BUS_VOICE_DISTORTED)
	if index < 0 or AudioServer.get_bus_effect_count(index) > 0:
		return
	var saturacion: AudioEffectDistortion = AudioEffectDistortion.new()
	saturacion.mode = AudioEffectDistortion.MODE_OVERDRIVE
	saturacion.drive = 6.0
	AudioServer.add_bus_effect(index, saturacion)

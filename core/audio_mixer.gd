class_name AudioMixer
extends RefCounted
## Buses de audio y volúmenes de las opciones.

const BUS_MUSIC: StringName = &"Musica"
const BUS_VOICES: StringName = &"Voces"
const SILENT_DB: float = -80.0


static func ensure_buses() -> void:
	for bus: StringName in [BUS_MUSIC, BUS_VOICES]:
		if AudioServer.get_bus_index(bus) < 0:
			AudioServer.add_bus()
			var index: int = AudioServer.bus_count - 1
			AudioServer.set_bus_name(index, bus)
			AudioServer.set_bus_send(index, &"Master")


static func apply_settings() -> void:
	ensure_buses()
	GameSettings.ensure_loaded()
	_apply_bus(BUS_MUSIC, GameSettings.music_volume)
	_apply_bus(BUS_VOICES, GameSettings.voice_volume)


static func _apply_bus(bus: StringName, volume: float) -> void:
	var db: float = SILENT_DB if volume <= 0.0 else linear_to_db(volume)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus), db)

class_name TestSupport
extends RefCounted
## Utilidades compartidas por las pruebas.

const SAVE_PATH: String = "user://prueba_partida.json"


static func reset_session() -> void:
	SaveSystem.path = SAVE_PATH
	SaveSystem.delete_all()
	Sandbox.session_started = true
	Sandbox.forced_seed = 1234

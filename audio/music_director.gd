class_name MusicDirector
extends Node
## Elige la música por situación, hora y barrio, con fundidos y sin repetir pronto.
## Usa su propio azar para no tocar la semilla de la partida.

const DATA_PATH: String = "res://data/audio/library.json"
const CHECK_INTERVAL: float = 1.0
const COMBAT_HOLD: float = 6.0
const RECENT_SIZE: int = 6

var level: BetaZone
var current_state: String = ""
var current_track: Dictionary = {}

var _tracks: Array = []
var _recent: Array[String] = []
var _players: Array[AudioStreamPlayer] = []
var _active: int = 0
var _check: float = 0.0
var _pending: String = ""
var _combat_left: float = 0.0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH))
	if not data is Dictionary:
		push_error("Biblioteca de audio ilegible: %s" % DATA_PATH)
		return
	_tracks = data["tracks"]
	for index: int in range(2):
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		player.bus = AudioMixer.BUS_MUSIC
		player.volume_db = -80.0
		player.finished.connect(_on_finished.bind(index))
		add_child(player)
		_players.append(player)


func _process(delta: float) -> void:
	_start_pending()
	_combat_left = maxf(_combat_left - delta, 0.0)
	_check -= delta
	if _check > 0.0:
		return
	_check = CHECK_INTERVAL
	var wanted: String = situation()
	if wanted != current_state:
		_play(wanted)


func situation() -> String:
	if level.battles.phase == BattleDirector.Phase.RUNNING or level.fight.phase != FightDirector.Phase.CALM:
		_combat_left = COMBAT_HOLD
	if _combat_left > 0.0:
		return "combate"
	for guard: Guard in level.guards():
		if not guard.is_down() and not guard.passive and (guard.is_alert() or guard.detector.meter > 0.5):
			return "tension"
	if level.live_world.sim.festivals.is_running() and not level.live_world.sim.festivals.ruined:
		return "festival"
	return "noche" if level.atmosphere.is_night() else "dia"


func zone() -> String:
	var feet: Vector2 = level.player.global_position
	if BetaLayout.north_quarter.has_point(feet):
		return "barrio_jubilado"
	if BetaLayout.south_quarter.has_point(feet):
		return "barrio_mohocrata"
	if BetaLayout.no_mans_land.has_point(feet):
		return "tierra_de_nadie"
	return "bosque"


## Elige una pista de esa situación, sin repetir las últimas que han sonado.
func pick(state: String, where: String) -> Dictionary:
	var options: Array = _tracks.filter(func(track: Dictionary) -> bool:
		return track["state"] == state and (track["any_zone"] or track["zone"] == where))
	var fresh: Array = options.filter(func(track: Dictionary) -> bool:
		return not _recent.has(str(track["file"])))
	var pool: Array = fresh if not fresh.is_empty() else options
	return pool[_rng.randi_range(0, pool.size() - 1)]


func _play(state: String) -> void:
	current_state = state
	var track: Dictionary = pick(state, zone())
	current_track = track
	_recent.append(str(track["file"]))
	if _recent.size() > RECENT_SIZE:
		_recent.pop_front()
	_active = 1 - _active
	_pending = str(track["file"])
	ResourceLoader.load_threaded_request(_pending)


## La pista se carga en segundo plano para que no se note un tirón al cambiar.
func _start_pending() -> void:
	if _pending.is_empty():
		return
	if ResourceLoader.load_threaded_get_status(_pending) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		return
	var old: AudioStreamPlayer = _players[1 - _active]
	var new: AudioStreamPlayer = _players[_active]
	new.stream = ResourceLoader.load_threaded_get(_pending) as AudioStream
	_pending = ""
	new.volume_db = -40.0
	new.play()
	var fade: float = float(current_track["crossfade"])
	var tween: Tween = create_tween()
	tween.tween_property(new, "volume_db", 0.0, fade)
	tween.parallel().tween_property(old, "volume_db", -60.0, fade)
	tween.tween_callback(old.stop)


func _on_finished(index: int) -> void:
	if index == _active and _pending.is_empty() and not current_state.is_empty():
		_play(current_state)

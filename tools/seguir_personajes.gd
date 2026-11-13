extends SceneTree
## Sigue a todos los habitantes fotograma a fotograma y apunta cada frase, caída, salto o desaparición.
## Variables: SEMILLA, SEGUNDOS (de juego), VELOCIDAD, ACCION (nada o malmeter), SALIDA y FOTOS (con ventana).

const JUMP_PER_TICK: float = 30.0
const FOLLOW_TIME: float = 30.0

var zone: DespliegueCeroZone
var world: LiveWorld
var clock: float = 0.0
var last_pos: Dictionary = {}
var last_text: Dictionary = {}
var last_state: Dictionary = {}
var hidden_now: Dictionary = {}
var names: Dictionary = {}
var phrases: Array = []
var _next_shot: float = 0.0
var _walker: String = ""
var _walker_log: int = -1
var counts: Dictionary = {"frases": 0, "saltos": 0, "invisibles": 0, "caidas": 0, "retirados": 0}


func _initialize() -> void:
	_run.call_deferred()


func _env(key: String, fallback: String) -> String:
	return OS.get_environment(key) if OS.has_environment(key) else fallback


func _run() -> void:
	SaveSystem.path = "user://seguir.json"
	SaveSystem.delete_all()
	Sandbox.session_started = true
	Sandbox.forced_seed = int(_env("SEMILLA", "7"))
	BattleDirector.auto_start = false
	if OS.has_environment("FECHA"):
		WorldCalendar.forced_local_unix = int(OS.get_environment("FECHA"))
	change_scene_to_file("res://scenes/despliegue_cero/despliegue_cero_zone.tscn")
	await create_timer(1.0).timeout
	zone = current_scene as DespliegueCeroZone
	world = zone.live_world
	_quiet_guards()
	zone.player.global_position = Vector2(float(_env("X", "1600")), float(_env("Y", "1320")))
	_next_shot = float(_env("FOTO_DESDE", "0"))
	if _env("ACCION", "nada") == "malmeter":
		_badmouth.call_deferred()
	Engine.time_scale = float(_env("VELOCIDAD", "4"))
	if OS.has_environment("SUCESO"):
		_stage_near.call_deferred()
	physics_frame.connect(_tick)
	var seconds: float = float(_env("SEGUNDOS", "300"))
	while clock < seconds:
		await physics_frame
	Engine.time_scale = 1.0
	_report()
	SaveSystem.delete_all()
	quit()


## Los guardias fijos no pintan nada aquí: el jugador solo mira.
func _quiet_guards() -> void:
	var citizens: Array = world.citizens.values()
	for enemy: Guard in zone.guards():
		if not citizens.has(enemy):
			enemy.process_mode = Node.PROCESS_MODE_DISABLED
	for sentinel: Node in [zone.drone, zone.security_camera]:
		if is_instance_valid(sentinel):
			sentinel.process_mode = Node.PROCESS_MODE_DISABLED


## Provoca un suceso con dos personajes cerca del jugador. MATAR=1 hace que haya víctima seguro.
func _stage_near() -> void:
	await create_timer(float(_env("ANTES", "5")), true, false, true).timeout
	var sim: WorldSim = world.sim
	var type: String = OS.get_environment("SUCESO")
	if OS.has_environment("MATAR"):
		sim.events.catalog[type]["kill"] = 1.0
	print("[%6.1f] SUCESO %s preparado: %s" % [clock, type, sim.events.stage(sim, type, -1, 1)])


func _shots() -> void:
	if not OS.has_environment("SALIDA") or clock < _next_shot:
		return
	_next_shot = clock + float(_env("FOTO_CADA", "3"))
	var view: Rect2 = zone.player.get_canvas_transform().affine_inverse() * zone.player.get_viewport_rect()
	var inside: int = 0
	for id: String in world.citizens:
		if is_instance_valid(world.citizens[id]) and view.has_point((world.citizens[id] as Guard).global_position):
			inside += 1
	print("[%6.1f] FOTO en pantalla=%d camara=%s" % [clock, inside, view])
	_save_shot.call_deferred(int(clock))


func _save_shot(label: int) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("%s/t%04d.png" % [OS.get_environment("SALIDA"), label])


func _badmouth() -> void:
	await create_timer(float(_env("ANTES", "15")), true, false, true).timeout
	var npc: NpcState = null
	for id: String in world.citizens:
		var candidate: NpcState = world.sim.npcs[id]
		if npc == null or candidate.pos.distance_to(zone.player.global_position) < npc.pos.distance_to(zone.player.global_position):
			npc = candidate
	world.dialogue.open(npc)
	for index: int in range(3):
		await process_frame
		world.dialogue._badmouth()
	print("[%6.1f] MALMETER tres veces con %s: fase de batalla %d" % [clock, npc.name, zone.battles.phase])
	await create_timer(0.3, true, false, true).timeout
	zone.battles.choose({"unirse": 0, "mirar": 2, "pasar": 3}[_env("BATALLA", "pasar")])
	print("[%6.1f] Oferta respondida: %s" % [clock, _env("BATALLA", "pasar")])


func _tick() -> void:
	if paused:
		return
	clock += _step_seconds()
	_shots()
	var seen_now: Dictionary = {}
	for id: String in world.citizens:
		var guard: Variant = world.citizens[id]
		if not is_instance_valid(guard):
			continue
		seen_now[id] = true
		names[id] = (world.sim.npcs[id] as NpcState).name
		_track(id, guard as Guard)
	for id: String in last_pos.keys():
		if not seen_now.has(id):
			counts["retirados"] += 1
			print("[%6.1f] RETIRADO %s en %s, antes %s" % [clock, names.get(id, id), last_pos[id], _state_name(int(last_state.get(id, 0)))])
			last_pos.erase(id)
			last_state.erase(id)
	_follow_phrases()
	_camera_on_walker()


## Godot multiplica el paso de la física por la velocidad del juego.
func _step_seconds() -> float:
	return Engine.time_scale / float(Engine.physics_ticks_per_second)


func _track(id: String, guard: Guard) -> void:
	var at: Vector2 = guard.global_position
	if last_pos.has(id) and (last_pos[id] as Vector2).distance_to(at) > JUMP_PER_TICK:
		counts["saltos"] += 1
		print("[%6.1f] SALTO %s de %s a %s" % [clock, names[id], last_pos[id], at])
	last_pos[id] = at
	if int(last_state.get(id, -1)) != guard.state:
		if guard.state == Guard.State.DOWN:
			counts["caidas"] += 1
			print("[%6.1f] CAE %s en %s (%s)" % [clock, names[id], at, world.sim.place_name(at)])
		last_state[id] = guard.state
	var rig: EnemyRig = guard.visual.rig
	var shown: bool = guard.is_visible_in_tree() and (rig == null or (rig.visible and rig.modulate.a > 0.05))
	if not shown and not hidden_now.has(id):
		hidden_now[id] = true
		counts["invisibles"] += 1
		print("[%6.1f] INVISIBLE %s estado=%s" % [clock, names[id], _state_name(guard.state)])
	elif shown:
		hidden_now.erase(id)
	var bubble: SpeechBubble = world.bubble_of(id)
	if bubble.is_busy() and last_text.get(id, "") != bubble.text:
		last_text[id] = bubble.text
		_note_phrase(id, guard, bubble.text)
	elif not bubble.is_busy():
		last_text.erase(id)


func _note_phrase(id: String, guard: Guard, text: String) -> void:
	counts["frases"] += 1
	var near: Dictionary = {}
	for other: String in world.citizens:
		if is_instance_valid(world.citizens[other]):
			near[other] = (world.citizens[other] as Guard).global_position
	phrases.append({"t": clock, "who": id, "text": text, "at": guard.global_position, "before": near, "done": false})
	print("[%6.1f] FRASE %s (%s, estado %s): %s" % [clock, names[id], (world.sim.npcs[id] as NpcState).activity, _state_name(guard.state), text])


## Treinta segundos después: quién de los que estaban cerca sigue, se ha movido o ya no está.
func _follow_phrases() -> void:
	for entry: Dictionary in phrases:
		if bool(entry["done"]) or clock - float(entry["t"]) < FOLLOW_TIME:
			continue
		entry["done"] = true
		var center: Vector2 = entry["at"]
		var stayed: int = 0
		var walked: Array[String] = []
		var gone: Array[String] = []
		for id: String in entry["before"]:
			var was: Vector2 = entry["before"][id]
			if was.distance_to(center) > 700.0:
				continue
			var guard: Variant = world.citizens.get(id)
			if not is_instance_valid(guard) or (guard as Guard).is_down():
				gone.append(names.get(id, id))
			elif was.distance_to((guard as Guard).global_position) > 250.0:
				walked.append("%s %d" % [names.get(id, id), int(was.distance_to((guard as Guard).global_position))])
			else:
				stayed += 1
		print("[%6.1f]   +30 s de «%s»: siguen=%d andaron=%s caidos_o_fuera=%s" % [clock, str(entry["text"]).left(50), stayed, walked, gone])


## SEGUIR=1: la cámara se pega al primero que sale a contar un rumor, para ver adónde va.
func _camera_on_walker() -> void:
	if not OS.has_environment("SEGUIR"):
		return
	if _walker.is_empty():
		for id: String in world.citizens:
			var guard: Guard = world.citizens[id]
			var npc: NpcState = world.sim.npcs[id]
			if npc.activity == "cotillear" and guard.state == Guard.State.INVESTIGATE and npc.species == _env("ESPECIE", "mohocrata"):
				_walker = id
				print("[%6.1f] SIGO a %s desde %s" % [clock, npc.name, guard.global_position])
				break
	if _walker.is_empty() or not is_instance_valid(world.citizens.get(_walker)):
		return
	var who: Guard = world.citizens[_walker]
	zone.player.global_position = who.global_position + Vector2(-90.0, 60.0)
	if int(clock) != _walker_log:
		_walker_log = int(clock)
		if _walker_log % 3 == 0:
			print("[%6.1f]   posición de %s: %s en %s, estado %s" % [clock, names[_walker], who.global_position, world.sim.place_name(who.global_position), _state_name(who.state)])


func _state_name(value: int) -> String:
	return Guard.State.keys()[value]


func _report() -> void:
	print("RESUMEN semilla=%s segundos=%.0f %s" % [_env("SEMILLA", "7"), clock, counts])
	var sim: WorldSim = world.sim
	var kinds: Dictionary = {}
	for record: Dictionary in sim.truth.records:
		kinds[record["type"]] = int(kinds.get(record["type"], 0)) + 1
	print("SUCESOS ", kinds)
	var alive: Dictionary = {}
	for id: String in sim.npc_ids:
		var npc: NpcState = sim.npcs[id]
		if npc.alive:
			alive[npc.species] = int(alive.get(npc.species, 0)) + 1
	print("VIVOS ", alive)

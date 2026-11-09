extends SceneTree
## Ejecuta en el juego real lo que el director tiene pendiente de confirmar y guarda capturas en SALIDA.

var zone: BetaZone
var out: String = ""


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	SaveSystem.path = "user://pendientes.json"
	SaveSystem.delete_all()
	Sandbox.session_started = true
	Sandbox.forced_seed = 7
	WorldCalendar.forced_local_unix = 1794225600
	BattleDirector.auto_start = false
	out = OS.get_environment("SALIDA")
	change_scene_to_file("res://scenes/beta/beta_zone.tscn")
	await create_timer(1.5).timeout
	zone = current_scene as BetaZone
	zone.challenges.hour_source = func() -> int: return 12
	await _pickup()
	await _knockback()
	await _auto_piece()
	await _shot("chat")
	await _provoke()
	SaveSystem.delete_all()
	quit()


func _shot(label: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("%s/%s.png" % [out, label])
	print("captura ", label)


func _wait(seconds: float) -> void:
	await create_timer(seconds, true, false, true).timeout


func _pickup() -> void:
	var before: int = zone.player.body.spare_count()
	zone.set_enemies_active(false)
	zone.player.global_position = BetaLayout.pickup_arm + Vector2(-70.0, 0.0)
	await _wait(0.2)
	zone.player.global_position = BetaLayout.pickup_arm
	await _wait(0.5)
	print("RECOGER repuestos %d -> %d aviso=«%s» visible=%s" % [before, zone.player.body.spare_count(), zone.hud.notice_label.text, zone.hud.notice_label.visible])
	await _shot("recoger")
	await _wait(1.0)


func _knockback() -> void:
	var enemy: Guard = zone.live_world.citizens.values()[0]
	var player: Player = zone.player
	## Ya en pelea, para que la pausa inicial no corte la medida.
	zone.fight.phase = FightDirector.Phase.FIGHTING
	player.body.context = ModularBody.Context.FIGHTING
	enemy.process_mode = Node.PROCESS_MODE_INHERIT
	enemy.stun(30.0)
	player.global_position = Vector2(1720.0, 1320.0)
	enemy.global_position = player.global_position + Vector2(-40.0, 0.0)
	await _wait(0.2)
	await _measure_player(enemy, "campo abierto")
	player.global_position = Vector2(_wall_probe(), 1320.0)
	enemy.global_position = player.global_position + Vector2(40.0, 0.0)
	await _wait(0.2)
	await _measure_player(enemy, "junto al borde oeste")
	await _shot("retroceso_jugador")
	player.global_position = Vector2(1720.0, 1320.0)
	enemy.global_position = player.global_position + Vector2(40.0, 0.0)
	await _wait(0.2)
	var was: Vector2 = enemy.global_position
	enemy.state = Guard.State.PATROL
	enemy.take_damage(1.0)
	await _wait(0.4)
	print("RETROCESO enemigo %.1f unidades, pausado=%s" % [was.distance_to(enemy.global_position), paused])
	enemy.stun(30.0)
	enemy.process_mode = Node.PROCESS_MODE_DISABLED
	zone.fight.phase = FightDirector.Phase.CALM
	player.body.context = ModularBody.Context.FREE


func _measure_player(enemy: Guard, title: String) -> void:
	var player: Player = zone.player
	var start: Vector2 = player.global_position
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 5
	player.receive_hit(1.0, rng, enemy)
	await _wait(0.4)
	print("RETROCESO jugador en %s: %.1f unidades (%s -> %s), pausado=%s" % [title, start.distance_to(player.global_position), start, player.global_position, paused])


func _wall_probe() -> float:
	return 130.0


func _auto_piece() -> void:
	var body: ModularBody = zone.player.body
	body.context = ModularBody.Context.FIGHTING
	zone.fight.phase = FightDirector.Phase.FIGHTING
	var cases: Array = [[ModularBody.Slot.ARM_MAIN_LEFT, 1], [ModularBody.Slot.ARM_MAIN_RIGHT, 0], [ModularBody.Slot.LEG_LEFT, 2]]
	for entry: Array in cases:
		var slot: ModularBody.Slot = entry[0]
		zone.hud.notice_label.text = ""
		while body.spares(slot).size() > 0:
			body.discard_spare(slot, 0)
		for index: int in range(int(entry[1])):
			body.add_spare(slot, BodyPiece.new(ModularBody.kind_of(slot)))
		var old: BodyPiece = body.equipped(slot)
		body.damage(slot, 1000.0)
		await process_frame
		var now: BodyPiece = body.equipped(slot)
		print("AUTOCOLOCAR repuestos=%d puesta_nueva=%s panel_abierto=%s pausado=%s aviso=«%s»" % [
			entry[1], now != null and now != old, zone.panel.is_open, paused, zone.hud.notice_label.text
		])
		await _shot("autocolocar_%d" % int(entry[1]))
		if zone.panel.is_open:
			zone.panel.close()
		await _wait(0.2)
	zone.fight.phase = FightDirector.Phase.CALM
	body.context = ModularBody.Context.FREE


func _provoke() -> void:
	var world: LiveWorld = zone.live_world
	var npc: NpcState = world.sim.alive_of("mohocrata")[0]
	zone.player.global_position = (world.citizens[npc.id] as Guard).global_position + Vector2(-60.0, 0.0)
	await _wait(0.3)
	world.dialogue.open(npc)
	await process_frame
	await _shot("provocar_conversacion")
	for turn: int in range(3):
		var label: int = -1
		for index: int in range(world.dialogue.options().size()):
			if str(world.dialogue.options()[index][0]).contains("van diciendo"):
				label = index
		var key: InputEventAction = InputEventAction.new()
		key.action = StringName("action_%d" % (label + 1))
		key.pressed = true
		Input.parse_input_event(key)
		await _wait(0.15)
		var up: InputEventAction = InputEventAction.new()
		up.action = key.action
		up.pressed = false
		Input.parse_input_event(up)
		await _wait(0.15)
		print("PROVOCAR vez %d con la tecla %d: fase=%d" % [turn + 1, label + 1, zone.battles.phase])
	await _wait(0.4)
	await _shot("provocar_oferta")
	var hurt: int = 0
	zone.battles.choose(3)
	await _wait(0.5)
	print("PROVOCAR tras «pasar»: fase=%d luchadores=%d" % [zone.battles.phase, zone.battles.alive_in("jubilado").size() + zone.battles.alive_in("mohocrata").size() + hurt])
	await _wait(8.0)
	await _shot("provocar_batalla")

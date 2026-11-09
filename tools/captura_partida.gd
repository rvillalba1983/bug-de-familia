extends SceneTree
## Ejecuta la zona beta real y guarda capturas: x,y,segundos,nombre separados por espacios en
## la variable CAPTURAS. Usa una partida aparte. FECHA fija la hora local (segundos desde 1970).

func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	SaveSystem.path = "user://captura_partida.json"
	SaveSystem.delete_all()
	Sandbox.session_started = true
	Sandbox.forced_seed = int(OS.get_environment("SEMILLA")) if OS.has_environment("SEMILLA") else 77
	if OS.has_environment("FECHA"):
		WorldCalendar.forced_local_unix = int(OS.get_environment("FECHA"))
	var out: String = OS.get_environment("SALIDA")
	change_scene_to_file("res://scenes/beta/beta_zone.tscn")
	await create_timer(1.5).timeout
	var zone: BetaZone = current_scene as BetaZone
	await _act(zone, OS.get_environment("ACCION"))
	if OS.has_environment("SUCESO"):
		var sim: WorldSim = zone.live_world.sim
		sim.events.stage(sim, OS.get_environment("SUCESO"), -1, 1)
	for shot: String in OS.get_environment("CAPTURAS").split(" ", false):
		var part: PackedStringArray = shot.split(",")
		if part[0] == "fiesta":
			zone.player.global_position = zone.live_world.sim.festivals.spot + Vector2(-140.0, 170.0)
		elif part[0] != "aqui":
			zone.player.global_position = Vector2(part[0].to_float(), part[1].to_float())
		await create_timer(part[2].to_float(), true, false, true).timeout
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("%s/%s.png" % [out, part[3]])
		print("captura ", part[3])
	var frames: int = int(OS.get_environment("FOTOGRAMAS")) if OS.has_environment("FOTOGRAMAS") else 0
	for index: int in range(frames):
		await create_timer(0.1, true, false, true).timeout
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("%s/video_%04d.png" % [out, index])
	SaveSystem.delete_all()
	quit()


func _act(zone: BetaZone, action: String) -> void:
	var world: LiveWorld = zone.live_world
	var sim: WorldSim = world.sim
	var near: Vector2 = Vector2(1500.0, 900.0)
	match action:
		"piezas":
			var body: ModularBody = zone.player.body
			body.equipped(ModularBody.Slot.values()[1] as ModularBody.Slot).durability = 18.0
			var level: int = 1
			for slot: int in ModularBody.Slot.values():
				for spare: BodyPiece in body.spares(slot as ModularBody.Slot):
					spare.level = (level % 5) + 1
					spare.label = "Muestra"
					spare.pick_visual_variant(str(level))
					if level % 2 == 0:
						spare.actions = [{"id": "a009", "name": "Impulso", "active": true}]
					level += 1
			zone.panel.open(BodyPanel.Mode.NORMAL)
		"objetivos":
			var crate: Convertible = get_nodes_in_group(Convertible.GROUP).filter(func(n: Node) -> bool: return n.get_parent() is Interactable)[0]
			zone.player.global_position = crate.global_position + Vector2(60.0, 0.0)
			zone.conversion.begin_on(crate)
		"seguidores":
			var crowd: Decoy = Decoy.new()
			crowd.followers = 4
			crowd.setup(near + Vector2(120.0, 40.0), 30.0, zone.noise_bus)
			zone.player.global_position = near
			zone.actors.add_child(crowd)
			var holo: Decoy = Decoy.new()
			holo.setup(near + Vector2(-140.0, 60.0), 30.0, zone.noise_bus)
			zone.actors.add_child(holo)
			zone.player.start_disguise("any", 30.0, 0.25)
			zone.ai.team.active = ["cupido", "sargento_bit", "lumi"]
			for index: int in range(7):
				zone.ai.chat.add_message("lumi", "Mensaje %d: ¡Chicos, se va a caer! ¡Like si muere!" % index)
		"calma":
			zone.set_enemies_active(false)
			zone.player.body.equipped(ModularBody.Slot.values()[1] as ModularBody.Slot).durability = 15.0
			zone.player.body.equipped(ModularBody.Slot.values()[5] as ModularBody.Slot).durability = 30.0
		"pausa":
			zone.pause.set_paused(true)
		"charla":
			zone.ai.team.active = ["cupido", "sargento_bit", "siestaware"]
			zone.ai.say_chain(["idle_advice", "idle_insult", "idle_reproach"])
			zone.ai._start_argument()
		"conversion":
			zone.ai.team.active = ["friki", "nihil", "rencorosa"]
			var target: Convertible = get_nodes_in_group(Convertible.GROUP)[0] as Convertible
			zone.player.global_position = target.global_position + Vector2(60.0, 0.0)
			zone.conversion.begin_on(target)
			await create_timer(1.6, true, false, true).timeout
			zone.conversion.choose_objective(zone.catalog.objectives.keys()[0])
			zone.conversion.choose_slot(ModularBody.Slot.values()[1])
		"oferta":
			zone.battles.begin()
		"batalla":
			zone.battles.begin()
			await create_timer(0.3, true, false, true).timeout
			zone.battles.choose(2)
			zone.battles.set_speed(4.0 if OS.has_environment("X4") else 1.0)
		"unirse":
			zone.player.global_position = Vector2(2000.0, 1300.0)
			zone.battles.begin()
			await create_timer(0.3, true, false, true).timeout
			zone.battles.choose(3)
		"controles":
			zone.get_children().filter(func(n: Node) -> bool: return n is ControlsPanel)[0].toggle()
		"nacimiento":
			zone.player.global_position = near
			var npc: NpcState = sim.spawn("jubilado", near + Vector2(120.0, 40.0), "nacido")
			sim.events.report(sim, "nacimiento", npc.id, "", npc.pos)
		"mision":
			zone.player.global_position = near
			var teller: NpcState = sim.alive_of("jubilado")[0]
			(world.citizens[teller.id] as Guard).global_position = near + Vector2(90.0, 20.0)
			teller.pos = near + Vector2(90.0, 20.0)
			sim.events.report(sim, "sombrero_perdido", teller.id, "", near + Vector2(250.0, 60.0))
			world.dialogue.open(teller)
			world.dialogue.choose(3)
		"rastro":
			var added: Array = sim.festivals.collect_traces(sim, WorldCalendar.today() - 10)
			world._build_festival_view(added)
			world._refresh_decor()

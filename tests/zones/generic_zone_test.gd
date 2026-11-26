extends GdUnitTestSuite
## Escena genÃƒÂ©rica zone.tscn: geometrÃƒÂ­a, corredores, guardado y mundo vivo.


func before_test() -> void:
	TestSupport.reset_session()
	Sandbox.pending_save = {}


func after_test() -> void:
	get_tree().paused = false


func _mount(zone_path: String) -> ZoneBase:
	return await _mount_edited(zone_path, func(_definition: ZoneDefinition) -> void: pass)


## Monta una zona sin delimitadores. Desde el ADR 0044 todas las zonas declaran
## fachadas, así que el caso opt-in se sintetiza en memoria (no se debilita).
func _mount_without_delimiters(zone_path: String) -> ZoneBase:
	var edit: Callable = func(definition: ZoneDefinition) -> void:
		for corridor: Dictionary in definition.data["geometry"]["corridors"]:
			corridor.erase("facades")
			corridor.erase("walls")
	return await _mount_edited(zone_path, edit)


func _mount_edited(zone_path: String, edit: Callable) -> ZoneBase:
	var zone: ZoneBase = auto_free(load("res://scenes/zones/zone.tscn").instantiate())
	var definition: ZoneDefinition = ZoneDefinition.load_from(zone_path)
	edit.call(definition)
	zone.set_definition(definition)
	zone.world_mode = true
	add_child(zone)
	await get_tree().process_frame
	return zone


func test_generic_zone_mounts_geometry_and_shape_blocks() -> void:
	var zone: ZoneBase = await _mount("res://data/zones/el_enchufe.json")
	assert_vector(zone.world_size()).is_equal(Vector2(4000.0, 4000.0))
	assert_vector(zone.floor_rect().position).is_equal(Vector2.ZERO)
	assert_int(zone.shape_blocks().size()).is_greater(0)
	assert_int(zone.corridor_rects().size()).is_equal(zone.zone_definition().corridors().size())
	assert_int(zone.save_point_positions().size()).is_equal(4)


func test_generic_zone_nav_blocks_shape_blocks() -> void:
	var zone: ZoneBase = await _mount("res://data/zones/el_enchufe.json")
	var block: Rect2 = zone.shape_blocks()[0]
	assert_bool(zone.nav.is_walkable(block.get_center())).is_false()
	assert_bool(zone.nav.is_walkable(zone.start_point())).is_true()


func test_generic_zone_creates_fast_travel_interactables() -> void:
	var zone: ZoneBase = await _mount("res://data/zones/el_enchufe.json")
	var count: int = 0
	for child: Node in zone.actors.get_children():
		if child is Interactable and str((child as Interactable).item_id).begins_with("fast_travel_"):
			count += 1
	assert_int(count).is_equal(zone.save_point_positions().size())


func test_generic_zone_live_world_starts() -> void:
	var zone: ZoneBase = await _mount("res://data/zones/el_enchufe.json")
	assert_bool(zone.live_world.started).is_true()
	assert_int(zone.live_world.citizens.size()).is_greater(0)
	assert_str(zone.objective_key()).is_equal("ZONE_OBJECTIVE")


func test_la_pausa_tactica_de_una_zona_generica_ensena_fantasmas() -> void:
	var zone: ZoneBase = await _mount("res://data/zones/el_enchufe.json")
	var vista: AiSpectres = null
	var contados: int = 0
	for child: Node in zone.hud.get_children():
		if child is AiSpectres:
			contados += 1
			vista = child as AiSpectres
	assert_int(contados).is_equal(1)
	assert_object(vista).is_not_null()
	if vista == null:
		return
	assert_bool(vista.visible).is_false()
	zone.pause.set_paused(true)
	assert_bool(get_tree().paused).is_true()
	assert_bool(vista.visible).is_true()
	assert_int(vista.ghosts().size()).is_equal(3)
	zone.pause.set_paused(false)
	assert_bool(get_tree().paused).is_false()
	assert_bool(vista.visible).is_false()


func test_corridor_triggers_transition() -> void:
	var zone: ZoneBase = await _mount("res://data/zones/el_enchufe.json")
	var received: Array[String] = []
	zone.transition_requested.connect(func(to: String) -> void: received.append(to))
	zone._on_corridor_entered(zone.player, "cumbre")
	assert_array(received).is_equal(["cumbre"])


## Los muros del pasillo no deben tapar el hueco del corredor: el centro del rect
## ha de seguir transitable en NavGrid y alcanzable desde el inicio.
func test_corridor_walls_keep_gap_walkable() -> void:
	var zone: ZoneBase = await _mount("res://data/zones/cumbre.json")
	assert_int(zone.zone_definition().corridors().size()).is_greater(0)
	for corridor: Dictionary in zone.zone_definition().corridors():
		var rect: Rect2 = corridor["rect"]
		assert_bool(zone.nav.is_walkable(rect.get_center())).is_true().override_failure_message(
			"El corredor hacia %s queda tapado por sus muros" % str(corridor["to"]))
		var path: PackedVector2Array = zone.nav.find_path(zone.start_point(), rect.get_center())
		assert_int(path.size()).is_greater(0).override_failure_message(
			"El corredor hacia %s no es alcanzable desde el inicio" % str(corridor["to"]))


## Las bocas sur y este llevan un fondo que cierra la vista del tramo siguiente:
## un muro de tipo BACKDROP cuyo frente cae justo sobre el rect del corredor.
func test_corridor_backdrops_close_the_south_and_east_mouths() -> void:
	var zone: ZoneBase = await _mount("res://data/zones/cumbre.json")
	var expected: int = 0
	for corridor: Dictionary in zone.zone_definition().corridors():
		var edge: String = str(corridor["edge"])
		if edge != "south" and edge != "east":
			continue
		expected += 1
		var rect: Rect2 = corridor["rect"]
		var backdrop: Wall = _backdrop_at(zone, rect)
		assert_object(backdrop).is_not_null().override_failure_message(
			"Falta el fondo del corredor hacia %s" % str(corridor["to"]))
		if backdrop == null:
			continue
		var front: Rect2 = _front_of(backdrop)
		assert_vector(front.position).is_equal(rect.position).override_failure_message(
			"El frente del fondo hacia %s no arranca en la boca" % str(corridor["to"]))
		assert_vector(front.size).is_equal(rect.size).override_failure_message(
			"El frente del fondo hacia %s no cubre el pasillo" % str(corridor["to"]))
		assert_bool(backdrop.always_opaque).is_true()
	assert_int(expected).is_greater(0)
	assert_int(_backdrops_of(zone).size()).is_equal(expected)


## El fondo es solo visual: no colisiona, para que el hueco del pasillo siga
## abierto y la transición se dispare igual que antes.
func test_corridor_backdrop_does_not_close_the_passage() -> void:
	var zone: ZoneBase = await _mount("res://data/zones/cumbre.json")
	var backdrops: Array[Wall] = _backdrops_of(zone)
	assert_int(backdrops.size()).is_greater(0)
	for backdrop: Wall in backdrops:
		assert_int(backdrop.collision_layer).is_equal(0)
	for corridor: Dictionary in zone.zone_definition().corridors():
		var rect: Rect2 = corridor["rect"]
		assert_bool(zone.nav.is_walkable(rect.get_center())).is_true()


## El fondo no se atenúa aunque su área visible pise a un personaje: si se
## desvaneciera se vería justo el corte del mapa que está tapando.
func test_corridor_backdrop_stays_opaque_at_the_mouth() -> void:
	var zone: ZoneBase = await _mount("res://data/zones/cumbre.json")
	var corridor: Dictionary = zone.zone_definition().corridor_to("archivo")
	var backdrop: Wall = _backdrop_at(zone, corridor["rect"])
	assert_object(backdrop).is_not_null()
	if backdrop == null:
		return
	var height: float = zone.player.current_height()
	var feet: Vector2 = (corridor["rect"] as Rect2).get_center()
	assert_bool(Wall.hides_character(
		backdrop.visual_rect(), backdrop.footprint.end.y, feet, height
	)).is_true().override_failure_message(
		"El caso de prueba no llega a tapar al personaje: el test no probaría nada")
	zone._update_wall_occlusion(feet, height)
	assert_float(backdrop.modulate.a).is_equal(1.0)


## El cambio es opt-in: las zonas que no declaran muros de pasillo no llevan fondo.
## El caso se sintetiza porque las 24 zonas ya están delimitadas (ADR 0044).
func test_zones_without_corridor_walls_have_no_backdrop() -> void:
	var zone: ZoneBase = await _mount_without_delimiters("res://data/zones/el_enchufe.json")
	assert_int(_backdrops_of(zone).size()).is_equal(0)
	for corridor: Dictionary in zone.zone_definition().corridors():
		assert_bool((corridor.get("walls", []) as Array).is_empty()).is_true()


## La señal de la boca (SVG y nombre de la zona) cae siempre dentro del área
## jugable. En las salidas norte el centro del corredor está en el borde del mapa:
## con el desplazamiento hacia el norte ambos caían fuera del límite de la cámara y
## no se veían nunca.
func test_corridor_signs_stay_inside_the_playable_area() -> void:
	var zone: ZoneBase = await _mount("res://data/zones/taller.json")
	var north: Dictionary = zone.zone_definition().corridor_to("el_enchufe")
	assert_str(str(north["edge"])).is_equal("north")
	var checked: int = 0
	for corridor: Dictionary in zone.zone_definition().corridors():
		var edge: String = str(corridor["edge"])
		var rect: Rect2 = corridor["rect"]
		var sprite: Sprite2D = _corridor_sign_at(zone, zone.corridor_sign_position(corridor))
		assert_object(sprite).is_not_null().override_failure_message(
			"Falta la señal del corredor hacia %s" % str(corridor["to"]))
		var name_label: Label = zone._zone_signs.get(str(corridor["to"])) as Label
		assert_object(name_label).is_not_null().override_failure_message(
			"Falta el nombre de la boca hacia %s" % str(corridor["to"]))
		if sprite == null or name_label == null:
			continue
		checked += 1
		assert_int(sprite.z_index).is_equal(ZoneBase.SIGN_SPRITE_Z)
		assert_int(name_label.z_index).is_equal(ZoneBase.SIGN_NAME_Z)
		assert_bool(name_label.z_index > sprite.z_index).is_true().override_failure_message(
			"El nombre de la boca hacia %s queda detrás de la señal" % str(corridor["to"]))
		assert_bool(name_label.text.is_empty()).is_false().override_failure_message(
			"El nombre de la boca hacia %s está vacío" % str(corridor["to"]))
		var box: Rect2 = _sprite_box(sprite)
		# Al menos parte de la señal tiene que caer en el área jugable. En este y
		# oeste la señal sobresale del borde del mapa por diseño.
		assert_bool(zone.floor_rect().intersects(box)).is_true().override_failure_message(
			"La señal hacia %s queda fuera del área jugable: %s" % [str(corridor["to"]), box])
		var card: Rect2 = _control_box(name_label)
		assert_bool(card.size.x > 0.0 and card.size.y > 0.0).is_true().override_failure_message(
			"El nombre de la boca hacia %s no tiene tamaño" % str(corridor["to"]))
		# El nombre va delante del cartel, superpuesto: el SVG queda de fondo.
		assert_bool(box.intersects(card)).is_true().override_failure_message(
			"El nombre de la boca hacia %s no se superpone a la señal: %s / %s" % [
				str(corridor["to"]), box, card
			])
		assert_bool(card.get_center().y >= box.position.y
			and card.get_center().y <= box.end.y).is_true().override_failure_message(
			"El nombre de la boca hacia %s no está centrado sobre la señal" % str(corridor["to"]))
		assert_bool(zone.floor_rect().intersects(card)).is_true().override_failure_message(
			"El nombre hacia %s queda fuera del área jugable: %s" % [str(corridor["to"]), card])
		if edge == "north":
			# El fallo corregido: señal y nombre caían enteros fuera de la cámara.
			assert_bool(zone.floor_rect().encloses(box)).is_true().override_failure_message(
				"La señal norte hacia %s se sale del área jugable: %s" % [
					str(corridor["to"]), box
				])
			assert_bool(zone.floor_rect().encloses(card)).is_true().override_failure_message(
				"El nombre norte hacia %s se sale del área jugable: %s" % [
					str(corridor["to"]), card
				])
			assert_bool(box.position.y > rect.end.y).is_true().override_failure_message(
				"La señal de la boca norte tiene que quedar dentro de la sala")
			assert_bool(card.position.y > rect.end.y).is_true().override_failure_message(
				"El nombre de la boca norte tiene que quedar dentro de la sala")
	assert_int(checked).is_greater(0)


## El cartel de texto viejo («Bienvenido a… / Seguir el camino / a N m») ya no debe
## existir en ninguna boca (P-55).
func test_corridor_old_text_sign_is_gone() -> void:
	var zone: ZoneBase = await _mount("res://data/zones/taller.json")
	var texts: Array[String] = _visible_texts(zone)
	assert_int(_zone_signs_of(zone).size()).is_greater(0)
	for text: String in texts:
		assert_bool(text.contains("Bienvenido")).is_false().override_failure_message(
			"Queda el cartel viejo en la zona: «%s»" % text)
		assert_bool(text.contains("Seguir el camino")).is_false().override_failure_message(
			"Queda el cartel viejo en la zona: «%s»" % text)


## Los corredores que no declaran `sign` reciben cartel del catálogo por el
## fallback del ADR 0034 (`hash(destino) % 10 + 1`): así las bocas de
## despliegue_cero también llevan cartel detrás y nombre delante.
func test_corridors_without_sign_get_a_sign_and_a_name() -> void:
	var zone: ZoneBase = auto_free(load("res://scenes/zones/zone.tscn").instantiate())
	var definition: ZoneDefinition = ZoneDefinition.load_from("res://data/zones/taller.json")
	for corridor: Dictionary in definition.data["geometry"]["corridors"]:
		corridor.erase("sign")
	zone.set_definition(definition)
	zone.world_mode = true
	add_child(zone)
	await get_tree().process_frame
	assert_int(zone.zone_definition().corridors().size()).is_greater(0)
	for corridor: Dictionary in zone.zone_definition().corridors():
		var to_zone: String = str(corridor["to"])
		assert_str(str(corridor["sign"])).is_empty()
		var sprite: Sprite2D = _corridor_sign_at(zone, zone.corridor_sign_position(corridor))
		assert_object(sprite).is_not_null().override_failure_message(
			"Falta el cartel del fallback hacia %s" % to_zone)
		var name_label: Label = zone._zone_signs.get(to_zone) as Label
		assert_object(name_label).is_not_null().override_failure_message(
			"Falta el nombre del fallback hacia %s" % to_zone)
		if sprite == null or name_label == null:
			continue
		assert_bool(sprite.texture.resource_path.contains(ZoneBase.SIGN_PREFIX)).is_true()
		assert_int(name_label.z_index).is_greater(sprite.z_index)
		assert_bool(_sprite_box(sprite).intersects(_control_box(name_label))).is_true()


## Fondo de la boca cuyo rect es `rect`: el muro BACKDROP cuyo frente lo cubre.
func _backdrop_at(zone: ZoneBase, rect: Rect2) -> Wall:
	for wall: Wall in _backdrops_of(zone):
		if _front_of(wall).is_equal_approx(rect):
			return wall
	return null


func _backdrops_of(zone: ZoneBase) -> Array[Wall]:
	var result: Array[Wall] = []
	for wall: Wall in zone.walls:
		if wall.kind == Wall.Kind.BACKDROP:
			result.append(wall)
	return result


## Rectángulo que dibuja el frente de un muro: su huella elevada `front_height`.
func _front_of(wall: Wall) -> Rect2:
	return Rect2(
		wall.footprint.position.x, wall.footprint.end.y - wall.front_height,
		wall.footprint.size.x, wall.front_height
	)


## Señal de la boca que está en `at` (hijos de `actors`, que no tiene desplazamiento).
func _corridor_sign_at(zone: ZoneBase, at: Vector2) -> Sprite2D:
	for child: Node in zone.actors.get_children():
		if child is Sprite2D and (child as Sprite2D).position.is_equal_approx(at):
			return child
	return null


## Caja que ocupa el sprite en el mundo: su textura, escalada y centrada.
func _sprite_box(sprite: Sprite2D) -> Rect2:
	var size: Vector2 = sprite.texture.get_size() * sprite.scale
	return Rect2(sprite.position - size * 0.5, size)


## Caja de un Control colocado en el mundo (posición y tamaño propios).
func _control_box(control: Control) -> Rect2:
	return Rect2(control.position, control.size)


## Nombres de las bocas de la zona, uno por destino.
func _zone_signs_of(zone: ZoneBase) -> Array:
	return zone._zone_signs.values()


## Todos los textos visibles que cuelgan de la zona, para comprobar que el cartel
## viejo ya no está montado en ninguna boca.
func _visible_texts(root: Node) -> Array[String]:
	var result: Array[String] = []
	for child: Node in root.get_children():
		if child is Label:
			result.append((child as Label).text)
		elif child is Button:
			result.append((child as Button).text)
		result.append_array(_visible_texts(child))
	return result


## La secciÃƒÂ³n Ã‚Â«actorsÃ‚Â» es opcional: solo algunas zonas la declaran. Montar las
## otras no debe quejar ni dejar a nadie sin facciÃƒÂ³n.
func test_zone_without_actors_section_mounts_without_errors() -> void:
	var zone: ZoneBase = auto_free(load("res://scenes/zones/zone.tscn").instantiate())
	var definition: ZoneDefinition = ZoneDefinition.load_from("res://data/zones/taller.json")
	definition.data.erase("actors")
	zone.set_definition(definition)
	zone.world_mode = true
	add_child(zone)
	await get_tree().process_frame
	assert_bool(zone.zone_definition().data.has("actors")).is_false()
	assert_bool(zone.live_world.started).is_true()
	assert_int(zone.live_world.citizens.size()).is_greater(0)
	## Sin actores guionados, los ÃƒÂºnicos cuerpos son los ciudadanos del mundo vivo.
	assert_int(zone.guards().size()).is_equal(zone.live_world.citizens.size())


## Las zonas con contenido traen actores guionados: aparecen en la escena junto
## a los ciudadanos del mundo vivo.
func test_zone_with_actors_mounts_the_scripted_actors() -> void:
	var zone: ZoneBase = await _mount("res://data/zones/valle.json")
	assert_int(zone.zone_definition().list_optional("actors").size()).is_equal(2)
	assert_int(zone.guards().size()).is_equal(zone.live_world.citizens.size() + 2)


## Los habitantes y los actores guionados llevan su bando: sin ÃƒÂ©l, las acciones
## que filtran por facciÃƒÂ³n no encuentran a nadie en las zonas genÃƒÂ©ricas.
func test_citizens_and_actors_have_their_faction() -> void:
	var zone: ZoneBase = await _mount("res://data/zones/el_enchufe.json")
	for id: String in zone.live_world.citizens:
		var citizen: Guard = zone.live_world.citizens[id]
		var npc: NpcState = zone.live_world.sim.npcs[id]
		assert_str(citizen.detector.faction).is_equal(npc.species).override_failure_message(
			"El ciudadano %s no lleva su bando" % id
		)
	for enemy: Guard in zone.guards():
		var actor_id: String = zone.id_of_guard(enemy)
		assert_str(enemy.detector.faction).is_not_empty().override_failure_message(
			"El actor %s no lleva bando" % actor_id
		)


## Los actores guionados no progenitores son hablables en zonas genéricas.
func test_scripted_actor_can_talk_in_generic_zone() -> void:
	var zone: ZoneBase = await _mount("res://data/zones/valle.json")
	var actor_id: String = str(zone.zone_definition().list_optional("actors")[0]["id"])
	var guard: Guard = null
	for enemy: Guard in zone.guards():
		if zone.id_of_guard(enemy) == actor_id:
			guard = enemy
			break
	assert_object(guard).is_not_null().override_failure_message(
		"No se encontró el actor guionado %s" % actor_id)
	if guard == null:
		return
	var item: Interactable = null
	for child: Node in guard.get_children():
		if child is Interactable and (child as Interactable).item_id == actor_id:
			item = child as Interactable
			break
	assert_object(item).is_not_null().override_failure_message(
		"El actor %s no tiene interactuable de conversación" % actor_id)
	if item == null:
		return
	item.activate()
	await get_tree().process_frame
	assert_bool(zone.live_world.dialogue.is_open()).is_true()
	assert_bool(zone.live_world.dialogue.is_external()).is_true()
	zone.live_world.dialogue.close()


func test_named_terminal_item_in_generic_zone_does_not_open_sandbox_door() -> void:
	var zone: ZoneBase = auto_free(load("res://scenes/zones/zone.tscn").instantiate())
	var definition: ZoneDefinition = ZoneDefinition.load_from("res://data/zones/valle.json")
	definition.data["items"] = [{
		"at": "start",
		"id": "cartel_prueba",
		"label": "Cartel de prueba",
		"reusable": true,
		"type": "named",
		"art": "res://art/shared/props/panel.svg",
	}]
	zone.set_definition(definition)
	zone.world_mode = true
	add_child(zone)
	await get_tree().process_frame
	var item: Interactable = zone.items.get("cartel_prueba") as Interactable
	assert_object(item).is_not_null()
	if item == null:
		return
	assert_object(item.art).is_not_null()
	item.activate()
	await get_tree().process_frame
	if zone.door != null:
		assert_bool(zone.door.is_open).is_false()
	assert_str(zone.hud.notice_label.text).is_equal("Cartel de prueba")


## Cobertura de la fase: cada actor guionado de cada zona (salvo la beta, que
## tiene suite propia) debe tener un interactuable de conversación.
func test_all_generic_zones_expose_interactable_scripted_actors() -> void:
	var files: PackedStringArray = DirAccess.get_files_at("res://data/zones")
	var revisadas: int = 0
	var actores: int = 0
	for nombre: String in files:
		if not nombre.ends_with(".json"):
			continue
		revisadas += 1
		if nombre == "despliegue_cero.json":
			continue
		var ruta: String = "res://data/zones/" + nombre
		var definition: ZoneDefinition = ZoneDefinition.load_from(ruta)
		var zone: ZoneBase = load("res://scenes/zones/zone.tscn").instantiate()
		zone.set_definition(definition)
		zone.world_mode = true
		add_child(zone)
		await get_tree().process_frame
		for entry: Dictionary in definition.list("actors"):
			var id: String = str(entry.get("id", ""))
			if str(entry.get("species", "")).is_empty():
				continue  # Progenitores: cubiertos por progenitor_encounter_test
			var guard: Guard = null
			for candidate: Guard in zone.guards():
				if zone.id_of_guard(candidate) == id:
					guard = candidate
					break
			assert_object(guard).override_failure_message(
				"%s: actor %s sin guardia" % [ruta, id]
			).is_not_null()
			if guard == null:
				continue
			var found: bool = false
			for child: Node in guard.get_children():
				if child is Interactable \
						and (child as Interactable).item_id == id \
						and (child as Interactable).kind == Interactable.Kind.NPC:
					found = true
					break
			assert_bool(found).override_failure_message(
				"%s: actor %s sin interactuable" % [ruta, id]
			).is_true()
			actores += 1
		zone.queue_free()
		await get_tree().process_frame
	assert_int(revisadas).is_equal(24)
	assert_int(actores).is_greater(20)

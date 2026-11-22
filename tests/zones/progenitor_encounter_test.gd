extends GdUnitTestSuite
## Encuentro con los progenitores: arte propio, objeto de conversación, diálogo
## con versión y pista, insulto que abre la pelea y consecuencia al morir.

const ITEM_PREFIX: String = "progenitor_"
const ART_FOLDER: String = "res://art/shared/"

func before_test() -> void:
	TestSupport.reset_session()
	Sandbox.pending_save = {}


func _mount(zone_path: String) -> ZoneBase:
	var zone: ZoneBase = auto_free(load("res://scenes/zones/zone.tscn").instantiate())
	var definition: ZoneDefinition = ZoneDefinition.load_from(zone_path)
	zone.set_definition(definition)
	zone.world_mode = true
	add_child(zone)
	await get_tree().process_frame
	return zone


func _guard_with_item(zone: ZoneBase, progenitor: String) -> Guard:
	var wanted: String = ITEM_PREFIX + progenitor
	for guard: Guard in zone.guards():
		for child: Node in guard.get_children():
			if child is Interactable and (child as Interactable).item_id == wanted:
				return guard
	return null


func _item_of(guard: Guard, progenitor: String) -> Interactable:
	var wanted: String = ITEM_PREFIX + progenitor
	for child: Node in guard.get_children():
		if child is Interactable and (child as Interactable).item_id == wanted:
			return child as Interactable
	return null


func _option_index(dialogue: LiveDialogue, label: String) -> int:
	for index: int in range(dialogue.options().size()):
		var entry: Array = dialogue.options()[index]
		if str(entry[0]) == label:
			return index
	fail("No existe la opción «%s» en el diálogo" % label)
	return -1


func test_los_quince_progenitores_tienen_arte_y_dialogo() -> void:
	for progenitor: String in ProgenitorDialogues.ids():
		var entry: Dictionary = ProgenitorCatalog.entry(progenitor)
		var art: String = str(entry.get("art", ""))
		assert_bool(art.begins_with("progenitores/")).is_true().override_failure_message(
			"%s: arte no conectado" % progenitor
		)
		for suffix: String in GuardVisual.VIEW_SUFFIX:
			var path: String = ART_FOLDER + art + suffix + ".svg"
			assert_bool(ResourceLoader.exists(path)).is_true().override_failure_message(
				"Falta %s" % path
			)
		var tree: Dictionary = ProgenitorDialogues.tree_for(progenitor)
		assert_bool(tree.has("root")).is_true().override_failure_message(
			"%s: sin nodo root" % progenitor
		)
		assert_bool(tree.has("version")).is_true().override_failure_message(
			"%s: sin versión del misterio" % progenitor
		)
		assert_bool(tree.has("pista") or progenitor == "contestador").is_true()
		assert_bool(tree.has("insultado")).is_true().override_failure_message(
			"%s: sin respuesta al insulto" % progenitor
		)


func test_las_zonas_montan_al_progenitores_con_sus_cinco_vistas() -> void:
	for progenitor: String in ProgenitorDialogues.ids():
		var zone_id: String = str(ProgenitorCatalog.entry(progenitor).get("zone", ""))
		if zone_id == "despliegue_cero" or zone_id.is_empty():
			continue
		var zone: ZoneBase = await _mount("res://data/zones/%s.json" % zone_id)
		var guard: Guard = _guard_with_item(zone, progenitor)
		assert_bool(guard != null).is_true().override_failure_message(
			"%s: no se montó al progenitor en %s" % [progenitor, zone_id]
		)
		if guard == null:
			continue
		assert_int(guard.visual.art_views.size()).is_equal(GuardVisual.VIEW_SUFFIX.size())
		for view: Texture2D in guard.visual.art_views:
			assert_bool(view != null).is_true().override_failure_message(
				"%s: falta una vista cargada" % progenitor
			)
		assert_bool(_item_of(guard, progenitor) != null).is_true()


func test_abrir_dialogo_muestra_saludo_version_y_pista() -> void:
	var zone: ZoneBase = await _mount("res://data/zones/taller.json")
	var guard: Guard = _guard_with_item(zone, "biela")
	assert_bool(guard != null).is_true()
	var item: Interactable = _item_of(guard, "biela")
	item.activate()
	var dialogue: LiveDialogue = zone.live_world.dialogue
	assert_bool(dialogue.is_open()).is_true()
	assert_bool(dialogue.is_progenitor()).is_true()
	var root: Dictionary = ProgenitorDialogues.tree_for("biela")["root"]
	assert_str(dialogue.progenitor_bubble.text).is_equal(str(root["text"]))
	assert_int(dialogue.options().size()).is_greater_equal(4)
	dialogue.choose(_option_index(dialogue, "¿Qué versión tienes?"))
	assert_bool(dialogue.progenitor_bubble.text.contains("articulaciones")).is_true()
	dialogue.choose(_option_index(dialogue, "¿Y una pista?"))
	assert_bool(dialogue.progenitor_bubble.text.contains("pieza")).is_true()
	dialogue.close()
	assert_bool(dialogue.is_open()).is_false()


func test_el_insulto_abre_la_opcion_de_golpear() -> void:
	var zone: ZoneBase = await _mount("res://data/zones/taller.json")
	var guard: Guard = _guard_with_item(zone, "biela")
	_item_of(guard, "biela").activate()
	var dialogue: LiveDialogue = zone.live_world.dialogue
	dialogue.choose(_option_index(dialogue, "Insultar"))
	assert_bool(dialogue.progenitor_bubble.text.contains("rótula")).is_true()
	assert_int(_option_index(dialogue, "Golpear")).is_greater_equal(0)
	dialogue.choose(_option_index(dialogue, "Golpear"))
	assert_bool(dialogue.is_open()).is_false()
	assert_bool(zone.combat.target == guard).is_true()


func test_hablar_no_crea_un_ciudadano_duplicado() -> void:
	var zone: ZoneBase = await _mount("res://data/zones/taller.json")
	var guard: Guard = _guard_with_item(zone, "biela")
	var before: int = zone.live_world.citizens.size()
	_item_of(guard, "biela").activate()
	assert_bool(zone.live_world.sim.npcs.has("progenitor_biela")).is_false()
	assert_int(zone.live_world.citizens.size()).is_equal(before)
	zone.live_world.dialogue.close()


func test_caer_un_progenitor_deja_constancia_en_la_investigacion() -> void:
	var zone: ZoneBase = await _mount("res://data/zones/taller.json")
	zone._on_progenitor_fell("biela")
	assert_bool(zone.investigation.has_flag(ITEM_PREFIX + "biela_muerto")).is_true()

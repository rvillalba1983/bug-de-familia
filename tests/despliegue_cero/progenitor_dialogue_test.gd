extends GdUnitTestSuite
## Don Ramón y El Contestador también tienen encuentro propio, sin perder la
## bobina de la beta ni duplicar al Contestador como ciudadano.

const PATH: String = "res://scenes/despliegue_cero/despliegue_cero_zone.tscn"

var zone: DespliegueCeroZone
var runner: GdUnitSceneRunner

func before_test() -> void:
	TestSupport.reset_session()
	DespliegueCeroZone.forced_hour = 12
	runner = scene_runner(PATH)
	zone = runner.scene()


func after_test() -> void:
	DespliegueCeroZone.forced_hour = -1
	get_tree().paused = false


func _item_of(actor: Node2D, progenitor: String) -> Interactable:
	var wanted: String = "progenitor_" + progenitor
	for child: Node in actor.get_children():
		if child is Interactable and (child as Interactable).item_id == wanted:
			return child as Interactable
	return null


func _option_index(dialogue: LiveDialogue, label: String) -> int:
	var index: int = _find_option(dialogue, label)
	if index < 0:
		fail("No existe la opción «%s» en el diálogo" % label)
	return index


func _find_option(dialogue: LiveDialogue, label: String) -> int:
	for index: int in range(dialogue.options().size()):
		var entry: Array = dialogue.options()[index]
		if str(entry[0]) == label:
			return index
	return -1


func test_don_ramon_exige_discutir_antes_de_hablar() -> void:
	assert_bool(zone.ramon != null).is_true()
	var item: Interactable = _item_of(zone.ramon, "ramon")
	assert_bool(item != null).is_true()
	item.activate()
	var dialogue: LiveDialogue = zone.live_world.dialogue
	assert_bool(dialogue.is_progenitor()).is_true()
	assert_bool(dialogue.progenitor_bubble.text.contains("Discute")).is_true()
	assert_int(_option_index(dialogue, "Discutir")).is_greater_equal(0)
	assert_int(_find_option(dialogue, "¿Qué versión tienes?")).is_equal(-1)
	dialogue.choose(_option_index(dialogue, "Discutir"))
	assert_bool(dialogue.progenitor_bubble.text.contains("salió bien")).is_true()
	dialogue.close()


func test_don_ramon_usa_las_cinco_vistas_propias() -> void:
	var views: Array[Texture2D] = zone.ramon.visual.art_views
	assert_int(views.size()).is_equal(GuardVisual.VIEW_SUFFIX.size())
	for view: Texture2D in views:
		assert_bool(view != null).is_true()


func test_el_contestador_usa_su_dialogo_y_entrega_la_bobina() -> void:
	var item: Interactable = zone.investigation.npc_nodes["contestador"]
	assert_bool(item.art != null).is_true()
	zone.investigation.flags["tiene_bobina"] = true
	item.activate()
	var dialogue: LiveDialogue = zone.live_world.dialogue
	assert_bool(dialogue.is_progenitor()).is_true()
	assert_bool(dialogue.progenitor_bubble.text.contains("grabación")).is_true()
	assert_bool(zone.live_world.sim.npcs.has("progenitor_contestador")).is_false()
	dialogue.choose(_option_index(dialogue, "Meter la bobina que falta"))
	assert_bool(zone.investigation.has_flag("bobina_puesta")).is_true()
	dialogue.close()


func test_el_contestador_muerto_sigue_visible_y_no_reabre_dialogo() -> void:
	var item: Interactable = zone.investigation.npc_nodes["contestador"]
	item.activate()
	var dialogue: LiveDialogue = zone.live_world.dialogue
	dialogue.choose(_option_index(dialogue, "Insultar"))
	dialogue.choose(_option_index(dialogue, "Golpear"))
	await get_tree().process_frame
	assert_bool(zone.investigation.has_flag("progenitor_contestador_muerto")).is_true()
	assert_bool(item.visible).is_true()
	assert_bool(item.used).is_true()
	item.activate()
	await get_tree().process_frame
	assert_bool(dialogue.is_open()).is_false()

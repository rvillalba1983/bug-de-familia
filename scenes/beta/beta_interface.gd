class_name BetaInterface
extends RefCounted
## Monta la interfaz propia de la beta sobre la común de cualquier nivel.


static func build(zone: BetaZone) -> void:
	var layer: CanvasLayer = CanvasLayer.new()
	layer.layer = 2
	zone.add_child(layer)
	zone.rain_label = LevelHud.make_label(layer, "BETA_RAIN", Vector2(760.0, 150.0), 26)
	zone.rain_label.visible = false
	_build_chat(zone, layer)
	for child: Node in zone.player.get_children():
		if child is CameraZoom:
			(child as CameraZoom).screen_shift = IrcChat.AREA.end.x * 0.5
	layer.add_child(ControlsWindow.new())
	_build_pause_view(zone, layer)
	var edges: ThreatEdges = ThreatEdges.new()
	edges.level = zone
	layer.add_child(edges)
	zone.conversion.converted.connect(zone.battles.on_converted)
	zone.ai.route_hint = zone.challenges.next_route
	zone.ai.treason_hint = zone.least_friendly_species
	var controls: ControlsPanel = ControlsPanel.new()
	controls.pause = zone.pause
	var filter: ScreenFilter = zone.screen_filter
	controls.filter_changed.connect(func() -> void: filter.apply_settings())
	zone.add_child(controls)
	var hint: KeyHint = KeyHint.new()
	hint.player = zone.player
	zone.actors.add_child(hint)


static func _build_chat(zone: BetaZone, layer: CanvasLayer) -> void:
	var irc: IrcChat = IrcChat.new()
	irc.team = zone.ai.team
	zone.ramon_item().body_hidden = true
	layer.add_child(irc)
	irc.set_topic(TranslationServer.translate(zone.objective_key()))
	zone.ai.chat = irc


## Lo que aparece solo durante la pausa táctica.
static func _build_pause_view(zone: BetaZone, layer: CanvasLayer) -> void:
	var spectres: AiSpectres = AiSpectres.new()
	spectres.team = zone.ai.team
	layer.add_child(spectres)
	zone.pause.paused_changed.connect(spectres.set_shown)
	zone.screen_filter = ScreenFilter.new()
	zone.add_child(zone.screen_filter)
	zone.pause.paused_changed.connect(zone.screen_filter.set_shown)
	var markers: PauseMarkers = PauseMarkers.new()
	markers.level = zone
	layer.add_child(markers)
	zone.pause.paused_changed.connect(markers.set_shown)

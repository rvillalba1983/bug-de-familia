class_name GameWorld
extends Node2D
## Escena raíz del mundo multi-zona (ADR 0027).
##
## Monta el gestor de zonas, que decide qué zona se muestra y simula las demás.
## Durante cada transición se enseña una pantalla de carga con las IAs del
## destino como fantasmas (P-26, opción 1a).

const LOADING_LAYER: int = 30
const TITLE_SIZE: int = 40
const ZONE_SIZE: int = 24
const HINT_SIZE: int = 16

var manager: ZoneManager
var zone_host: Node2D
var loading: CanvasLayer
var ghosts: AiSpectres
var team: AiTeam
var _zone_label: Label

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()
	_build_loading_screen()
	zone_host = Node2D.new()
	zone_host.name = "ZoneHost"
	add_child(zone_host)
	manager = ZoneManager.new()
	manager.name = "ZoneManager"
	manager.setup(zone_host)
	manager.transition_started.connect(_on_transition_started)
	manager.transition_finished.connect(_on_transition_finished)
	add_child(manager)
	if not manager.start():
		push_error("GameWorld: no se pudo montar la zona inicial")


func _build_loading_screen() -> void:
	loading = CanvasLayer.new()
	loading.layer = LOADING_LAYER
	loading.process_mode = Node.PROCESS_MODE_ALWAYS
	loading.visible = false
	add_child(loading)
	var backdrop: ColorRect = ColorRect.new()
	backdrop.color = Color(0.05, 0.04, 0.09, 0.96)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	loading.add_child(backdrop)
	var title: Label = Label.new()
	title.text = tr("UI_LOADING")
	title.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	title.offset_top = 120.0
	title.add_theme_font_size_override(&"font_size", TITLE_SIZE)
	loading.add_child(title)
	_zone_label = Label.new()
	_zone_label.text = ""
	_zone_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_zone_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_zone_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	_zone_label.offset_top = 180.0
	_zone_label.add_theme_font_size_override(&"font_size", ZONE_SIZE)
	loading.add_child(_zone_label)
	team = AiTeam.new()
	ghosts = AiSpectres.new()
	ghosts.team = team
	ghosts.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	loading.add_child(ghosts)
	var hint: Label = Label.new()
	hint.text = tr("UI_LOADING_HINT")
	hint.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	hint.offset_bottom = -80.0
	hint.add_theme_font_size_override(&"font_size", HINT_SIZE)
	loading.add_child(hint)


func _on_transition_started(_from_zone: String, to_zone: String) -> void:
	var zone: ZoneDefinition = manager.registry.zone(to_zone) if manager != null else null
	_zone_label.text = zone.display_name if zone != null else to_zone
	team.start(_rng)
	ghosts.set_shown(true)
	loading.visible = true


func _on_transition_finished(_zone_id: String) -> void:
	ghosts.set_shown(false)
	loading.visible = false

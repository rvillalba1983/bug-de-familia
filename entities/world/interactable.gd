class_name Interactable
extends Node2D
## Objeto con el que el jugador interactúa con la tecla E.

signal activated(item: Interactable)

const GROUP: StringName = &"interactable"
const RANGE: float = 100.0
const ART_ICON_HEIGHT: float = 56.0
const RUBBLE_ART: Array = ["caja_rota", 80.0, 40.0]

enum Kind { CRATE, TERMINAL, PICKUP_LEG, PICKUP_ARM, NPC, EVIDENCE }

const LABELS: Dictionary = {
	Kind.CRATE: "ITEM_CRATE",
	Kind.TERMINAL: "ITEM_TERMINAL",
	Kind.PICKUP_LEG: "ITEM_PICKUP_LEG",
	Kind.PICKUP_ARM: "ITEM_PICKUP_ARM",
	Kind.NPC: "",
	Kind.EVIDENCE: "",
}
const COLORS: Dictionary = {
	Kind.CRATE: Color("#b98a4e"),
	Kind.TERMINAL: Color("#35e0ff"),
	Kind.PICKUP_LEG: Color("#7fe07f"),
	Kind.PICKUP_ARM: Color("#7fe07f"),
	Kind.NPC: Color("#b08ad0"),
	Kind.EVIDENCE: Color("#e8d070"),
}

var kind: Kind = Kind.CRATE
var item_id: String = ""
var used: bool = false
var custom_label: String = ""
var custom_color: Color = Color.TRANSPARENT
var reusable: bool = false
## Si existe, se dibuja en lugar del cuadro de color.
var art: Texture2D
## Para personajes que ya se dibujan solos.
var body_hidden: bool = false
## Ya no se puede usar, pero se sigue viendo: por ejemplo, un grupo que se marcha andando.
var drawn_when_used: bool = false


func setup(new_id: String, new_kind: Kind, at: Vector2) -> void:
	item_id = new_id
	kind = new_kind
	position = at
	add_to_group(GROUP)


func _draw() -> void:
	if body_hidden:
		return
	if is_rubble():
		PropArt.draw_entry(self, RUBBLE_ART)
		return
	if used and kind != Kind.TERMINAL and not drawn_when_used:
		return
	if art != null:
		draw_texture_rect(art, Rect2(-28.0, -56.0, 56.0, 56.0), false)
	else:
		PropArt.draw_entry(self, PropArt.entry_for(item_id, kind))


## Una caja rota deja restos, que se siguen pudiendo convertir.
func is_rubble() -> bool:
	return used and kind == Kind.CRATE


## Altura del dibujo, para colocar encima el aviso de la tecla.
func art_height() -> float:
	if body_hidden:
		return GuardVisual.ART_HEIGHT * CharacterScale.value
	if art != null:
		return ART_ICON_HEIGHT
	var entry: Array = PropArt.entry_for(item_id, kind)
	return float(entry[2]) * PropArt.scale_of(entry)


## Ranuras donde puede guardarse este objeto; vacío si no se recoge.
func pickup_slots() -> Array[ModularBody.Slot]:
	match kind:
		Kind.PICKUP_LEG:
			return [ModularBody.Slot.LEG_LEFT, ModularBody.Slot.LEG_RIGHT]
		Kind.PICKUP_ARM:
			return [ModularBody.Slot.ARM_MAIN_LEFT, ModularBody.Slot.ARM_MAIN_RIGHT]
	return []


func is_pickup() -> bool:
	return not pickup_slots().is_empty()


func activate() -> void:
	if used:
		return
	if not reusable:
		mark_used()
	activated.emit(self)


func mark_used() -> void:
	used = true
	queue_redraw()

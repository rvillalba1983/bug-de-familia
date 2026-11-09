class_name Interactable
extends Node2D
## Objeto con el que el jugador interactúa con la tecla E.

signal activated(item: Interactable)

const GROUP: StringName = &"interactable"
const RANGE: float = 100.0

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
## Para personajes que ya se dibujan solos: sin cuadro, y el nombre solo de cerca.
var body_hidden: bool = false
var show_label: bool = true


func setup(new_id: String, new_kind: Kind, at: Vector2) -> void:
	item_id = new_id
	kind = new_kind
	position = at
	add_to_group(GROUP)


func _draw() -> void:
	if body_hidden:
		if show_label:
			WorldLabel.draw_on(self, custom_label, Vector2(0.0, -112.0))
		return
	if is_rubble():
		_draw_rubble()
		return
	if used and kind != Kind.TERMINAL:
		return
	var color: Color = Color("#55606a") if used else COLORS[kind]
	if custom_color.a > 0.0:
		color = custom_color
	if art != null:
		draw_texture_rect(art, Rect2(-24.0, -44.0, 48.0, 48.0), false)
	else:
		draw_rect(Rect2(-16.0, -32.0, 32.0, 32.0), color)
	if not used:
		var text: String = custom_label if not custom_label.is_empty() else tr(LABELS[kind] as String)
		WorldLabel.draw_on(self, text, Vector2(0.0, -40.0))


## Una caja rota deja restos, que se siguen pudiendo convertir.
func is_rubble() -> bool:
	return used and kind == Kind.CRATE


func _draw_rubble() -> void:
	var color: Color = COLORS[Kind.CRATE]
	draw_rect(Rect2(-20.0, -9.0, 15.0, 9.0), color.darkened(0.15))
	draw_rect(Rect2(-3.0, -13.0, 11.0, 13.0), color.darkened(0.35))
	draw_rect(Rect2(10.0, -6.0, 11.0, 6.0), color.darkened(0.25))
	WorldLabel.draw_on(self, tr("ITEM_CRATE_BROKEN"), Vector2(0.0, -20.0))


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

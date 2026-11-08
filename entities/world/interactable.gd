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


func setup(new_id: String, new_kind: Kind, at: Vector2) -> void:
	item_id = new_id
	kind = new_kind
	position = at
	add_to_group(GROUP)


func _draw() -> void:
	if used and kind != Kind.TERMINAL:
		return
	var color: Color = Color("#55606a") if used else COLORS[kind]
	if custom_color.a > 0.0:
		color = custom_color
	draw_rect(Rect2(-16.0, -32.0, 32.0, 32.0), color)
	if not used:
		var text: String = custom_label if not custom_label.is_empty() else tr(LABELS[kind] as String)
		WorldLabel.draw_on(self, text, Vector2(0.0, -40.0))


func activate() -> void:
	if used:
		return
	if not reusable:
		mark_used()
	activated.emit(self)


func mark_used() -> void:
	used = true
	queue_redraw()

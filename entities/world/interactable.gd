class_name Interactable
extends Node2D
## Objeto con el que el jugador interactúa con la tecla E.

signal activated(item: Interactable)

const GROUP: StringName = &"interactable"
const RANGE: float = 100.0

enum Kind { CRATE, TERMINAL, PICKUP_LEG, PICKUP_ARM }

const COLORS: Dictionary = {
	Kind.CRATE: Color("#b98a4e"),
	Kind.TERMINAL: Color("#35e0ff"),
	Kind.PICKUP_LEG: Color("#7fe07f"),
	Kind.PICKUP_ARM: Color("#7fe07f"),
}

var kind: Kind = Kind.CRATE
var item_id: String = ""
var used: bool = false


func setup(new_id: String, new_kind: Kind, at: Vector2) -> void:
	item_id = new_id
	kind = new_kind
	position = at
	add_to_group(GROUP)


func _draw() -> void:
	if used and kind != Kind.TERMINAL:
		return
	var color: Color = Color("#55606a") if used else COLORS[kind]
	draw_rect(Rect2(-16.0, -32.0, 32.0, 32.0), color)


func activate() -> void:
	if used:
		return
	mark_used()
	activated.emit(self)


func mark_used() -> void:
	used = true
	queue_redraw()

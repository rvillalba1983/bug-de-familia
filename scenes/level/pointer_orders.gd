class_name PointerOrders
extends RefCounted
## Traduce el clic de mover en la orden que toca: atacar, ir y usar, o andar.

const USE_CLICK_RADIUS: float = 56.0

var level: Sandbox

var _pending_use: Interactable


func _init(owner_level: Sandbox) -> void:
	level = owner_level


func order_at(point: Vector2) -> void:
	_pending_use = null
	var enemy: Guard = enemy_at(point)
	if enemy != null and (not enemy.passive or enemy.is_alert() or _is_selected(enemy)):
		level.combat.engage(enemy)
		return
	level.combat.disengage()
	var item: Interactable = _usable_at(point)
	if item != null:
		_go_and_use(item)
		return
	level.player.set_path(level.nav.find_path(level.player.global_position, point))


## Al llegar, se usa solo. Si te mueves con el teclado, la orden se cancela.
func track(feet: Vector2) -> void:
	if _pending_use == null:
		return
	if not is_instance_valid(_pending_use) or _pending_use.used:
		_pending_use = null
	elif feet.distance_to(_pending_use.global_position) <= Interactable.RANGE:
		var item: Interactable = _pending_use
		_pending_use = null
		level.player.set_path(PackedVector2Array())
		item.activate()
	elif not level.player.has_path():
		_pending_use = null


## Lo que hay bajo el puntero y se puede usar: objeto, persona o rastro.
func _usable_at(point: Vector2) -> Interactable:
	var best: Interactable = null
	var best_distance: float = USE_CLICK_RADIUS
	for node: Node in level.get_tree().get_nodes_in_group(Interactable.GROUP):
		var item: Interactable = node as Interactable
		if item.used or item.is_pickup():
			continue
		var center: Vector2 = item.global_position - Vector2(0.0, item.art_height() * 0.5)
		var distance: float = minf(item.global_position.distance_to(point), center.distance_to(point))
		if distance <= best_distance:
			best = item
			best_distance = distance
	return best


func _go_and_use(item: Interactable) -> void:
	_pending_use = item
	var player: Player = level.player
	if player.global_position.distance_to(item.global_position) > Interactable.RANGE:
		player.set_path(level.nav.find_path(player.global_position, item.global_position))


func _is_selected(enemy: Guard) -> bool:
	var current: Selectable = level.selection.current
	return current != null and current.get_parent() == enemy


## Usa el mismo criterio que la selección: clic izquierdo y derecho eligen a la misma persona.
func enemy_at(point: Vector2) -> Guard:
	var picked: Selectable = level.selection.pick(point)
	if picked == null or not picked.get_parent() is Guard:
		return null
	var enemy: Guard = picked.get_parent()
	return null if enemy.is_down() else enemy

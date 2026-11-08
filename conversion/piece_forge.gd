class_name PieceForge
extends RefCounted
## Crea la pieza. Nunca falla: el conocimiento solo mejora las probabilidades.

const MIN_POWER: float = 0.6
const MAX_POWER: float = 1.4


## score va de 0 (todo mal) a 1 (todo bien y rápido).
static func forge(
	catalog: ConversionCatalog,
	material_id: String,
	objective_id: String,
	kind: BodyPiece.Kind,
	score: float,
	rng: RandomNumberGenerator
) -> BodyPiece:
	var piece: BodyPiece = BodyPiece.new(kind)
	var power: float = roll_power(score, rng)
	var material: Dictionary = catalog.materials[material_id]
	var objective: Dictionary = catalog.objectives[objective_id]
	piece.metallic = bool(material.get("metal", true))
	var chosen: Array = _pick_properties(catalog, material["properties"], score, rng)
	for id: String in chosen:
		_apply_effects(piece, catalog.properties[id], power)
	var action_ids: Array = (objective["actions"] as Array).duplicate()
	_shuffle(action_ids, rng)
	var count: int = 1 + (1 if rng.randf() < 0.2 + 0.6 * score else 0)
	for id: String in action_ids.slice(0, mini(count, action_ids.size())):
		var action: Dictionary = catalog.actions[id]
		piece.actions.append({"id": id, "name": action["name"], "active": action["active"]})
	piece.label = _build_label(catalog, material, objective, chosen, piece.actions)
	piece.description = _build_description(catalog, chosen, piece.actions)
	return piece


static func roll_power(score: float, rng: RandomNumberGenerator) -> float:
	return lerpf(MIN_POWER, MAX_POWER, pow(rng.randf(), 1.0 / (1.0 + 2.0 * score)))


static func _pick_properties(
	catalog: ConversionCatalog, group: Array, score: float, rng: RandomNumberGenerator
) -> Array:
	var count: int = 1 + (1 if rng.randf() < 0.3 + 0.6 * score else 0)
	var pool: Array = group.duplicate()
	var chosen: Array = []
	while chosen.size() < count and not pool.is_empty():
		var weights: PackedFloat32Array = PackedFloat32Array()
		for id: String in pool:
			var positive: bool = catalog.properties[id]["positive"]
			weights.append(1.0 + 3.0 * score if positive else 2.0 - score)
		var index: int = rng.rand_weighted(weights)
		chosen.append(pool[index])
		pool.remove_at(index)
	return chosen


static func _apply_effects(piece: BodyPiece, property: Dictionary, power: float) -> void:
	var effects: Dictionary = property["effects"]
	for key: String in effects:
		var value: float = float(effects[key])
		var positive: bool = property["positive"]
		if key == "speed" or key == "stun":
			value = 1.0 + (value - 1.0) * power
		elif positive:
			value *= power
		piece.effects[key] = value


static func _build_label(
	catalog: ConversionCatalog, material: Dictionary, objective: Dictionary,
	chosen: Array, actions: Array
) -> String:
	var names: Array[String] = []
	for id: String in chosen:
		names.append(str(catalog.properties[id]["name"]))
	for action: Dictionary in actions:
		names.append(str(action["name"]))
	return "%s · %s: %s" % [material["name"], objective["name"], ", ".join(names)]


static func _build_description(catalog: ConversionCatalog, chosen: Array, actions: Array) -> String:
	var lines: Array[String] = []
	for action: Dictionary in actions:
		lines.append(str(catalog.actions[action["id"]]["desc"]))
	for id: String in chosen:
		lines.append(str(catalog.properties[id]["desc"]))
	return " ".join(lines)


static func _shuffle(items: Array, rng: RandomNumberGenerator) -> void:
	for index: int in range(items.size() - 1, 0, -1):
		var other: int = rng.randi_range(0, index)
		var held: Variant = items[index]
		items[index] = items[other]
		items[other] = held

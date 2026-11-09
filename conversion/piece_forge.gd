class_name PieceForge
extends RefCounted
## Crea la pieza. Nunca falla: el conocimiento solo mejora las probabilidades.

const MIN_POWER: float = 0.6
const MAX_POWER: float = 1.4
## Efectos que multiplican; el resto suman o son marcas.
const MULTIPLIERS: Array[String] = [
	"speed", "stun", "melee", "sight", "dark_sight", "still_sight", "sight_mohocrata", "sight_jubilado",
	"damage_taken", "wear", "run_noise", "cooldown", "use_wear", "crouch_speed", "panic_speed",
	"one_leg", "night_off",
]
const FLAGS: Array[String] = ["clingy", "acid_proof", "head_guard", "tick_noise", "worry_noise", "excuse"]


## score va de 0 (todo mal) a 1 (todo bien y rápido).
static func forge(
	catalog: ConversionCatalog,
	material_id: String,
	objective_id: String,
	kind: BodyPiece.Kind,
	score: float,
	rng: RandomNumberGenerator,
	fixed_property: String = ""
) -> BodyPiece:
	var piece: BodyPiece = BodyPiece.new(kind)
	var power: float = roll_power(score, rng)
	piece.level = level_of(power)
	var material: Dictionary = catalog.materials[material_id]
	var objective: Dictionary = catalog.objectives[objective_id]
	piece.metallic = bool(material.get("metal", true))
	var chosen: Array = _pick_properties(catalog, material["properties"], score, rng)
	if not fixed_property.is_empty() and not chosen.has(fixed_property):
		chosen.append(fixed_property)
	for id: String in chosen:
		var property: Dictionary = catalog.properties[id]
		if property["effects"].has("random"):
			property = _surprise(catalog, rng)
		_apply_effects(piece, property, power)
	var action_ids: Array = (objective["actions"] as Array).duplicate()
	_shuffle(action_ids, rng)
	var count: int = 1 + (1 if rng.randf() < 0.2 + 0.6 * score else 0)
	for id: String in action_ids.slice(0, mini(count, action_ids.size())):
		var action: Dictionary = catalog.actions[id]
		piece.actions.append({"id": id, "name": action["name"], "active": action["active"]})
		for key: String in action.get("fx", {}):
			_merge(piece, key, float(action["fx"][key]))
	piece.label = _build_label(catalog, material, objective, chosen, piece.actions)
	piece.description = _build_description(catalog, chosen, piece.actions)
	piece.pick_visual_variant(piece.label)
	return piece


## Reparte la potencia entre los niveles 1 a 5.
static func level_of(power: float) -> int:
	var ratio: float = (power - MIN_POWER) / (MAX_POWER - MIN_POWER)
	return clampi(1 + int(ratio * 5.0), 1, 5)


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


## Defecto de fábrica: los efectos de otra propiedad cualquiera.
static func _surprise(catalog: ConversionCatalog, rng: RandomNumberGenerator) -> Dictionary:
	var pool: Array = catalog.properties.keys().filter(
		func(id: String) -> bool: return not catalog.properties[id]["effects"].has("random")
	)
	return catalog.properties[pool[rng.randi_range(0, pool.size() - 1)]]


static func _apply_effects(piece: BodyPiece, property: Dictionary, power: float) -> void:
	var effects: Dictionary = property["effects"]
	var positive: bool = property["positive"]
	for key: String in effects:
		var value: float = float(effects[key])
		if MULTIPLIERS.has(key):
			if positive or key == "speed" or key == "stun":
				value = 1.0 + (value - 1.0) * power
		elif positive and not FLAGS.has(key):
			value *= power
		_merge(piece, key, value)


## Varias fuentes del mismo efecto se acumulan en lugar de pisarse.
static func _merge(piece: BodyPiece, key: String, value: float) -> void:
	if not piece.effects.has(key):
		piece.effects[key] = value
	elif MULTIPLIERS.has(key):
		piece.effects[key] = float(piece.effects[key]) * value
	elif not FLAGS.has(key):
		piece.effects[key] = float(piece.effects[key]) + value


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

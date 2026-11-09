class_name LevelSaveState
extends RefCounted
## Traduce el estado de un nivel a los datos del único espacio de partida, y viceversa.


static func capture(level: Sandbox) -> Dictionary:
	var used: Array = []
	for id: String in level.items:
		if (level.items[id] as Interactable).used:
			used.append(id)
	var player: Player = level.player
	return {
		"dead": player.body.is_dead,
		"seed": level.rng.seed,
		"body": player.body.to_dict(),
		"player": {"x": player.global_position.x, "y": player.global_position.y},
		"used": used,
		"converted": level.converted_ids,
		"fallen": level.fallen_ids,
		"door_open": level.door.is_open,
		"ai": level.ai.team.to_dict(),
		"case": level.investigation.to_dict(),
		"challenge_done": level.challenge_done,
	}


## Datos de una partida recién empezada; el nivel se monta con ellos al recargar.
static func fresh(start: Vector2, seed_value: int, body: ModularBody) -> Dictionary:
	return {
		"dead": false,
		"seed": seed_value,
		"body": body.to_dict(),
		"player": {"x": start.x, "y": start.y},
		"used": [],
		"converted": [],
		"fallen": [],
		"door_open": false,
		"ai": {},
		"case": {},
		"challenge_done": false,
		"world": {},
	}


## Devuelve false si el cuerpo guardado no es válido.
static func restore(level: Sandbox, data: Dictionary) -> bool:
	var loaded_body: ModularBody = ModularBody.from_dict(data["body"])
	if data["dead"]:
		return true
	if loaded_body == null:
		return false
	level.replace_body(loaded_body)
	level.rng.seed = int(data.get("seed", 0))
	var start: Vector2 = level.start_point()
	var at: Dictionary = data.get("player", {})
	level.player.global_position = Vector2(float(at.get("x", start.x)), float(at.get("y", start.y)))
	_restore_entities(level, data)
	if data.get("door_open", false):
		level.open_door()
	level.ai.restore(data.get("ai", {}))
	level.investigation.restore(data.get("case", {}))
	if data.get("challenge_done", false):
		level.challenge_done = true
		level.hud.done_label.visible = true
	return true


static func _restore_entities(level: Sandbox, data: Dictionary) -> void:
	for id: Variant in data.get("used", []):
		if level.items.has(id):
			(level.items[id] as Interactable).mark_used()
			if id == Sandbox.ID_TERMINAL:
				level.open_door()
	for id: Variant in data.get("converted", []):
		level.converted_ids.append(id)
		level.remove_entity(str(id))
	for id: Variant in data.get("fallen", []):
		level.fallen_ids.append(id)
		level.remove_entity(str(id))

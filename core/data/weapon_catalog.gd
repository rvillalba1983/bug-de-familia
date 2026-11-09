class_name WeaponCatalog
extends RefCounted
## Armas del jugador y de los enemigos, según data/combat/weapons.json.

const PATH: String = "res://data/combat/weapons.json"
const THROWN_ID: String = "lanzar"
const ENEMY_MELEE: String = "golpe"
const ENEMY_RANGED: String = "pistola"
const PLAYER_FIELDS: Array[String] = ["damage", "stun", "range", "pellets", "spread", "noise", "noise_at_impact", "color"]
const ENEMY_FIELDS: Array[String] = ["kind", "damage", "range", "windup", "cooldown"]

static var _player: Dictionary = {}
static var _enemy: Dictionary = {}


static func thrown() -> Dictionary:
	return player(THROWN_ID)


static func has_player_weapon(id: String) -> bool:
	_ensure_loaded()
	return id != THROWN_ID and _player.has(id)


static func player(id: String) -> Dictionary:
	_ensure_loaded()
	return _player[id]


static func enemy(id: String) -> Dictionary:
	_ensure_loaded()
	return _enemy[id]


static func _ensure_loaded() -> void:
	if not _player.is_empty():
		return
	var data: Dictionary = DataFile.load_dictionary(PATH)
	_player = data.get("player", {})
	_enemy = data.get("enemy", {})
	DataFile.require_fields(PATH, _player, PLAYER_FIELDS)
	DataFile.require_fields(PATH, _enemy, ENEMY_FIELDS)
	for id: String in _player:
		var weapon: Dictionary = _player[id]
		weapon["pellets"] = int(weapon["pellets"])
		weapon["color"] = Color(str(weapon["color"]))

class_name ModularBody
extends RefCounted
## Reglas del cuerpo: ranuras, inventarios, desgaste, cambios y muerte.

signal piece_destroyed(slot: Slot)
signal piece_discarded(piece: BodyPiece)
signal changed
signal died

enum Slot {
	HEAD,
	ARM_MAIN_LEFT,
	ARM_MAIN_RIGHT,
	ARM_EXTRA_LEFT,
	ARM_EXTRA_RIGHT,
	LEG_LEFT,
	LEG_RIGHT,
}
enum Context { FREE, INTERACTING, PRE_FIGHT, FIGHTING }

const MAX_SPARES: int = 4
## Valores provisionales: ver docs/adr/0002-parametros-provisionales.md.
const ONE_LEG_SPEED_FACTOR: float = 0.5
## Una pierna dura unos 10 minutos andando a 180 píxeles por segundo.
const LEG_WEAR_PER_100_PX: float = 100.0 / 1080.0
## La cabeza recibe golpes con mucha menos probabilidad que una extremidad.
const HEAD_HIT_WEIGHT: int = 1
const LIMB_HIT_WEIGHT: int = 4

var context: Context = Context.FREE
var is_dead: bool = false

var _equipped: Dictionary = {}
var _spares: Dictionary = {}


func _init() -> void:
	for slot: int in Slot.values():
		_equipped[slot] = BodyPiece.new(kind_of(slot as Slot))
		_spares[slot] = [] as Array[BodyPiece]


static func kind_of(slot: Slot) -> BodyPiece.Kind:
	if slot == Slot.HEAD:
		return BodyPiece.Kind.HEAD
	if slot == Slot.LEG_LEFT or slot == Slot.LEG_RIGHT:
		return BodyPiece.Kind.LEG
	return BodyPiece.Kind.ARM


func equipped(slot: Slot) -> BodyPiece:
	return _equipped[slot]


func spares(slot: Slot) -> Array[BodyPiece]:
	return _spares[slot]


func add_spare(slot: Slot, piece: BodyPiece) -> bool:
	if piece.kind != kind_of(slot) or spares(slot).size() >= MAX_SPARES:
		return false
	spares(slot).append(piece)
	changed.emit()
	return true


func discard_spare(slot: Slot, index: int) -> void:
	var piece: BodyPiece = spares(slot)[index]
	spares(slot).remove_at(index)
	piece_discarded.emit(piece)
	changed.emit()


## Libre sin interacción; antes de pelear, libre; en plena pelea, solo si la pieza se destruyó.
func can_swap(slot: Slot) -> bool:
	if is_dead:
		return false
	match context:
		Context.INTERACTING:
			return false
		Context.FIGHTING:
			return equipped(slot) == null
		_:
			return true


func swap(slot: Slot, spare_index: int) -> bool:
	if not can_swap(slot) or spare_index < 0 or spare_index >= spares(slot).size():
		return false
	var incoming: BodyPiece = spares(slot)[spare_index]
	var outgoing: BodyPiece = equipped(slot)
	if outgoing == null:
		spares(slot).remove_at(spare_index)
	else:
		spares(slot)[spare_index] = outgoing
	_equipped[slot] = incoming
	changed.emit()
	return true


func damage(slot: Slot, amount: float) -> void:
	var piece: BodyPiece = equipped(slot)
	if piece != null:
		_reduce(slot, amount * float(piece.effects.get("damage_taken", 1.0)))


func wear_piece(slot: Slot, amount: float) -> void:
	var piece: BodyPiece = equipped(slot)
	if piece != null:
		_reduce(slot, amount * float(piece.effects.get("wear", 1.0)))


## Multiplica un efecto de todas las piezas puestas.
func multiplier(key: String) -> float:
	var result: float = 1.0
	for piece: BodyPiece in _worn_pieces():
		result *= float(piece.effects.get(key, 1.0))
	return result


## Suma un efecto de todas las piezas puestas.
func total(key: String) -> float:
	var result: float = 0.0
	for piece: BodyPiece in _worn_pieces():
		result += float(piece.effects.get(key, 0.0))
	return result


func has_action(action_id: String) -> bool:
	for piece: BodyPiece in _worn_pieces():
		if piece.has_action(action_id):
			return true
	return false


## Lista de { id, name, slot } de las acciones que se activan con tecla.
func active_actions() -> Array:
	var result: Array = []
	for slot: int in Slot.values():
		var piece: BodyPiece = equipped(slot as Slot)
		if piece != null:
			for action: Dictionary in piece.actions:
				if action["active"]:
					result.append({"id": action["id"], "name": action["name"], "slot": slot})
	return result


func tick(delta: float) -> void:
	for piece: BodyPiece in _worn_pieces():
		var repair: float = float(piece.effects.get("self_repair", 0.0))
		if repair > 0.0:
			piece.durability = minf(piece.durability + repair * delta, BodyPiece.MAX_DURABILITY)


func has_worried_piece() -> bool:
	for piece: BodyPiece in _worn_pieces():
		if piece.effects.has("worry_noise") and piece.durability < 50.0:
			return true
	return false


func can_stow_in(slots: Array[Slot]) -> bool:
	for slot: Slot in slots:
		if spares(slot).size() < MAX_SPARES:
			return true
	return false


func has_room(slot: Slot) -> bool:
	return equipped(slot) == null or spares(slot).size() < MAX_SPARES


## Pone la pieza si la ranura está vacía; si no, la guarda como repuesto.
func receive(slot: Slot, piece: BodyPiece) -> bool:
	if piece.kind != kind_of(slot):
		return false
	if equipped(slot) == null:
		_equipped[slot] = piece
		changed.emit()
		return true
	return add_spare(slot, piece)


func damage_random(amount: float, rng: RandomNumberGenerator) -> void:
	var candidates: Array[int] = []
	for slot: int in Slot.values():
		if equipped(slot as Slot) != null:
			var weight: int = HEAD_HIT_WEIGHT if slot == Slot.HEAD else LIMB_HIT_WEIGHT
			for count: int in range(weight):
				candidates.append(slot)
	if not candidates.is_empty():
		damage(candidates[rng.randi_range(0, candidates.size() - 1)] as Slot, amount)


func wear_legs(distance: float) -> void:
	var amount: float = distance / 100.0 * LEG_WEAR_PER_100_PX
	wear_piece(Slot.LEG_LEFT, amount)
	wear_piece(Slot.LEG_RIGHT, amount)


func arm_count() -> int:
	var arms: int = 0
	for slot: int in Slot.values():
		if kind_of(slot as Slot) == BodyPiece.Kind.ARM and equipped(slot as Slot) != null:
			arms += 1
	return arms


func leg_count() -> int:
	var legs: int = 0
	for slot: Slot in [Slot.LEG_LEFT, Slot.LEG_RIGHT]:
		if equipped(slot) != null:
			legs += 1
	return legs


## Si se cierra la selección sin elegir cabeza, se pone la primera de repuesto.
func ensure_head() -> void:
	if equipped(Slot.HEAD) == null and not spares(Slot.HEAD).is_empty():
		_equipped[Slot.HEAD] = spares(Slot.HEAD).pop_front()
		changed.emit()


func speed_factor() -> float:
	var legs: int = leg_count()
	if legs == 2:
		return 1.0
	return ONE_LEG_SPEED_FACTOR if legs == 1 else 0.0


func to_dict() -> Dictionary:
	var result: Dictionary = {}
	for slot: int in Slot.values():
		var piece: BodyPiece = _equipped[slot]
		var spare_data: Array = []
		for spare: BodyPiece in _spares[slot]:
			spare_data.append(spare.to_dict())
		result[str(slot)] = {
			"equipped": piece.to_dict() if piece != null else null,
			"spares": spare_data,
		}
	return result


## Devuelve null si los datos no son válidos.
static func from_dict(data: Variant) -> ModularBody:
	if not data is Dictionary:
		return null
	var values: Dictionary = data
	var body: ModularBody = ModularBody.new()
	for slot: int in Slot.values():
		var key: String = str(slot)
		if not values.has(key) or not values[key] is Dictionary:
			return null
		var entry: Dictionary = values[key]
		if not entry.get("spares") is Array or not entry.has("equipped"):
			return null
		var piece: BodyPiece = null
		if entry["equipped"] != null:
			piece = BodyPiece.from_dict(entry["equipped"])
			if piece == null or piece.kind != kind_of(slot as Slot):
				return null
		body._equipped[slot] = piece
		for spare_data: Variant in entry["spares"]:
			var spare: BodyPiece = BodyPiece.from_dict(spare_data)
			if spare == null or not body.add_spare(slot as Slot, spare):
				return null
	return body


func _worn_pieces() -> Array[BodyPiece]:
	var result: Array[BodyPiece] = []
	for slot: int in Slot.values():
		if _equipped[slot] != null:
			result.append(_equipped[slot])
	return result


func _reduce(slot: Slot, amount: float) -> void:
	var piece: BodyPiece = equipped(slot)
	if piece == null or is_dead:
		return
	piece.durability = maxf(piece.durability - amount, 0.0)
	if piece.durability <= 0.0:
		_destroy(slot)
	changed.emit()


func _destroy(slot: Slot) -> void:
	_equipped[slot] = null
	var no_legs: bool = equipped(Slot.LEG_LEFT) == null and equipped(Slot.LEG_RIGHT) == null
	var no_head: bool = slot == Slot.HEAD and spares(Slot.HEAD).is_empty()
	if no_head or no_legs:
		is_dead = true
		died.emit()
		return
	piece_destroyed.emit(slot)

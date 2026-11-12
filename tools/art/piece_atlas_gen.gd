extends SceneTree
## Genera art/shared/atlas/piezas.png y data/art/atlas_piezas.json con las piezas de art/shared/rig/.
## Uso: godot --headless --path . -s tools/art/piece_atlas_gen.gd y después --import.

const SIDE: int = 2048
const PADDING: int = 2
## Las piezas se ven a la mitad de su tamaño: más resolución solo daría dientes de sierra.
const SCALE: float = 0.6
const SHADOW_SIZE: int = 64
const OUTPUT_IMAGE: String = "res://art/shared/atlas/piezas.png"
const OUTPUT_INDEX: String = "res://data/art/atlas_piezas.json"
const RIG_FOLDER: String = "res://art/shared/rig/"
const ACTIONS_PATH: String = "res://data/art/action_frames.json"
const FRAME_SIDE: int = 64
const COLOR_INK: Color = Color("#1b0e2a")
const COLOR_ARM: Color = Color("#8894b5")
const COLOR_WEAPON: Color = Color("#00e5ff")
const COLOR_ACCENT: Color = Color("#ffd400")


func _initialize() -> void:
	var pieces: Array[Dictionary] = _load_pieces()
	pieces.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a["image"].get_height() > b["image"].get_height())
	var atlas: Image = Image.create(SIDE, SIDE, false, Image.FORMAT_RGBA8)
	var entries: Dictionary = {}
	var x: int = PADDING
	var y: int = PADDING
	var shelf: int = 0
	for piece: Dictionary in pieces:
		var image: Image = piece["image"]
		if x + image.get_width() + PADDING > SIDE:
			x = PADDING
			y += shelf + PADDING
			shelf = 0
		assert(y + image.get_height() + PADDING <= SIDE, "La hoja se queda pequeña")
		atlas.blit_rect(image, Rect2i(Vector2i.ZERO, image.get_size()), Vector2i(x, y))
		entries[piece["key"]] = [x, y, image.get_width(), image.get_height(), piece["trim_x"], piece["trim_y"], piece["full"]]
		x += image.get_width() + PADDING
		shelf = maxi(shelf, image.get_height())
	var result: Error = atlas.save_png(OUTPUT_IMAGE)
	assert(result == OK, "No se puede guardar la hoja")
	FileAccess.open(OUTPUT_INDEX, FileAccess.WRITE).store_string(JSON.stringify(entries, "\t"))
	print("Hoja con %d piezas; altura usada %d de %d" % [pieces.size(), y + shelf, SIDE])
	quit()


func _load_pieces() -> Array[Dictionary]:
	var pieces: Array[Dictionary] = [_shadow()]
	for view: String in EnemyRigData.VIEWS:
		var parts: Array = (EnemyRigData.VIEWS[view]["joints"] as Dictionary).keys()
		parts.append("torso")
		for part: String in parts:
			pieces.append(_piece(RIG_FOLDER + view + "/" + part + ".svg", view + "/" + part))
	pieces.append_array(_action_frames())
	return pieces


func _piece(path: String, key: String) -> Dictionary:
	var source: Image = (load(path) as Texture2D).get_image()
	source.decompress()
	source.convert(Image.FORMAT_RGBA8)
	var full: int = roundi(float(source.get_width()) * SCALE)
	source.resize(full, roundi(float(source.get_height()) * SCALE), Image.INTERPOLATE_LANCZOS)
	var used: Rect2i = source.get_used_rect()
	return {"key": key, "image": source.get_region(used), "trim_x": used.position.x, "trim_y": used.position.y, "full": full}


## Fotogramas por acción dibujados por código con la paleta «Cuñado Radiactivo» (P-25).
## Origen: este generador con Godot 4.7.2; no es un SVG externo. Provisional.
func _action_frames() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var source: Variant = JSON.parse_string(FileAccess.get_file_as_string(ACTIONS_PATH))
	var acciones: Dictionary = (source as Dictionary).get("acciones", {})
	for accion: String in acciones:
		var claves: Array = acciones[accion]["frames"]
		for index: int in range(claves.size()):
			out.append(_action_frame(accion, index, claves.size(), str(claves[index])))
	return out


func _action_frame(accion: String, index: int, total: int, key: String) -> Dictionary:
	var image: Image = Image.create(FRAME_SIDE, FRAME_SIDE, false, Image.FORMAT_RGBA8)
	var fase: float = float(index) / float(maxi(total, 1))
	var angulo: float = _angulo(accion, fase)
	var hombro: Vector2 = Vector2(14.0, 50.0)
	var mano: Vector2 = hombro + Vector2(cos(angulo), sin(angulo)) * 30.0
	_linea(image, hombro, mano, COLOR_INK, 9.0)
	_linea(image, hombro, mano, COLOR_ARM, 5.0)
	var punta: Vector2 = mano + Vector2(cos(angulo), sin(angulo)) * 16.0
	_linea(image, mano, punta, COLOR_INK, 8.0)
	_linea(image, mano, punta, COLOR_WEAPON, 4.0)
	_punto(image, punta, 4.0, COLOR_ACCENT)
	return {"key": key, "image": image, "trim_x": 0, "trim_y": 0, "full": FRAME_SIDE}


func _angulo(accion: String, fase: float) -> float:
	match accion:
		"ataque":
			return lerpf(-1.2, -0.1, fase)
		"recarga":
			return lerpf(-0.2, -0.9, fase) + sin(fase * TAU) * 0.15
		_:
			return -0.65 + sin(fase * TAU) * 0.12


func _linea(image: Image, from: Vector2, to: Vector2, color: Color, width: float) -> void:
	var pasos: int = int(from.distance_to(to) * 2.0) + 1
	for step: int in range(pasos + 1):
		var at: Vector2 = from.lerp(to, float(step) / float(pasos))
		_punto(image, at, width * 0.5, color)


func _punto(image: Image, center: Vector2, radius: float, color: Color) -> void:
	var x0: int = maxi(int(center.x - radius), 0)
	var x1: int = mini(int(center.x + radius), FRAME_SIDE - 1)
	var y0: int = maxi(int(center.y - radius), 0)
	var y1: int = mini(int(center.y + radius), FRAME_SIDE - 1)
	for y: int in range(y0, y1 + 1):
		for x: int in range(x0, x1 + 1):
			if Vector2(float(x), float(y)).distance_to(center) <= radius:
				image.set_pixel(x, y, color)


func _shadow() -> Dictionary:
	var image: Image = Image.create(SHADOW_SIZE, SHADOW_SIZE, false, Image.FORMAT_RGBA8)
	var center: float = float(SHADOW_SIZE) * 0.5
	for y: int in range(SHADOW_SIZE):
		for x: int in range(SHADOW_SIZE):
			var distance: float = Vector2(float(x) + 0.5, float(y) + 0.5).distance_to(Vector2(center, center))
			image.set_pixel(x, y, Color(1.0, 1.0, 1.0, clampf(center - distance, 0.0, 1.0)))
	return {"key": PieceAtlas.SHADOW, "image": image, "trim_x": 0, "trim_y": 0, "full": SHADOW_SIZE}

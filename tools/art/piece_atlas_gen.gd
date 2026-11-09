extends SceneTree
## Genera art/beta/atlas/piezas.png y data/art/atlas_piezas.json con las piezas de art/beta/rig/.
## Uso: godot --headless --path . -s tools/art/piece_atlas_gen.gd y después --import.

const SIDE: int = 2048
const PADDING: int = 2
## Las piezas se ven a la mitad de su tamaño: más resolución solo daría dientes de sierra.
const SCALE: float = 0.6
const SHADOW_SIZE: int = 64
const OUTPUT_IMAGE: String = "res://art/beta/atlas/piezas.png"
const OUTPUT_INDEX: String = "res://data/art/atlas_piezas.json"
const RIG_FOLDER: String = "res://art/beta/rig/"


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
	return pieces


func _piece(path: String, key: String) -> Dictionary:
	var source: Image = (load(path) as Texture2D).get_image()
	source.decompress()
	source.convert(Image.FORMAT_RGBA8)
	var full: int = roundi(float(source.get_width()) * SCALE)
	source.resize(full, roundi(float(source.get_height()) * SCALE), Image.INTERPOLATE_LANCZOS)
	var used: Rect2i = source.get_used_rect()
	return {"key": key, "image": source.get_region(used), "trim_x": used.position.x, "trim_y": used.position.y, "full": full}


func _shadow() -> Dictionary:
	var image: Image = Image.create(SHADOW_SIZE, SHADOW_SIZE, false, Image.FORMAT_RGBA8)
	var center: float = float(SHADOW_SIZE) * 0.5
	for y: int in range(SHADOW_SIZE):
		for x: int in range(SHADOW_SIZE):
			var distance: float = Vector2(float(x) + 0.5, float(y) + 0.5).distance_to(Vector2(center, center))
			image.set_pixel(x, y, Color(1.0, 1.0, 1.0, clampf(center - distance, 0.0, 1.0)))
	return {"key": PieceAtlas.SHADOW, "image": image, "trim_x": 0, "trim_y": 0, "full": SHADOW_SIZE}

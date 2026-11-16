class_name DeathEffect
extends Node2D
## Efecto visual gamberro al morir. No cambia reglas: solo dibuja sobre el cadáver.

const GENERIC_COLOR: Color = Color("#7ec850")

var death: Dictionary = {}
var species_color: Color = Color.WHITE
var _time: float = 0.0
var _duration: float = 0.0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _particles: Array[Dictionary] = []
var _phase: int = 0


func play(p_death: Dictionary, p_species_color: Color = Color.WHITE) -> void:
	death = p_death
	species_color = p_species_color
	_duration = float(death.get("effect_duration", 0.0))
	var base_seed: int = hash(str(death.get("effect", "")))
	_rng.seed = base_seed + int(global_position.x + global_position.y * 10.0)
	_setup()
	set_process(true)
	queue_redraw()


func _setup() -> void:
	var effect: String = str(death.get("effect", "none"))
	_particles.clear()
	match effect:
		"trozos":
			_spawn_chunks(14, 180.0)
		"cohete":
			_launch_body()
		"confeti":
			_spawn_chunks(22, 140.0, true)
		"congelado":
			_phase = 0
		"estatua":
			_phase = 0
		"muelle":
			_bounce_body()
		"apagon":
			_phase = 0
		"oxidacion":
			_phase = 0
		"origami":
			_fold_body()
		"burbujas":
			_spawn_bubbles(8)
		"prensa":
			_press_body()
		"dispersion":
			_spawn_runners(4)


func _spawn_chunks(count: int, speed: float, colorful: bool = false) -> void:
	var base: Color = Color(str(death.get("effect_color", GENERIC_COLOR)))
	for i: int in range(count):
		var angle: float = _rng.randf_range(-PI, 0.0)
		var speed_now: float = _rng.randf_range(speed * 0.4, speed)
		var vel: Vector2 = Vector2(cos(angle), sin(angle)) * speed_now
		var col: Color = base
		if colorful:
			col = Color.from_hsv(_rng.randf(), 0.85, 1.0)
		_particles.append({
			"pos": Vector2(0.0, -20.0),
			"vel": vel,
			"size": _rng.randf_range(3.0, 7.0),
			"color": col,
			"life": _rng.randf_range(0.8, 1.3),
		})


func _spawn_bubbles(count: int) -> void:
	var base: Color = Color(str(death.get("effect_color", "#8fffe8")))
	for i: int in range(count):
		_particles.append({
			"pos": Vector2(_rng.randf_range(-18.0, 18.0), -10.0),
			"vel": Vector2(_rng.randf_range(-20.0, 20.0), _rng.randf_range(-60.0, -20.0)),
			"size": _rng.randf_range(6.0, 14.0),
			"color": base,
			"life": _rng.randf_range(0.8, 1.6),
			"ring": true,
		})


func _spawn_runners(count: int) -> void:
	for i: int in range(count):
		_particles.append({
			"pos": Vector2(0.0, -20.0),
			"vel": Vector2(_rng.randf_range(60.0, 140.0), _rng.randf_range(-20.0, 20.0)),
			"size": _rng.randf_range(8.0, 14.0),
			"color": species_color if species_color.a > 0.0 else Color.WHITE,
			"life": _rng.randf_range(0.8, 1.4),
			"runner": true,
		})


func _launch_body() -> void:
	var body: Node2D = _body()
	if body == null:
		return
	var target_y: float = body.position.y - 500.0
	var tween: Tween = create_tween()
	var up: PropertyTweener = tween.tween_property(body, "position:y", target_y, 1.2)
	up.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	var fade: PropertyTweener = tween.parallel().tween_property(body, "modulate:a", 0.0, 1.0)
	fade.set_delay(0.2)


func _bounce_body() -> void:
	var body: Node2D = _body()
	if body == null:
		return
	var base_y: float = body.position.y
	var tween: Tween = create_tween()
	var t1: PropertyTweener = tween.tween_property(body, "position:y", base_y - 60.0, 0.18)
	t1.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	var t2: PropertyTweener = tween.tween_property(body, "position:y", base_y, 0.18)
	t2.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	var t3: PropertyTweener = tween.tween_property(body, "position:y", base_y - 30.0, 0.12)
	t3.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	var t4: PropertyTweener = tween.tween_property(body, "position:y", base_y, 0.12)
	t4.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)


func _fold_body() -> void:
	var body: Node2D = _body()
	if body == null:
		return
	var tween: Tween = create_tween()
	var s: PropertyTweener = tween.tween_property(body, "scale", Vector2(0.2, 0.05), 1.2)
	s.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(body, "position:y", body.position.y - 40.0, 1.2)
	var f: PropertyTweener = tween.parallel().tween_property(body, "modulate:a", 0.0, 0.6)
	f.set_delay(0.8)


func _press_body() -> void:
	var body: Node2D = _body()
	if body == null:
		return
	var tween: Tween = create_tween()
	var s1: PropertyTweener = tween.tween_property(body, "scale", Vector2(1.4, 0.2), 0.25)
	s1.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(body, "scale", Vector2(0.7, 0.7), 0.2)


func _body() -> Node2D:
	var guard: Node = get_parent()
	if guard == null:
		return null
	if guard.has_method("get") and guard.get("visual") != null:
		var visual: Variant = guard.get("visual")
		if visual is Object and (visual as Object).get("rig_root") != null:
			return (visual as Object).get("rig_root") as Node2D
	return guard as Node2D


func _process(delta: float) -> void:
	_time += delta
	var effect: String = str(death.get("effect", "none"))
	_update_particles(delta)
	match effect:
		"congelado", "estatua", "apagon", "oxidacion":
			_phase = 1 if _time > _duration * 0.55 else 0
		"burbujas":
			pass
	queue_redraw()
	if _time >= maxf(_duration, 0.1) and _particles.is_empty():
		set_process(false)


func _update_particles(delta: float) -> void:
	var alive: Array[Dictionary] = []
	for p: Dictionary in _particles:
		p["life"] = float(p["life"]) - delta
		if float(p["life"]) <= 0.0:
			continue
		var vel: Vector2 = p["vel"]
		if not p.has("runner") and not p.has("ring"):
			vel.y += 260.0 * delta
		p["vel"] = vel
		p["pos"] = (p["pos"] as Vector2) + vel * delta
		alive.append(p)
	_particles = alive


func _draw() -> void:
	var effect: String = str(death.get("effect", "none"))
	if effect == "none" or effect == "":
		return
	var col: Color = Color(str(death.get("effect_color", "#ffffff")))
	match effect:
		"trozos":
			_draw_chunks(col, true)
		"cohete":
			_draw_trail(col)
		"confeti":
			_draw_chunks(col, false)
		"congelado":
			_draw_frozen(col)
		"estatua":
			_draw_statue(col)
		"muelle":
			_draw_spring(col)
		"apagon":
			_draw_apagon(col)
		"oxidacion":
			_draw_rust(col)
		"origami":
			_draw_origami(col)
		"burbujas":
			_draw_bubbles(col)
		"prensa":
			_draw_press(col)
		"dispersion":
			_draw_runners()


func _draw_chunks(base: Color, puddle: bool) -> void:
	for p: Dictionary in _particles:
		var c: Color = p["color"]
		var size: float = float(p["size"])
		var pos: Vector2 = (p["pos"] as Vector2) - Vector2(size * 0.5, size * 0.5)
		draw_rect(Rect2(pos, Vector2.ONE * size), c)
	if puddle and _time > 0.3:
		var a: float = clampf((_time - 0.3) / 0.6, 0.0, 0.7)
		var radius: float = 18.0 * clampf(_time / 0.8, 0.2, 1.0)
		draw_circle(Vector2(0.0, 2.0), radius, Color(base.r, base.g, base.b, a))


func _draw_trail(col: Color) -> void:
	for i: int in range(6):
		var t: float = _time - float(i) * 0.05
		if t < 0.0:
			continue
		var y: float = 10.0 + float(i) * 18.0
		var r: float = maxf(2.0, 8.0 - float(i))
		var tx: float = _rng.randf_range(-3.0, 3.0) * 0.1
		var alpha: float = 0.5 - float(i) * 0.07
		draw_circle(Vector2(tx, y), r, Color(col, alpha))


func _draw_frozen(col: Color) -> void:
	if _phase == 0:
		draw_rect(Rect2(-16.0, -60.0, 32.0, 60.0), Color(col, 0.25))
	else:
		for i: int in range(5):
			var x: float = -12.0 + float(i) * 6.0
			draw_line(Vector2(x, -55.0), Vector2(x + 2.0, 0.0), Color(col, 0.7), 2.0)
		if fmod(_time, 0.2) < 0.1:
			draw_rect(Rect2(-18.0, -62.0, 36.0, 64.0), Color(1, 1, 1, 0.2))


func _draw_statue(col: Color) -> void:
	var a: float = 0.4
	if _phase != 0:
		var t: float = (_time - _duration * 0.55) / maxf(_duration * 0.45, 0.01)
		a = clampf(1.0 - t, 0.0, 0.5)
	draw_rect(Rect2(-14.0, -58.0, 28.0, 58.0), Color(col, a))
	if _phase == 1:
		for i: int in range(4):
			var x: float = -10.0 + float(i) * 7.0
			draw_circle(Vector2(x, 2.0 - _time * 8.0 + float(i) * 3.0), 3.0, Color(col, a))


func _draw_spring(col: Color) -> void:
	var base_y: float = -10.0
	for i: int in range(5):
		var y: float = base_y - float(i) * 8.0
		var x: float = 8.0 if i % 2 == 0 else -8.0
		draw_line(Vector2(-x, y + 8.0), Vector2(x, y), col, 2.5)


func _draw_apagon(col: Color) -> void:
	if _phase == 0:
		var progress: float = _time / maxf(_duration * 0.55, 0.01)
		var h: float = maxf(1.0, 30.0 * (1.0 - progress))
		draw_rect(Rect2(-20.0, -30.0 - h * 0.5, 40.0, h), Color(col, 0.9))
	else:
		var r: float = 6.0 + (_time - _duration * 0.55) * 20.0
		var alpha: float = clampf(1.2 - _time, 0.0, 0.6)
		draw_circle(Vector2(0.0, -30.0), clampf(r, 0.0, 18.0), Color(col, alpha))


func _draw_rust(col: Color) -> void:
	var a: float = clampf(_time / maxf(_duration, 0.01), 0.0, 0.8)
	draw_rect(Rect2(-16.0, -58.0, 32.0, 58.0), Color(col, a * 0.5))
	if _phase == 1:
		for i: int in range(6):
			draw_circle(Vector2(-10.0 + float(i) * 4.0, -float(i * 3)), 4.0, Color(col, a))


func _draw_origami(col: Color) -> void:
	var a: float = clampf(1.0 - _time / maxf(_duration, 0.01), 0.2, 0.8)
	var w: float = 24.0 - _time * 8.0
	var ww: float = maxf(4.0, w)
	var poly: PackedVector2Array = PackedVector2Array([
		Vector2(0, -50), Vector2(ww, -30), Vector2(0, -10), Vector2(-ww, -30),
	])
	draw_colored_polygon(poly, Color(col, a))


func _draw_bubbles(col: Color) -> void:
	for p: Dictionary in _particles:
		if p.has("ring"):
			draw_arc(p["pos"], float(p["size"]), 0.0, TAU, 12, Color(col, 0.7), 2.0)
	var texts: Array[String] = ["¡ay!", "ay...", "aay"]
	var idx: int = int(_time / 0.45) % texts.size()
	var alpha: float = clampf(1.0 - _time / 1.6, 0.0, 1.0)
	var pos: Vector2 = Vector2(-14.0, -55.0 - _time * 8.0)
	var text_color: Color = Color(col, alpha)
	draw_string(
		ThemeDB.fallback_font, pos, texts[idx],
		HORIZONTAL_ALIGNMENT_LEFT, -1, 14, text_color
	)


func _draw_press(col: Color) -> void:
	draw_rect(Rect2(-22.0, -18.0, 44.0, 16.0), Color(col, 0.8))
	draw_rect(Rect2(-2.0, -18.0, 4.0, 16.0), Color(col.darkened(0.4), 0.9))


func _draw_runners() -> void:
	for p: Dictionary in _particles:
		var c: Color = p["color"]
		draw_circle(p["pos"], float(p["size"]) * 0.5, c)
		draw_circle(p["pos"] + Vector2(4.0, 2.0), float(p["size"]) * 0.3, c.darkened(0.2))


# fin del efecto

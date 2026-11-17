extends GdUnitTestSuite

## Pose del rig del protagonista (P-51). ProtagonistArt.pose_for es pura.


func _pose(state: Dictionary) -> Dictionary:
	return ProtagonistArt.pose_for(state)


func _part(pose: Dictionary, part_name: String) -> float:
	return float((pose["parts"] as Dictionary).get(part_name, 0.0))


func test_la_pose_quieta_no_toca_el_rig() -> void:
	var pose: Dictionary = _pose({})
	assert_float(pose["base_rotation"]).is_equal(0.0)
	assert_float(pose["swing_scale"]).is_equal(1.0)
	assert_int((pose["parts"] as Dictionary).size()).is_equal(0)
	assert_bool(pose["hide_fragile"]).is_false()
	assert_vector(pose["body_offset"]).is_equal(Vector2.ZERO)


func test_agacharse_abre_las_piernas_y_pega_los_brazos() -> void:
	var pose: Dictionary = _pose({"crouching": true})
	assert_float(_part(pose, "leg_left")).is_equal(ProtagonistArt.CROUCH_LEG_SPREAD)
	assert_float(_part(pose, "leg_right")).is_equal(-ProtagonistArt.CROUCH_LEG_SPREAD)
	assert_float(_part(pose, "arm_main_right")).is_equal(ProtagonistArt.CROUCH_ARM_TUCK)
	assert_float(_part(pose, "arm_main_left")).is_equal(-ProtagonistArt.CROUCH_ARM_TUCK)


func test_correr_inclina_el_cuerpo_y_acelera_el_balanceo() -> void:
	var pose: Dictionary = _pose({"running": true})
	assert_float(pose["base_rotation"]).is_equal(ProtagonistArt.RUN_LEAN)
	assert_float(pose["swing_scale"]).is_equal(ProtagonistArt.RUN_SWING_SCALE)


func test_sentarse_pliega_las_piernas_y_baja_el_cuerpo() -> void:
	var pose: Dictionary = _pose({"sitting": true})
	assert_float(_part(pose, "leg_left")).is_equal(ProtagonistArt.SIT_LEG_BEND)
	assert_float(_part(pose, "leg_right")).is_equal(-ProtagonistArt.SIT_LEG_BEND)
	assert_float((pose["body_offset"] as Vector2).y).is_equal(ProtagonistArt.SIT_DROP)


func test_cada_gesto_mueve_la_parte_que_le_toca() -> void:
	assert_float(_part(_pose({"action": "provocar"}), "arm_main_right")).is_equal(
		ProtagonistArt.TAUNT_ARM
	)
	assert_float(_part(_pose({"action": "provocar"}), "head")).is_equal(ProtagonistArt.TAUNT_HEAD)
	assert_float(_pose({"action": "provocar"})["tail_width_scale"]).is_equal(
		ProtagonistArt.TAUNT_TAIL_WIDTH
	)
	assert_float(_part(_pose({"action": "señalar"}), "arm_main_right")).is_equal(
		ProtagonistArt.POINT_ARM
	)
	assert_float(_part(_pose({"action": "recoger"}), "arm_main_right")).is_equal(
		ProtagonistArt.GATHER_ARM
	)
	assert_float(_part(_pose({"action": "rascar"}), "arm_main_right")).is_between(
		ProtagonistArt.SCRATCH_ARM - ProtagonistArt.SCRATCH_SWING,
		ProtagonistArt.SCRATCH_ARM + ProtagonistArt.SCRATCH_SWING
	)


func test_celebrar_levanta_los_cuatro_brazos_y_da_un_saltito() -> void:
	var pose: Dictionary = _pose({"action": "celebrar", "elapsed": 0.15})
	assert_float(_part(pose, "arm_main_right")).is_equal(ProtagonistArt.CELEBRATE_ARM)
	assert_float(_part(pose, "arm_extra_left")).is_equal(-ProtagonistArt.CELEBRATE_ARM)
	assert_float(pose["tail_amplitude"]).is_equal(2.0)
	assert_float((pose["body_offset"] as Vector2).y).is_less(0.0)
	var later: Dictionary = _pose({"action": "celebrar", "elapsed": 0.6})
	assert_vector(later["body_offset"]).is_equal(Vector2.ZERO)


func test_lanzar_extiende_el_brazo_y_convertir_levanta_los_dos() -> void:
	var principio: Dictionary = _pose({"action": "lanzar", "elapsed": 0.0})
	assert_float(_part(principio, "arm_main_right")).is_equal(0.0)
	var final: Dictionary = _pose({"action": "lanzar", "elapsed": ProtagonistArt.THROW_TIME})
	assert_float(_part(final, "arm_main_right")).is_equal(ProtagonistArt.THROW_ARM)
	var conversion: Dictionary = _pose({"action": "convertir"})
	assert_float(_part(conversion, "arm_main_right")).is_equal(ProtagonistArt.CAST_ARM)
	assert_float(_part(conversion, "arm_main_left")).is_equal(-ProtagonistArt.CAST_ARM)


func test_recibir_dano_y_perder_una_pieza_inclinan_el_cuerpo() -> void:
	var golpe: Dictionary = _pose({"action": "daño"})
	assert_float(golpe["base_rotation"]).is_equal(ProtagonistArt.HIT_LEAN)
	assert_float(_part(golpe, "arm_main_right")).is_equal(ProtagonistArt.HIT_ARMS)
	var perdida: Dictionary = _pose({"action": "perdida", "elapsed": 0.05})
	assert_float(absf(perdida["base_rotation"])).is_less_equal(ProtagonistArt.STAGGER_LEAN)


func test_la_muerte_va_por_sus_tres_fases() -> void:
	var encogido: Dictionary = _pose({"dead": true, "elapsed": 0.15})
	assert_float((encogido["squash"] as Vector2).x).is_greater(1.0)
	assert_float((encogido["squash"] as Vector2).y).is_less(1.0)
	assert_float(encogido["base_rotation"]).is_equal(0.0)
	var cayendo: Dictionary = _pose({"dead": true, "elapsed": 0.6})
	assert_float(cayendo["base_rotation"]).is_greater(0.0)
	assert_float(cayendo["base_rotation"]).is_less(ProtagonistArt.DEATH_FALL)
	var suelo: Dictionary = _pose({"dead": true, "elapsed": 1.4})
	assert_float(suelo["base_rotation"]).is_equal(ProtagonistArt.DEATH_FALL)
	assert_bool(suelo["hide_fragile"]).is_true()
	assert_float(suelo["piece_offset"]).is_equal(ProtagonistArt.DEATH_SPREAD)


func test_la_muerte_manda_sobre_cualquier_otro_estado() -> void:
	var pose: Dictionary = _pose({"dead": true, "elapsed": 1.0, "crouching": true, "running": true})
	assert_int((pose["parts"] as Dictionary).size()).is_equal(0)
	assert_bool(pose["hide_fragile"]).is_true()

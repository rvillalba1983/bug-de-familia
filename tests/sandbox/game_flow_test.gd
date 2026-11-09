extends GdUnitTestSuite
## Muerte, guardado, pausa antes de pelear y cambio de piezas en la partida.

const SANDBOX_PATH: String = "res://scenes/sandbox/sandbox.tscn"


func before_test() -> void:
	TestSupport.reset_session()


func after_test() -> void:
	get_tree().paused = false


func _scene() -> Sandbox:
	var runner: GdUnitSceneRunner = scene_runner(SANDBOX_PATH)
	var sandbox: Sandbox = runner.scene()
	sandbox.set_enemies_active(false)
	return sandbox


func test_guard_detection_opens_pre_fight_pause() -> void:
	var sandbox: Sandbox = _scene()
	sandbox.guard.alert_started.emit()
	assert_int(sandbox.fight.phase).is_equal(FightDirector.Phase.PRE_FIGHT)
	assert_bool(sandbox.panel.is_open).is_true()
	assert_bool(get_tree().paused).is_true()
	assert_bool(sandbox.player.body.can_swap(ModularBody.Slot.ARM_MAIN_LEFT)).is_true()
	sandbox.panel.close()
	assert_int(sandbox.fight.phase).is_equal(FightDirector.Phase.FIGHTING)
	assert_bool(get_tree().paused).is_false()
	assert_bool(sandbox.player.body.can_swap(ModularBody.Slot.ARM_MAIN_LEFT)).is_false()


func test_destroyed_piece_in_fight_pauses_and_allows_replacement() -> void:
	var sandbox: Sandbox = _scene()
	sandbox.guard.alert_started.emit()
	sandbox.panel.close()
	var body: ModularBody = sandbox.player.body
	body.add_spare(ModularBody.Slot.LEG_LEFT, BodyPiece.new(BodyPiece.Kind.LEG))
	body.damage(ModularBody.Slot.LEG_LEFT, BodyPiece.MAX_DURABILITY)
	assert_bool(sandbox.panel.is_open).is_true()
	assert_int(sandbox.panel.mode).is_equal(BodyPanel.Mode.REPLACE)
	sandbox.panel.swap_spare(ModularBody.Slot.LEG_LEFT, 0)
	assert_object(body.equipped(ModularBody.Slot.LEG_LEFT)).is_not_null()
	sandbox.panel.close()


func test_death_is_saved_and_cannot_continue() -> void:
	var sandbox: Sandbox = _scene()
	sandbox.player.body.discard_spare(ModularBody.Slot.HEAD, 0)
	sandbox.player.body.damage(ModularBody.Slot.HEAD, BodyPiece.MAX_DURABILITY)
	assert_bool(SaveSystem.read()["data"]["dead"]).is_true()
	assert_object(sandbox.overlay).is_not_null()
	assert_int(sandbox.overlay.options.size()).is_equal(1)
	get_tree().paused = false
	var second: GdUnitSceneRunner = scene_runner(SANDBOX_PATH)
	var reopened: Sandbox = second.scene()
	assert_object(reopened.overlay).is_not_null()
	assert_int(reopened.overlay.options.size()).is_equal(1)


func test_one_leg_cannot_run_and_moves_at_half_speed() -> void:
	var sandbox: Sandbox = _scene()
	var player: Player = sandbox.player
	player.body.spares(ModularBody.Slot.LEG_LEFT).clear()
	player.body.damage(ModularBody.Slot.LEG_LEFT, BodyPiece.MAX_DURABILITY)
	sandbox.panel.close()
	Input.action_press(&"run")
	var running: bool = player.is_running()
	var speed: float = player.current_speed()
	Input.action_release(&"run")
	assert_bool(running).is_false()
	assert_float(speed).is_equal(Player.WALK_SPEED * ModularBody.ONE_LEG_SPEED_FACTOR)


func test_save_restores_position_body_and_world() -> void:
	var sandbox: Sandbox = _scene()
	sandbox.player.global_position = Vector2(500.0, 900.0)
	sandbox.player.body.damage(ModularBody.Slot.LEG_LEFT, 40.0)
	(sandbox.items[Sandbox.ID_TERMINAL] as Interactable).activate()
	sandbox.autosave()
	var second: GdUnitSceneRunner = scene_runner(SANDBOX_PATH)
	var restored: Sandbox = second.scene()
	restored.set_enemies_active(false)
	assert_vector(restored.player.global_position).is_equal(Vector2(500.0, 900.0))
	var leg: BodyPiece = restored.player.body.equipped(ModularBody.Slot.LEG_LEFT)
	assert_float(leg.durability).is_equal(60.0)
	assert_bool(restored.door.is_open).is_true()


func test_corrupt_save_starts_clean_and_is_kept_aside() -> void:
	var file: FileAccess = FileAccess.open(SaveSystem.path, FileAccess.WRITE)
	file.store_string("{ esto no es json")
	file.close()
	var sandbox: Sandbox = _scene()
	assert_bool(FileAccess.file_exists(SaveSystem.path + ".danada")).is_true()
	assert_int(SaveSystem.read()["status"]).is_equal(SaveSystem.Status.OK)
	assert_bool(sandbox.player.body.is_dead).is_false()


func test_start_menu_appears_when_opening_existing_game() -> void:
	var first: Sandbox = _scene()
	first.autosave()
	Sandbox.session_started = false
	var second: GdUnitSceneRunner = scene_runner(SANDBOX_PATH)
	var reopened: Sandbox = second.scene()
	assert_object(reopened.overlay).is_not_null()
	assert_int(reopened.overlay.options.size()).is_equal(2)


func test_con_un_solo_repuesto_se_pone_sin_abrir_nada() -> void:
	var sandbox: Sandbox = _scene()
	sandbox.guard.alert_started.emit()
	sandbox.panel.close()
	var body: ModularBody = sandbox.player.body
	assert_int(body.spares(ModularBody.Slot.LEG_LEFT).size()).is_equal(1)
	body.damage(ModularBody.Slot.LEG_LEFT, BodyPiece.MAX_DURABILITY)
	assert_bool(sandbox.panel.is_open).is_false()
	assert_object(body.equipped(ModularBody.Slot.LEG_LEFT)).is_not_null()
	assert_int(body.spares(ModularBody.Slot.LEG_LEFT).size()).is_equal(0)


func test_sin_repuestos_no_se_abre_nada() -> void:
	var sandbox: Sandbox = _scene()
	sandbox.guard.alert_started.emit()
	sandbox.panel.close()
	var body: ModularBody = sandbox.player.body
	body.discard_spare(ModularBody.Slot.ARM_EXTRA_LEFT, 0) if not body.spares(ModularBody.Slot.ARM_EXTRA_LEFT).is_empty() else null
	body.damage(ModularBody.Slot.ARM_EXTRA_LEFT, BodyPiece.MAX_DURABILITY)
	assert_bool(sandbox.panel.is_open).is_false()
	assert_object(body.equipped(ModularBody.Slot.ARM_EXTRA_LEFT)).is_null()


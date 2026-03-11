extends Node3D

@onready var _camera: Camera3D = $Camera3D
@onready var _player := $Player
@onready var _npc: StaticBody3D = $NPC
@onready var _chest: StaticBody3D = $LootChest
@onready var _hud: HudController = $CanvasLayer/HUD

var _state := GameState.new()

func _ready() -> void:
	if not _validate_scene_setup():
		push_error("Scene setup is invalid. Check node names in Game.tscn.")
		return

	SettingsManager.apply_settings(SettingsManager.load_settings(), get_viewport())

	_hud.setup_callbacks(_show_tutorial_panel, _hide_tutorial_panel, _clear_dialogue)
	_hud.set_tutorial_visible(false)
	_hud.refresh(_state.locale, _state)
	_hud.set_dialogue("")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _process(_delta: float) -> void:
	_update_cursor_shape()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if _handle_hotkeys(event):
			get_viewport().set_input_as_handled()
		return

	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_player.set_move_target(_screen_to_ground(event.position))
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_handle_context_interaction(event.position)

func _validate_scene_setup() -> bool:
	return _camera != null and _player != null and _npc != null and _chest != null and _hud != null

func _handle_hotkeys(event: InputEventKey) -> bool:
	if event.keycode == KEY_L:
		_toggle_locale()
		return true
	if event.keycode == KEY_F5:
		_save_game_state()
		return true
	if event.keycode == KEY_F9:
		_load_game_state()
		return true
	if event.keycode == KEY_R:
		_reset_state()
		return true
	if event.keycode == KEY_H:
		_toggle_hud()
		return true
	if event.keycode == KEY_C:
		_clear_dialogue()
		return true
	if event.keycode == KEY_TAB:
		if _hud.is_tutorial_visible():
			_hide_tutorial_panel()
		else:
			_show_tutorial_panel()
		return true
	return false

func _screen_to_ground(screen_position: Vector2) -> Vector3:
	var from: Vector3 = _camera.project_ray_origin(screen_position)
	var ray_direction: Vector3 = _camera.project_ray_normal(screen_position)
	var hit: Variant = GameConstants.GROUND_PLANE.intersects_ray(from, ray_direction)
	if hit == null:
		return _player.global_position
	return hit as Vector3

func _handle_context_interaction(screen_position: Vector2) -> void:
	var clicked: Object = _ray_pick(screen_position)
	if clicked == _npc:
		_handle_npc_interaction()
	elif clicked == _chest:
		_try_loot_chest()

func _ray_pick(screen_position: Vector2) -> Object:
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var from: Vector3 = _camera.project_ray_origin(screen_position)
	var to: Vector3 = from + _camera.project_ray_normal(screen_position) * 400.0
	var ray_query := PhysicsRayQueryParameters3D.create(from, to)
	ray_query.collide_with_areas = false
	var result: Dictionary = space_state.intersect_ray(ray_query)
	if result.is_empty():
		return null
	return result.get("collider", null) as Object

func _update_cursor_shape() -> void:
	var mouse_pos := get_viewport().get_mouse_position()
	var hovered := _ray_pick(mouse_pos)
	if hovered == _npc or hovered == _chest:
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	else:
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _handle_npc_interaction() -> void:
	if _state.npc_hp <= 0:
		_set_dialogue(_t("npc_down"))
		return

	var distance: float = _player.global_position.distance_to(_npc.global_position)
	if distance <= GameConstants.ATTACK_RANGE:
		_apply_attack_to_npc(GameConstants.PLAYER_DAMAGE)
		return
	if distance <= GameConstants.TALK_RANGE:
		_cycle_dialogue()
	else:
		_set_dialogue(_t("too_far_talk"))

func _try_loot_chest() -> void:
	var distance: float = _player.global_position.distance_to(_chest.global_position)
	if distance > GameConstants.LOOT_RANGE:
		_set_dialogue(_t("too_far_loot"))
		return
	if _state.chest_loot.is_empty():
		_set_dialogue(_t("loot_empty"))
		return

	var item := str(_state.chest_loot.pop_front())
	_state.apply_loot(item)
	_set_dialogue(_t("loot_taken") % item)
	_refresh_hud()

func _apply_attack_to_npc(damage: int) -> void:
	_state.apply_npc_damage(damage)
	if _state.npc_hp == 0:
		_set_dialogue(_t("npc_down"))
	else:
		_set_dialogue(_t("npc_hit") % damage)
	_refresh_hud()

func _cycle_dialogue() -> void:
	var dialogue_keys: Array[String] = ["npc_talk_1", "npc_talk_2", "npc_talk_3"]
	_set_dialogue(_t(dialogue_keys[_state.dialogue_index]))
	_state.dialogue_index = (_state.dialogue_index + 1) % dialogue_keys.size()

func _toggle_locale() -> void:
	_state.locale = GameConstants.LOCALE_EN if _state.locale == GameConstants.LOCALE_HR else GameConstants.LOCALE_HR
	_set_dialogue(_t("locale_switched"))
	_refresh_hud()

func _toggle_hud() -> void:
	_hud.visible = not _hud.visible
	if _hud.visible:
		_set_dialogue(_t("hud_shown"))
	else:
		print(_t("hud_hidden"))

func _show_tutorial_panel() -> void:
	_hud.set_tutorial_visible(true)
	_state.tutorial_visible = true
	_set_dialogue(_t("tutorial_shown"))

func _hide_tutorial_panel() -> void:
	_hud.set_tutorial_visible(false)
	_state.tutorial_visible = false
	_set_dialogue(_t("tutorial_hidden"))

func _clear_dialogue() -> void:
	_set_dialogue(_t("dialogue_cleared"))

func _set_dialogue(message: String) -> void:
	_hud.set_dialogue(message)

func _refresh_hud() -> void:
	_hud.refresh(_state.locale, _state)

func _save_game_state() -> void:
	var result: Dictionary = SaveManager.save_state(_state.to_dict(_player.global_position))
	if bool(result.get("ok", false)):
		_set_dialogue(_t("save_ok"))
	else:
		_set_dialogue(_t("save_error") % str(result.get("error", "unknown")))

func _load_game_state() -> void:
	var result: Dictionary = SaveManager.load_state()
	if not bool(result.get("ok", false)):
		var err: String = str(result.get("error", "unknown"))
		if err == "missing":
			_set_dialogue(_t("load_missing"))
		else:
			_set_dialogue(_t("load_error") % err)
		return

	var player_pos: Vector3 = _state.load_from_dict(result.get("payload", {}) as Dictionary)
	_player.global_position = player_pos
	_hud.set_tutorial_visible(_state.tutorial_visible)
	_refresh_hud()
	_set_dialogue(_t("load_ok"))

func _reset_state() -> void:
	_state.reset()
	_player.global_position = Vector3(0.0, 0.9, 0.0)
	_hud.set_tutorial_visible(false)
	_refresh_hud()
	_set_dialogue(_t("reset_ok"))

func _t(key: String) -> String:
	return Translator.t(_state.locale, key, GameConstants.LOCALE_HR, GameConstants.TEXT)

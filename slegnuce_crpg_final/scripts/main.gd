extends Node3D

const MENU_SCENE := "res://scenes/MainMenu.tscn"
const GAME_SCENE := "res://scenes/Game.tscn"

@onready var _camera: Camera3D = $Camera3D
@onready var _light: DirectionalLight3D = $DirectionalLight3D
@onready var _player: CharacterBody3D = $Player
@onready var _npc_guard: StaticBody3D = $NPC
@onready var _npc_journalist: StaticBody3D = $JournalistNPC
@onready var _chest: StaticBody3D = $LootChest
@onready var _evidence_spot: StaticBody3D = $EvidenceSpot
@onready var _town_hall_door: StaticBody3D = $TownHallDoor
@onready var _hud: HudController = $CanvasLayer/HUD

@onready var _choice_panel: PanelContainer = $CanvasLayer/ChoicePanel
@onready var _choice_title: Label = $CanvasLayer/ChoicePanel/ChoiceVBox/ChoiceTitle
@onready var _choice_a: Button = $CanvasLayer/ChoicePanel/ChoiceVBox/ChoiceA
@onready var _choice_b: Button = $CanvasLayer/ChoicePanel/ChoiceVBox/ChoiceB
@onready var _choice_c: Button = $CanvasLayer/ChoicePanel/ChoiceVBox/ChoiceC

var _state := GameState.new()
var _active_choice_id: String = ""
var _choices_locked: bool = false
var _council_trust: int = 0
var _citizen_trust: int = 0
var _evidence_found: int = 0
var _day_phase: float = 0.0

func _ready() -> void:
	if not _validate_scene_setup():
		push_error("Scene setup is invalid. Check node names in Game.tscn.")
		return

	_apply_runtime_settings()
	_hud.setup_callbacks(_on_show_tutorial, _on_hide_tutorial, _on_clear_dialogue)
	_bind_choice_buttons()
	_reset_gameplay_state()
	_hud.set_tutorial_visible(_state.tutorial_visible)
	_refresh_ui()
	_set_dialogue(_t("intro_arrival"))

func _process(delta: float) -> void:
	_day_phase += delta * 0.05
	var tilt := lerpf(-0.48, -0.2, (sin(_day_phase) + 1.0) * 0.5)
	_light.rotation.x = tilt

func _unhandled_input(event: InputEvent) -> void:
	if _choice_panel.visible:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		_handle_hotkeys(event)
		return

	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_player.set_move_target(_screen_to_ground(event.position))
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_handle_context_interaction(event.position)

func _validate_scene_setup() -> bool:
	return _camera != null and _player != null and _npc_guard != null and _npc_journalist != null and _hud != null

func _apply_runtime_settings() -> void:
	var settings := SettingsManager.load_settings()
	SettingsManager.apply_settings(settings, get_viewport())
	_camera.fov = clampf(float(settings.get("camera_fov", 70.0)), 55.0, 95.0)
	_state.locale = str(settings.get("language", GameConstants.LOCALE_HR))

func _handle_hotkeys(event: InputEventKey) -> void:
	if event.keycode == KEY_L:
		_toggle_locale()
	elif event.keycode == KEY_F5:
		_save_game_state()
	elif event.keycode == KEY_F9:
		_load_game_state()
	elif event.keycode == KEY_R:
		get_tree().change_scene_to_file(GAME_SCENE)
	elif event.keycode == KEY_TAB:
		_state.tutorial_visible = not _hud.is_tutorial_visible()
		_hud.set_tutorial_visible(_state.tutorial_visible)
		_set_dialogue(_t("tutorial_shown") if _state.tutorial_visible else _t("tutorial_hidden"))
	elif event.keycode == KEY_H:
		_hud.visible = not _hud.visible
		if _hud.visible:
			_set_dialogue(_t("hud_shown"))
	elif event.keycode == KEY_C:
		_on_clear_dialogue()
	elif event.keycode == KEY_ESCAPE:
		get_tree().change_scene_to_file(MENU_SCENE)

func _screen_to_ground(screen_position: Vector2) -> Vector3:
	var from := _camera.project_ray_origin(screen_position)
	var ray_direction := _camera.project_ray_normal(screen_position)
	var hit: Variant = GameConstants.GROUND_PLANE.intersects_ray(from, ray_direction)
	if hit == null:
		return _player.global_position
	return hit as Vector3

func _handle_context_interaction(screen_position: Vector2) -> void:
	var clicked := _ray_pick(screen_position)
	if clicked == _npc_guard:
		_handle_guard_interaction()
	elif clicked == _npc_journalist:
		_handle_journalist_interaction()
	elif clicked == _chest:
		_try_loot_chest()
	elif clicked == _evidence_spot:
		_collect_evidence()
	elif clicked == _town_hall_door:
		_try_story_resolution()

func _ray_pick(screen_position: Vector2) -> Object:
	var space_state := get_world_3d().direct_space_state
	var from := _camera.project_ray_origin(screen_position)
	var to := from + _camera.project_ray_normal(screen_position) * 220.0
	var ray_query := PhysicsRayQueryParameters3D.create(from, to)
	ray_query.collide_with_areas = false
	var result := space_state.intersect_ray(ray_query)
	if result.is_empty():
		return null
	return result.get("collider", null) as Object

func _handle_guard_interaction() -> void:
	var distance := _player.global_position.distance_to(_npc_guard.global_position)
	if distance > GameConstants.TALK_RANGE:
		_set_dialogue(_t("too_far_talk"))
		return

	if _state.npc_hp <= 0:
		_set_dialogue(_t("npc_down"))
		return

	if _state.inventory.has("Iron Sword") and distance <= GameConstants.ATTACK_RANGE:
		_state.apply_npc_damage(GameConstants.PLAYER_DAMAGE)
		_set_dialogue(_t("npc_hit") % GameConstants.PLAYER_DAMAGE)
		if _state.npc_hp == 0:
			_citizen_trust += 1
			_set_dialogue(_t("guard_defeated_branch"))
	else:
		var dialogue_keys: Array[String] = ["npc_talk_1", "npc_talk_2", "npc_talk_3"]
		var key := dialogue_keys[_state.dialogue_index % dialogue_keys.size()]
		_set_dialogue(_t(key))
		_state.dialogue_index += 1

	_refresh_ui()

func _handle_journalist_interaction() -> void:
	var distance := _player.global_position.distance_to(_npc_journalist.global_position)
	if distance > GameConstants.TALK_RANGE:
		_set_dialogue(_t("too_far_talk"))
		return

	if _choices_locked:
		_set_dialogue(_t("journalist_done"))
		return

	if _evidence_found <= 0:
		_set_dialogue(_t("journalist_needs_proof"))
		return

	_open_choice(
		"journalist_pitch",
		_t("choice_support_council"),
		_t("choice_support_citizens"),
		_t("choice_stall")
	)

func _try_loot_chest() -> void:
	var distance := _player.global_position.distance_to(_chest.global_position)
	if distance > GameConstants.LOOT_RANGE:
		_set_dialogue(_t("too_far_loot"))
		return

	if _state.chest_loot.is_empty():
		_set_dialogue(_t("loot_empty"))
		return

	var item := str(_state.chest_loot.pop_front())
	_state.apply_loot(item)
	_set_dialogue(_t("loot_taken") % item)
	_refresh_ui()

func _collect_evidence() -> void:
	var distance := _player.global_position.distance_to(_evidence_spot.global_position)
	if distance > GameConstants.LOOT_RANGE:
		_set_dialogue(_t("too_far_loot"))
		return

	if _state.inventory.has("Water Sample"):
		_set_dialogue(_t("evidence_already"))
		return

	_evidence_found += 1
	_state.apply_loot("Water Sample")
	_set_dialogue(_t("evidence_found"))
	_refresh_ui()

func _try_story_resolution() -> void:
	var distance := _player.global_position.distance_to(_town_hall_door.global_position)
	if distance > GameConstants.TALK_RANGE:
		_set_dialogue(_t("too_far_talk"))
		return

	if _active_choice_id != "journalist_pitch":
		_set_dialogue(_t("ending_locked"))
		return

	if _council_trust > _citizen_trust:
		_state.quest_stage = GameConstants.QUEST_COMPLETE
		_set_dialogue(_t("ending_council"))
	elif _citizen_trust > _council_trust:
		_state.quest_stage = GameConstants.QUEST_COMPLETE
		_set_dialogue(_t("ending_citizens"))
	else:
		_set_dialogue(_t("ending_ambiguous"))

	_choices_locked = true
	_refresh_ui()

func _open_choice(choice_id: String, option_a: String, option_b: String, option_c: String) -> void:
	_active_choice_id = choice_id
	_choice_title.text = _t(choice_id)
	_choice_a.text = option_a
	_choice_b.text = option_b
	_choice_c.text = option_c
	_choice_panel.visible = true

func _bind_choice_buttons() -> void:
	_choice_a.pressed.connect(func(): _resolve_choice(0))
	_choice_b.pressed.connect(func(): _resolve_choice(1))
	_choice_c.pressed.connect(func(): _resolve_choice(2))

func _resolve_choice(index: int) -> void:
	if _active_choice_id != "journalist_pitch":
		_choice_panel.visible = false
		return

	if index == 0:
		_council_trust += 2
		_set_dialogue(_t("branch_council"))
	elif index == 1:
		_citizen_trust += 2
		_set_dialogue(_t("branch_citizens"))
	else:
		_council_trust += 1
		_citizen_trust += 1
		_set_dialogue(_t("branch_stall"))

	_choice_panel.visible = false
	_refresh_ui()

func _on_show_tutorial() -> void:
	_state.tutorial_visible = true
	_hud.set_tutorial_visible(true)
	_set_dialogue(_t("tutorial_shown"))

func _on_hide_tutorial() -> void:
	_state.tutorial_visible = false
	_hud.set_tutorial_visible(false)
	_set_dialogue(_t("tutorial_hidden"))

func _on_clear_dialogue() -> void:
	_set_dialogue(_t("dialogue_cleared"))

func _toggle_locale() -> void:
	_state.locale = GameConstants.LOCALE_EN if _state.locale == GameConstants.LOCALE_HR else GameConstants.LOCALE_HR
	_set_dialogue(_t("locale_switched"))
	_refresh_ui()

func _refresh_ui() -> void:
	_hud.refresh(_state.locale, _state)

func _set_dialogue(message: String) -> void:
	_hud.set_dialogue(message)

func _save_game_state() -> void:
	var state := _state.to_dict(_player.global_position)
	state["council_trust"] = _council_trust
	state["citizen_trust"] = _citizen_trust
	state["evidence_found"] = _evidence_found
	state["active_choice_id"] = _active_choice_id
	state["choices_locked"] = _choices_locked

	var result := SaveManager.save_state(state)
	if bool(result.get("ok", false)):
		_set_dialogue(_t("save_ok"))
	else:
		_set_dialogue(_t("save_error") % str(result.get("error", "unknown")))

func _load_game_state() -> void:
	var result := SaveManager.load_state()
	if not bool(result.get("ok", false)):
		var err := str(result.get("error", "unknown"))
		_set_dialogue(_t("load_missing") if err == "missing" else _t("load_error") % err)
		return

	var payload: Dictionary = result.get("payload", {})
	_player.global_position = _state.load_from_dict(payload)
	_council_trust = int(payload.get("council_trust", 0))
	_citizen_trust = int(payload.get("citizen_trust", 0))
	_evidence_found = int(payload.get("evidence_found", 0))
	_active_choice_id = str(payload.get("active_choice_id", ""))
	_choices_locked = bool(payload.get("choices_locked", false))
	_choice_panel.visible = false
	_refresh_ui()
	_set_dialogue(_t("load_ok"))

func _reset_gameplay_state() -> void:
	_state.reset()
	_state.tutorial_visible = true
	_active_choice_id = ""
	_choices_locked = false
	_council_trust = 0
	_citizen_trust = 0
	_evidence_found = 0
	_player.global_position = Vector3(0.0, 0.9, 0.0)
	_choice_panel.visible = false

func _t(key: String) -> String:
	return Translator.t(_state.locale, key, GameConstants.LOCALE_HR, GameConstants.TEXT)

extends Node3D

const GROUND_PLANE := Plane(Vector3.UP, 0.0)
const ATTACK_RANGE: float = 2.2
const TALK_RANGE: float = 2.8
const LOOT_RANGE: float = 2.0
const PLAYER_DAMAGE: int = 20
const NPC_MAX_HP: int = 100
const PLAYER_MAX_HP: int = 100

const LOCALE_HR := "hr"
const LOCALE_EN := "en"

const TEXT := {
	"hr": {
		"controls": "LMB Kretanje | RMB NPC Razgovor/Napad | RMB Chest Loot | L Jezik | F5 Save | F9 Load | R Reset",
		"hud_player": "Player HP: %d/%d",
		"hud_npc": "NPC HP: %d/%d",
		"hud_inventory": "Inventory: %s",
		"hud_inventory_empty": "Inventory: (prazan)",
		"hud_quest_active": "Quest: Opljačkaj škrinju i porazi NPC-a",
		"hud_quest_done": "Quest: Vertical Slice dovršen",
		"too_far_talk": "Priđi NPC-u da razgovaraš.",
		"too_far_loot": "Priđi škrinji da pokupiš predmet.",
		"npc_down": "NPC je poražen.",
		"npc_hit": "Napad! NPC prima %d štete.",
		"npc_talk_1": "Dobar dan, putniče.",
		"npc_talk_2": "Lika te zove na novu avanturu.",
		"npc_talk_3": "Ubaci modele i postajemo pravi CRPG.",
		"loot_taken": "Pokupio si: %s",
		"loot_empty": "Škrinja je prazna.",
		"save_ok": "Spremljeno: user://savegame.dat",
		"load_ok": "Učitano: user://savegame.dat",
		"load_missing": "Save još ne postoji.",
		"load_error": "Greška pri učitavanju: %s",
		"save_error": "Greška pri spremanju: %s",
		"reset_ok": "Stanje vraćeno na početak.",
		"locale_switched": "Jezik prebačen: HR"
	},
	"en": {
		"controls": "LMB Move | RMB NPC Talk/Attack | RMB Chest Loot | L Language | F5 Save | F9 Load | R Reset",
		"hud_player": "Player HP: %d/%d",
		"hud_npc": "NPC HP: %d/%d",
		"hud_inventory": "Inventory: %s",
		"hud_inventory_empty": "Inventory: (empty)",
		"hud_quest_active": "Quest: Loot chest and defeat NPC",
		"hud_quest_done": "Quest: Vertical Slice complete",
		"too_far_talk": "Move closer to talk to the NPC.",
		"too_far_loot": "Move closer to loot the chest.",
		"npc_down": "NPC is defeated.",
		"npc_hit": "Hit! NPC takes %d damage.",
		"npc_talk_1": "Good day, traveler.",
		"npc_talk_2": "Lika is calling you to a new adventure.",
		"npc_talk_3": "Import your models and this becomes a real CRPG.",
		"loot_taken": "You picked up: %s",
		"loot_empty": "The chest is empty.",
		"save_ok": "Saved: user://savegame.dat",
		"load_ok": "Loaded: user://savegame.dat",
		"load_missing": "No save file exists yet.",
		"load_error": "Load failed: %s",
		"save_error": "Save failed: %s",
		"reset_ok": "State reset to defaults.",
		"locale_switched": "Language switched: EN"
	}
}

@onready var _camera: Camera3D = $Camera3D
@onready var _player := $Player
@onready var _npc: StaticBody3D = $NPC
@onready var _chest: StaticBody3D = $LootChest

@onready var _dialogue_label: Label = $CanvasLayer/HUD/VBoxContainer/Dialogue
@onready var _controls_label: Label = $CanvasLayer/HUD/VBoxContainer/Instructions
@onready var _player_hp_label: Label = $CanvasLayer/HUD/VBoxContainer/PlayerHP
@onready var _npc_hp_label: Label = $CanvasLayer/HUD/VBoxContainer/NpcHP
@onready var _inventory_label: Label = $CanvasLayer/HUD/VBoxContainer/Inventory
@onready var _quest_label: Label = $CanvasLayer/HUD/VBoxContainer/Quest

var _locale: String = LOCALE_HR
var _dialogue_index: int = 0
var _player_hp: int = PLAYER_MAX_HP
var _npc_hp: int = NPC_MAX_HP
var _inventory: Array[String] = []
var _chest_loot: Array[String] = ["Iron Sword", "Health Potion"]

func _ready() -> void:
	if not _validate_scene_setup():
		push_error("Scene setup is invalid. Check node names in Main.tscn.")
		return
	_refresh_hud()
	_set_dialogue("")
	print("slegnuce_crpg_final vertical slice ready")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		_handle_hotkeys(event)
		return

	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_player.set_move_target(_screen_to_ground(event.position))
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_handle_context_interaction(event.position)

func _validate_scene_setup() -> bool:
	return _camera != null and _player != null and _npc != null and _chest != null and _dialogue_label != null

func _handle_hotkeys(event: InputEventKey) -> void:
	if event.keycode == KEY_L:
		_toggle_locale()
	elif event.keycode == KEY_F5:
		_save_game_state()
	elif event.keycode == KEY_F9:
		_load_game_state()
	elif event.keycode == KEY_R:
		_reset_state()

func _screen_to_ground(screen_position: Vector2) -> Vector3:
	var from: Vector3 = _camera.project_ray_origin(screen_position)
	var ray_direction: Vector3 = _camera.project_ray_normal(screen_position)
	var hit: Variant = GROUND_PLANE.intersects_ray(from, ray_direction)
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
	var to: Vector3 = from + _camera.project_ray_normal(screen_position) * 200.0
	var ray_query := PhysicsRayQueryParameters3D.create(from, to)
	ray_query.collide_with_areas = false
	var result: Dictionary = space_state.intersect_ray(ray_query)
	if result.is_empty():
		return null
	return result.get("collider", null) as Object

func _handle_npc_interaction() -> void:
	if _npc_hp <= 0:
		_set_dialogue(_t("npc_down"))
		return

	var distance: float = _player.global_position.distance_to(_npc.global_position)
	if distance <= ATTACK_RANGE:
		_apply_attack_to_npc(PLAYER_DAMAGE)
		return

	if distance <= TALK_RANGE:
		_cycle_dialogue()
	else:
		_set_dialogue(_t("too_far_talk"))

func _try_loot_chest() -> void:
	var distance: float = _player.global_position.distance_to(_chest.global_position)
	if distance > LOOT_RANGE:
		_set_dialogue(_t("too_far_loot"))
		return

	if _chest_loot.is_empty():
		_set_dialogue(_t("loot_empty"))
		return

	var item := str(_chest_loot.pop_front())
	_inventory.append(item)
	_set_dialogue(_t("loot_taken") % item)
	_refresh_hud()

func _apply_attack_to_npc(damage: int) -> void:
	_npc_hp = maxi(_npc_hp - damage, 0)
	if _npc_hp == 0:
		_set_dialogue(_t("npc_down"))
	else:
		_set_dialogue(_t("npc_hit") % damage)
	_refresh_hud()

func _cycle_dialogue() -> void:
	var dialogue_keys: Array[String] = ["npc_talk_1", "npc_talk_2", "npc_talk_3"]
	_set_dialogue(_t(dialogue_keys[_dialogue_index]))
	_dialogue_index = (_dialogue_index + 1) % dialogue_keys.size()

func _toggle_locale() -> void:
	_locale = LOCALE_EN if _locale == LOCALE_HR else LOCALE_HR
	_set_dialogue(_t("locale_switched"))
	_refresh_hud()

func _refresh_hud() -> void:
	_controls_label.text = _t("controls")
	_player_hp_label.text = _t("hud_player") % [_player_hp, PLAYER_MAX_HP]
	_npc_hp_label.text = _t("hud_npc") % [_npc_hp, NPC_MAX_HP]

	if _inventory.is_empty():
		_inventory_label.text = _t("hud_inventory_empty")
	else:
		_inventory_label.text = _t("hud_inventory") % ", ".join(_inventory)

	if _npc_hp <= 0 and _inventory.has("Iron Sword"):
		_quest_label.text = _t("hud_quest_done")
	else:
		_quest_label.text = _t("hud_quest_active")

func _set_dialogue(message: String) -> void:
	_dialogue_label.text = message

func _save_game_state() -> void:
	var state := {
		"locale": _locale,
		"player_hp": _player_hp,
		"npc_hp": _npc_hp,
		"inventory": _inventory,
		"chest_loot": _chest_loot,
		"dialogue_index": _dialogue_index,
		"player_pos": _player.global_position
	}

	var result: Dictionary = SaveManager.save_state(state)
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

	var state: Dictionary = result.get("payload", {}) as Dictionary
	_locale = str(state.get("locale", LOCALE_HR))
	_player_hp = int(state.get("player_hp", PLAYER_MAX_HP))
	_npc_hp = int(state.get("npc_hp", NPC_MAX_HP))
	_dialogue_index = int(state.get("dialogue_index", 0))
	_player.global_position = state.get("player_pos", Vector3.ZERO)

	_inventory.clear()
	for item in state.get("inventory", []):
		_inventory.append(str(item))

	_chest_loot.clear()
	for item in state.get("chest_loot", []):
		_chest_loot.append(str(item))

	_refresh_hud()
	_set_dialogue(_t("load_ok"))

func _reset_state() -> void:
	_locale = LOCALE_HR
	_dialogue_index = 0
	_player_hp = PLAYER_MAX_HP
	_npc_hp = NPC_MAX_HP
	_inventory.clear()
	_chest_loot = ["Iron Sword", "Health Potion"]
	_player.global_position = Vector3.ZERO
	_refresh_hud()
	_set_dialogue(_t("reset_ok"))

func _t(key: String) -> String:
	var bundle: Dictionary = TEXT.get(_locale, TEXT[LOCALE_HR])
	return str(bundle.get(key, key))

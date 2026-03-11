extends RefCounted
class_name GameState

var locale: String = GameConstants.LOCALE_HR
var dialogue_index: int = 0
var player_hp: int = GameConstants.PLAYER_MAX_HP
var npc_hp: int = GameConstants.NPC_MAX_HP
var inventory: Array[String] = []
var chest_loot: Array[String] = ["Iron Sword", "Health Potion"]
var quest_stage: int = GameConstants.QUEST_ARRIVAL
var tutorial_visible: bool = false

func apply_loot(item: String) -> void:
	inventory.append(item)
	if quest_stage == GameConstants.QUEST_ARRIVAL:
		quest_stage = GameConstants.QUEST_FOUND_LOOT

func apply_npc_damage(damage: int) -> void:
	npc_hp = maxi(npc_hp - damage, 0)
	if npc_hp == 0:
		if quest_stage >= GameConstants.QUEST_FOUND_LOOT:
			quest_stage = GameConstants.QUEST_COMPLETE
		else:
			quest_stage = GameConstants.QUEST_DEFEATED_NPC

func story_key() -> String:
	if quest_stage == GameConstants.QUEST_COMPLETE:
		return "story_done"
	if quest_stage == GameConstants.QUEST_FOUND_LOOT:
		return "story_loot"
	if quest_stage == GameConstants.QUEST_DEFEATED_NPC:
		return "story_fight"
	return "story_arrival"

func quest_key() -> String:
	if quest_stage == GameConstants.QUEST_COMPLETE:
		return "hud_quest_done"
	return "hud_quest_active"

func to_dict(player_position: Vector3) -> Dictionary:
	return {
		"locale": locale,
		"player_hp": player_hp,
		"npc_hp": npc_hp,
		"inventory": inventory,
		"chest_loot": chest_loot,
		"dialogue_index": dialogue_index,
		"quest_stage": quest_stage,
		"player_pos": player_position,
		"tutorial_visible": tutorial_visible
	}

func load_from_dict(state: Dictionary) -> Vector3:
	locale = str(state.get("locale", GameConstants.LOCALE_HR))
	player_hp = int(state.get("player_hp", GameConstants.PLAYER_MAX_HP))
	npc_hp = int(state.get("npc_hp", GameConstants.NPC_MAX_HP))
	dialogue_index = int(state.get("dialogue_index", 0))
	quest_stage = clampi(int(state.get("quest_stage", GameConstants.QUEST_ARRIVAL)), GameConstants.QUEST_ARRIVAL, GameConstants.QUEST_COMPLETE)
	tutorial_visible = bool(state.get("tutorial_visible", false))

	inventory.clear()
	for item in state.get("inventory", []):
		inventory.append(str(item))

	chest_loot.clear()
	for item in state.get("chest_loot", []):
		chest_loot.append(str(item))

	return state.get("player_pos", Vector3(0.0, 0.9, 0.0))

func reset() -> void:
	locale = GameConstants.LOCALE_HR
	dialogue_index = 0
	player_hp = GameConstants.PLAYER_MAX_HP
	npc_hp = GameConstants.NPC_MAX_HP
	quest_stage = GameConstants.QUEST_ARRIVAL
	tutorial_visible = false
	inventory.clear()
	chest_loot = ["Iron Sword", "Health Potion"]

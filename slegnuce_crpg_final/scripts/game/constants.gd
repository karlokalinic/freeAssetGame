extends RefCounted
class_name GameConstants

const GROUND_PLANE := Plane(Vector3.UP, 0.0)
const ATTACK_RANGE: float = 2.2
const TALK_RANGE: float = 2.8
const LOOT_RANGE: float = 2.0
const PLAYER_DAMAGE: int = 20
const NPC_MAX_HP: int = 100
const PLAYER_MAX_HP: int = 100

const LOCALE_HR := "hr"
const LOCALE_EN := "en"

const QUEST_ARRIVAL := 0
const QUEST_FOUND_LOOT := 1
const QUEST_DEFEATED_NPC := 2
const QUEST_COMPLETE := 3

const TEXT := {
	"hr": {
		"mini_hint": "TAB: Prikaži tutorial / HUD",
		"controls": "LMB Kretanje | RMB Interakcija | L Jezik | H HUD | TAB Tutorial | C Očisti | F5/F9 Save/Load | R Reset",
		"hud_player": "Igrač HP: %d/%d",
		"hud_npc": "NPC HP: %d/%d",
		"hud_inventory": "Inventar: %s",
		"hud_inventory_empty": "Inventar: (prazan)",
		"hud_quest_active": "Zadatak: Opljačkaj škrinju i porazi NPC-a",
		"hud_quest_done": "Zadatak: Vertical Slice dovršen",
		"story_arrival": "Priča: Dolazak u snježno selo.",
		"story_loot": "Priča: Našao si opremu i pripremio se za sukob.",
		"story_fight": "Priča: Pobijedio si čuvara i otvorio put dalje.",
		"story_done": "Priča: Demo vertikalnog slicea je kompletiran.",
		"too_far_talk": "Priđi NPC-u da razgovaraš.",
		"too_far_loot": "Priđi škrinji da pokupiš predmet.",
		"npc_down": "NPC je poražen.",
		"npc_hit": "Napad! NPC prima %d štete.",
		"npc_talk_1": "Dobar dan, putniče.",
		"npc_talk_2": "Lika te zove na novu avanturu.",
		"npc_talk_3": "Spreman sam testirati tvoju snagu.",
		"loot_taken": "Pokupio si: %s",
		"loot_empty": "Škrinja je prazna.",
		"save_ok": "Spremljeno: user://savegame.dat",
		"load_ok": "Učitano: user://savegame.dat",
		"load_missing": "Save još ne postoji.",
		"load_error": "Greška pri učitavanju: %s",
		"save_error": "Greška pri spremanju: %s",
		"reset_ok": "Stanje vraćeno na početak.",
		"hud_hidden": "HUD sakriven.",
		"hud_shown": "HUD prikazan.",
		"dialogue_cleared": "Poruka očišćena.",
		"locale_switched": "Jezik prebačen: HR",
		"tutorial_hidden": "Tutorial skriven. TAB ili Show Tutorial za povratak.",
		"tutorial_shown": "Tutorial prikazan.",
		"hud_day": "Dan %d / Slot %d",
		"hud_resonance": "Glasovi: %s",
		"hud_notebook": "Bilježnica: %s",
		"hud_evidence": "Dokazi: %s",
		"dialogue_mode_on": "Dijalog mode: odaberi 1/2/3.",
		"dialogue_mode_off": "Dijalog mode ugašen.",
		"hud_abilities": "Sposobnosti: %s",
		"ability_unlocked": "Otključano: %s",
		"ability_needed": "Trebaš sposobnost: %s",
		"special_action_done": "Posebna radnja izvedena: %s"
	},
	"en": {
		"mini_hint": "TAB: Show tutorial / HUD",
		"controls": "LMB Move | RMB Interact | L Language | H HUD | TAB Tutorial | C Clear | F5/F9 Save/Load | R Reset",
		"hud_player": "Player HP: %d/%d",
		"hud_npc": "NPC HP: %d/%d",
		"hud_inventory": "Inventory: %s",
		"hud_inventory_empty": "Inventory: (empty)",
		"hud_quest_active": "Quest: Loot chest and defeat NPC",
		"hud_quest_done": "Quest: Vertical Slice complete",
		"story_arrival": "Story: Arrival in the snowy village.",
		"story_loot": "Story: You found gear and prepared for conflict.",
		"story_fight": "Story: You defeated the guard and opened the path.",
		"story_done": "Story: Vertical slice demo complete.",
		"too_far_talk": "Move closer to talk to the NPC.",
		"too_far_loot": "Move closer to loot the chest.",
		"npc_down": "NPC is defeated.",
		"npc_hit": "Hit! NPC takes %d damage.",
		"npc_talk_1": "Good day, traveler.",
		"npc_talk_2": "Lika is calling you to a new adventure.",
		"npc_talk_3": "I am ready to test your strength.",
		"loot_taken": "You picked up: %s",
		"loot_empty": "The chest is empty.",
		"save_ok": "Saved: user://savegame.dat",
		"load_ok": "Loaded: user://savegame.dat",
		"load_missing": "No save file exists yet.",
		"load_error": "Load failed: %s",
		"save_error": "Save failed: %s",
		"reset_ok": "State reset to defaults.",
		"hud_hidden": "HUD hidden.",
		"hud_shown": "HUD shown.",
		"dialogue_cleared": "Message cleared.",
		"locale_switched": "Language switched: EN",
		"tutorial_hidden": "Tutorial hidden. Use TAB or Show Tutorial.",
		"tutorial_shown": "Tutorial shown.",
		"hud_day": "Day %d / Slot %d",
		"hud_resonance": "Voices: %s",
		"hud_notebook": "Notebook: %s",
		"hud_evidence": "Evidence: %s",
		"dialogue_mode_on": "Dialogue mode: pick 1/2/3.",
		"dialogue_mode_off": "Dialogue mode closed.",
		"hud_abilities": "Abilities: %s",
		"ability_unlocked": "Unlocked: %s",
		"ability_needed": "Ability required: %s",
		"special_action_done": "Special action performed: %s"
	}
}

extends Node
class_name SceneHub

const SCENE_MAIN_MENU: String = "res://scenes/MainMenu.tscn"
const SCENE_MAIN: String = "res://scenes/Main.tscn"
const SCENE_GAME: String = "res://scenes/Game.tscn"
const SCENE_GAME_ARCHIVE: String = "res://scenes/Game_Archive.tscn"
const SCENE_GAME_CLINIC: String = "res://scenes/Game_Clinic.tscn"
const SCENE_GAME_INDUSTRIAL: String = "res://scenes/Game_Industrial.tscn"
const SCENE_GAME_PRUDINA_CENTER: String = "res://scenes/Game_PrudinaCenter.tscn"
const SCENE_GAME_RIVERBANK: String = "res://scenes/Game_Riverbank.tscn"

const STORY_ROUTE: Array[String] = [
	SCENE_GAME,
	SCENE_GAME_PRUDINA_CENTER,
	SCENE_GAME_RIVERBANK,
	SCENE_GAME_CLINIC,
	SCENE_GAME_INDUSTRIAL,
	SCENE_GAME_ARCHIVE
]

static func all_scene_paths() -> Array[String]:
	return STORY_ROUTE.duplicate()

static func scene_exists(path: String) -> bool:
	return ResourceLoader.exists(path)

static func safe_change_scene(tree: SceneTree, path: String) -> bool:
	if tree == null:
		push_warning("SceneHub.safe_change_scene called with null SceneTree.")
		return false
	if not scene_exists(path):
		push_warning("SceneHub could not find scene at path: %s" % path)
		return false
	var error_code: int = tree.change_scene_to_file(path)
	return error_code == OK

static func next_story_scene(current_path: String) -> String:
	var index: int = STORY_ROUTE.find(current_path)
	if index == -1:
		return STORY_ROUTE[0]
	var next_index: int = mini(index + 1, STORY_ROUTE.size() - 1)
	return STORY_ROUTE[next_index]

static func previous_story_scene(current_path: String) -> String:
	var index: int = STORY_ROUTE.find(current_path)
	if index <= 0:
		return STORY_ROUTE[0]
	return STORY_ROUTE[index - 1]

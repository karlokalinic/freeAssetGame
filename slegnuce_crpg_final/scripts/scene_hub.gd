extends Control

const MAIN_MENU := "res://scenes/MainMenu.tscn"
const SCENES := {
	"PrudinaCenter": "res://scenes/Game_PrudinaCenter.tscn",
	"Clinic": "res://scenes/Game_Clinic.tscn",
	"Archive": "res://scenes/Game_Archive.tscn",
	"Riverbank": "res://scenes/Game_Riverbank.tscn",
	"Industrial": "res://scenes/Game_Industrial.tscn"
}

@onready var _status: Label = $MarginContainer/VBox/Status

func _ready() -> void:
	$MarginContainer/VBox/PrudinaCenter.pressed.connect(func(): _open_scene("PrudinaCenter"))
	$MarginContainer/VBox/Clinic.pressed.connect(func(): _open_scene("Clinic"))
	$MarginContainer/VBox/Archive.pressed.connect(func(): _open_scene("Archive"))
	$MarginContainer/VBox/Riverbank.pressed.connect(func(): _open_scene("Riverbank"))
	$MarginContainer/VBox/Industrial.pressed.connect(func(): _open_scene("Industrial"))
	$MarginContainer/VBox/Back.pressed.connect(func(): get_tree().change_scene_to_file(MAIN_MENU))

func _open_scene(key: String) -> void:
	var target := SCENES.get(key, "")
	if target.is_empty():
		_status.text = "Scene not found: %s" % key
		return
	get_tree().change_scene_to_file(target)

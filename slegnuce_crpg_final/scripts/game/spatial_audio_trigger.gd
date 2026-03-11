extends Area3D
class_name SpatialAudioTrigger

@export var one_shot: bool = true
@export var auto_play_on_start: bool = false

@onready var _audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D

var _has_played: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if auto_play_on_start:
		_play_audio()

func _on_body_entered(body: Node) -> void:
	if body.name != "Player":
		return
	if one_shot and _has_played:
		return
	_play_audio()

func _play_audio() -> void:
	if _audio_player.stream == null:
		return
	_audio_player.play()
	_has_played = true

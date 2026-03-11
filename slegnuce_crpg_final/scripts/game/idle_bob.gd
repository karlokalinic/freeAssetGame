extends Node3D
class_name IdleBob

@export var amplitude: float = 0.06
@export var speed: float = 1.8

var _base_y: float

func _ready() -> void:
	_base_y = position.y

func _process(delta: float) -> void:
	position.y = _base_y + sin(Time.get_ticks_msec() / 1000.0 * speed) * amplitude
	rotate_y(delta * 0.4)

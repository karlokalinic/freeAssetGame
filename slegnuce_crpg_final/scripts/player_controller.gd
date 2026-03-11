extends CharacterBody3D

@export var move_speed: float = 5.5
@export var stop_distance: float = 0.15
@export var fixed_height: float = 0.9

var _has_target: bool = false
var _target_position: Vector3 = Vector3.ZERO

func _ready() -> void:
	global_position.y = fixed_height

func set_move_target(world_position: Vector3) -> void:
	_target_position = world_position
	_target_position.y = fixed_height
	_has_target = true

func distance_to_target() -> float:
	return global_position.distance_to(_target_position)

func _physics_process(_delta: float) -> void:
	global_position.y = fixed_height

	if not _has_target:
		velocity.x = 0.0
		velocity.z = 0.0
		move_and_slide()
		return

	var to_target: Vector3 = _target_position - global_position
	to_target.y = 0.0
	if to_target.length() <= stop_distance:
		_has_target = false
		velocity.x = 0.0
		velocity.z = 0.0
		move_and_slide()
		return

	var direction: Vector3 = to_target.normalized()
	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed

	if direction.length() > 0.01:
		look_at(global_position + Vector3(direction.x, 0.0, direction.z), Vector3.UP)

	move_and_slide()
	global_position.y = fixed_height

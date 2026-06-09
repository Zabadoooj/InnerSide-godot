class_name EnemyPathCheck extends Node3D


@onready var _raycast : RayCast3D = $BarrierChecker
@onready var _player_raycast : RayCast3D = $PlayerChecker
@export_flags_3d_physics var raycast_collision_mask : int = 1


var check_radius : float = 2.0
var player_check_radius : float = 5.0



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	if _raycast == null:
		push_error("AttackComponent: не найден дочерний RayCast3D!")
		return
	
	_raycast.enabled = true
	_raycast.target_position = Vector3(0.0, -check_radius, 0.0)
	_raycast.collision_mask = raycast_collision_mask

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:	
	
	if _raycast.get_collider() != null and _raycast.get_collider().name != "PlayerController":
		get_parent().find_path()
		pass
	
	if _player_raycast.get_collider() != null and _player_raycast.get_collider().name == "PlayerController":
		print("Нашел игрока")

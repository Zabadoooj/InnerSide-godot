class_name PlayerController extends CharacterBody3D


@export_category("Настройки передвижения")
@export var speed : float = 5.0
@export var acceleration : float = 10.0
@export var deceleration : float = 15.0
@export var jump_force : float = 5.0


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Прыжок
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force

	var input_dir : Vector2 = Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
		"move_backward"
	)

	var direction : Vector3 = (
		transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)
	).normalized()

	if direction != Vector3.ZERO:
		velocity.x = lerp(velocity.x, direction.x * speed, acceleration * delta)
		velocity.z = lerp(velocity.z, direction.z * speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, deceleration * delta)
		velocity.z = move_toward(velocity.z, 0.0, deceleration * delta)

	move_and_slide()

func update_rotation(rotation_input: Vector3) -> void:
	global_transform.basis = Basis.from_euler(rotation_input)

class_name PlayerController extends CharacterBody3D


@export_category("Настройки передвижения")
@export var speed : float = 5.0
@export var acceleration : float = 50.0  # Скорость разгона
@export var deceleration : float = 30.0  # Скорость торможения


func _physics_process(delta: float) -> void:
	# Гравитация
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Получаем направление ввода
	var input_dir : Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")

	# Переводим 2D ввод в 3D направление относительно ориентации игрока
	var direction : Vector3 = (transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()

	# Плавно разгоняем или тормозим горизонтальную скорость
	if direction != Vector3.ZERO:
		velocity.x = lerp(velocity.x, direction.x * speed, acceleration * delta)
		velocity.z = lerp(velocity.z, direction.z * speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, deceleration * delta)
		velocity.z = move_toward(velocity.z, 0.0, deceleration * delta)

	move_and_slide()


func update_rotation(rotation_input: Vector3) -> void:
	global_transform.basis = Basis.from_euler(rotation_input)

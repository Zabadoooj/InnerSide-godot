class_name PlayerController extends CharacterBody3D

## Класс игрока
##
## Обрабатывает ввод для передвижения игрока и хранит основные переменные


@export_category("Настройки передвижения")
@export var speed : float = 5.0				## Скорость игрока
@export var acceleration : float = 10.0		## Скорость ускорения игрока при нажатии клавиши ввода
@export var deceleration : float = 15.0		## Скорость замедления после отпуска клавиши ввода
@export var jump_force : float = 6.0		## Сила прыжка


func _physics_process(delta: float) -> void:
	
	## Проверка наличия игрока на земле
	if not is_on_floor():
		velocity += get_gravity() * delta

	## Логика прыжка
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force
	
	## Присваивает типы ввода с клавиш передвижения
	var input_dir : Vector2 = Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
		"move_backward"
	)
	
	## Направление движения игрока
	var direction : Vector3 = (
		transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)
	).normalized()
	
	## Если есть ввод с клавиш движения - ускоряем игрока
	if direction != Vector3.ZERO:
		velocity.x = lerp(velocity.x, direction.x * speed, acceleration * delta)
		velocity.z = lerp(velocity.z, direction.z * speed, acceleration * delta)
	
	## Если ввода с клавиши нет - замедляем игрока
	else:
		velocity.x = move_toward(velocity.x, 0.0, deceleration * delta)
		velocity.z = move_toward(velocity.z, 0.0, deceleration * delta)
	
	## Двигает игрока
	move_and_slide()


## Обновляет поворот для игрока
## [br] Получает обработаный ввод с мыши из [CameraController] 
## и поворачивает нашего игрока в сторону движения камеры
func update_rotation(rotation_input: Vector3) -> void:
	global_transform.basis = Basis.from_euler(rotation_input)

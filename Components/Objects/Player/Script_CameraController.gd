class_name CameraController extends Node3D


@export var debug : bool = false
@export_category("Референсы")
@export var player_controller : PlayerController
@export var component_mouse_capture : MouseCaptureComponent

@export_category("Настройки камеры")
@export_range(-90, -10) var tilt_lower_limit : int = -70
@export_range(10, 90)  var tilt_upper_limit : int  = 70

var _rotation : Vector3


func _process(_delta: float) -> void:
	# Читаем и сбрасываем ввод мыши за этот кадр
	var input := component_mouse_capture.consume_input()

	if input != Vector2.ZERO:
		update_camera_rotation(input)

	if debug:
		print("Camera rotation: ", _rotation)


func update_camera_rotation(input: Vector2) -> void:
	# Обновление движения камеры
	
	# Обновляем значения камеры, сохраняя ограничители
	_rotation.x += input.y
	_rotation.y += input.x
	_rotation.x = clamp(_rotation.x, deg_to_rad(tilt_lower_limit), deg_to_rad(tilt_upper_limit))

	# Ось Z не трогаем
	_rotation.z = 0.0

	# Применяет поворот камеры (только x)
	transform.basis = Basis.from_euler(Vector3(_rotation.x, 0.0, 0.0))

	# Применяеит поворот игрока (только y)
	player_controller.update_rotation(Vector3(0.0, _rotation.y, 0.0))

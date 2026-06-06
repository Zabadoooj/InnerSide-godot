class_name CameraController extends Node3D


@export var debug : bool = false
@export_category("Референсы")
@export var player_controller : PlayerController
@export var component_mouse_capture : MouseCaptureComponent

@export_category("Настройки камеры")
@export_range(-90, -60) var tilt_lower_limit : int = -90
@export_range(60, 90) var tilt_upper_limit : int = 90

var _rotation : Vector3


func update_camera_rotation(input: Vector2) -> void:
	# Обновление движения камеры
	
	# Обновляем значения камеры, сохраняя ограничители
	_rotation.x += input.y
	_rotation.y += input.x
	_rotation.x = clamp(_rotation.x, deg_to_rad(tilt_lower_limit), deg_to_rad(tilt_upper_limit))
	
	# Устанавливаем поворот игрока и камеры НЕ ТРОГАЯ ось Z
	var _player_rotation = Vector3(0.0, _rotation.y, 0.0)
	var _camera_rotation = Vector3(_rotation.x, 0.0, 0.0)
	
	transform.basis = Basis.from_euler(_camera_rotation)
	player_controller.update_rotation(_player_rotation)
	
	_rotation.z = 0.0

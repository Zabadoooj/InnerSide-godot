class_name CameraController extends Node3D

## Класс для управления камерой игрока [PlayerController]
##
## Тут обрабатывается вся логика и устанавливаются настройки для камеры


## Дебаг для отладки
@export var debug : bool = false

## Здесь сразу передаются референсы на компоненты игрока 
## чтоб не искать их после запуска
@export_category("Референсы")
@export var player_controller : PlayerController ## Ссылка на [PlayerController]
@export var component_mouse_capture : MouseCaptureComponent ## Ссылка на компонент захвата движения мыши [MouseCaptureComponent]

## Настройки камеры
@export_category("Настройки камеры")
@export_range(-90, -10) var tilt_lower_limit : int = -70 ## Ограничение на просмотр вниз (градусы)
@export_range(10, 90)  var tilt_upper_limit : int  = 70 ## Ограничение на просмотр вверх (градусы)

## Текущий поворот камеры
var _rotation : Vector3


## Читаем и сбрасываем ввод мыши за этот кадр
func _process(_delta: float) -> void:

	## Ввод движения мыши
	var input := component_mouse_capture.consume_input()
	
	## Если движение мышкой есть - обновляем положение камеры
	if input != Vector2.ZERO:
		update_camera_rotation(input)
	
	## Если включен [param debug = true] выводит положение камеры
	if debug:
		print("Camera rotation: ", _rotation)


## Обновление движения камеры
##
## Принимает текущее положение мышки и обрабатывает его
func update_camera_rotation(input: Vector2) -> void:
	
	## Обновляем значения камеры, сохраняя ограничители
	_rotation.x += input.y
	_rotation.y += input.x
	_rotation.x = clamp(_rotation.x, deg_to_rad(tilt_lower_limit), deg_to_rad(tilt_upper_limit))

	# Ось Z не трогаем
	_rotation.z = 0.0

	# Применяет поворот камеры (только x)
	transform.basis = Basis.from_euler(Vector3(_rotation.x, 0.0, 0.0))

	# Применяеит поворот игрока (только y)
	player_controller.update_rotation(Vector3(0.0, _rotation.y, 0.0))

class_name MouseCaptureComponent extends Node

## Захват мыши
##
## Получает и обрабатывает ввод с мыши
## после чего удерживает курсор по середине экрана


## Переключение режима обработки
@export var debug : bool = false


@export_category("Настройки захвата мыши")
## Режим захвата мыши
@export var current_mouse_mode : Input.MouseMode = Input.MOUSE_MODE_CAPTURED
## Чувствительность мыши
@export var mouse_sensitivity : float = 0.005

## Накопленный ввод за кадр — сбрасывается ПОСЛЕ того, как камера его прочитает
var _mouse_input : Vector2


## Захватываем движение мыши только когда курсор скрыт
func _unhandled_input(event: InputEvent) -> void:
	
	## Если мышь двигается - получает её положение и разбивает на координаты
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_mouse_input.x += -event.relative.x * mouse_sensitivity		## Получает координату Х
		_mouse_input.y += -event.relative.y * mouse_sensitivity		## Получает координату У
	
	## Если включен режим дебага - выводит координаты мыши
	if debug:
		print("Mouse input: ", _mouse_input)


## Задает тип захвата мыши на [param current_mouse_mode]
func _ready() -> void:
	Input.mouse_mode = current_mouse_mode


## Метод для получения и сброса накопленного ввода
## Вызывается из [CameraController] и удерживает мышь по середине экрана
func consume_input() -> Vector2:
	var input := _mouse_input
	_mouse_input = Vector2.ZERO
	return input

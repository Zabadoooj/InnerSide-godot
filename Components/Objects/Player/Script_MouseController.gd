class_name MouseCaptureComponent extends Node


@export var debug : bool = false
@export_category("Настройки захвата мыши")
@export var current_mouse_mode : Input.MouseMode = Input.MOUSE_MODE_CAPTURED
@export var mouse_sensitivity : float = 0.005

var _capture_mouse : bool
var _mouse_input : Vector2


func _unhandled_input(event: InputEvent) -> void:
	# Захватываем движение мыши и проверяем, не открыт-ли интерфейс и т.п
	_capture_mouse = event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
	
	if _capture_mouse:
		_mouse_input.x += -event.screen_relative.x * mouse_sensitivity
		_mouse_input.y += -event.screen_relative.y * mouse_sensitivity
	
	# Дебаггинг (пишет положение мышки)
	if debug:
		print(_mouse_input)


func _ready() -> void:
	# Устанавливаем тип движения мышки
	Input.mouse_mode = current_mouse_mode


func _process(_delta: float) -> void:
	# Обнуляем движение мышки каждый кадр, чтоб курсор не двигался с камерой
	_mouse_input = Vector2.ZERO

class_name MouseCaptureComponent extends Node


@export var debug : bool = false
@export_category("Настройки захвата мыши")
@export var current_mouse_mode : Input.MouseMode = Input.MOUSE_MODE_CAPTURED
@export var mouse_sensitivity : float = 0.005

# Накопленный ввод за кадр — сбрасывается ПОСЛЕ того, как камера его прочитает
var _mouse_input : Vector2


func _unhandled_input(event: InputEvent) -> void:
	# Захватываем движение мыши только когда курсор скрыт
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		# relative вместо screen_relative — корректно работает на всех платформах в Godot 4
		_mouse_input.x += -event.relative.x * mouse_sensitivity
		_mouse_input.y += -event.relative.y * mouse_sensitivity

	if debug:
		print("Mouse input: ", _mouse_input)


func _ready() -> void:
	Input.mouse_mode = current_mouse_mode


# Метод для получения и сброса накопленного ввода.
# Вызывается из CameraController — это гарантирует правильный порядок.
func consume_input() -> Vector2:
	var input := _mouse_input
	_mouse_input = Vector2.ZERO
	return input

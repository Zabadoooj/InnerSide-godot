class_name AttackComponent extends Node3D

## Обработка атак игрока
## 
## Обрабатывает ввод атаки ближнего боя через рейкаст
## [br] Получает данные с рейкаста (дальности атаки) и работает с ними

## Отладка
@export var debug : bool = false

@export_category("Настройки атаки")
@export var attack_action : String = "attack"	## Задается кнопка атаки
@export var attack_damage : int = 1				## Урон от атаки
@export var attack_range : float = 3			## Радиус, в котором игрок может атакавать
@export var can_attack : bool = false			## Может ли игрок атакавать в данный момент


@export_category("Настройки рывка при атаке вблизи")
## Сколько метров пролетит игрок при атаке
@export_range(0.0, 2.0) var dash_distance : float = 1.0
## За сколько секунд пролетит (короче = резче)
@export_range(0.0001, 0.002) var dash_duration : float = 0.001


@export_category("Настройки кулдауна")
@export var attack_cooldown : float = 0.3	## Промежуток в секунды между атаками


## Настройки коллизии рейкаста атаки
@export_flags_3d_physics var raycast_collision_mask : int = 1

## Получаем рейкаст, которым будем считывать возможность атаки в данный момент
@onready var _raycast : RayCast3D = $RayCast3D	

## Ссылка на игрока
var _player : CharacterBody3D = null

## Рывок
var _dash_velocity : Vector3 = Vector3.ZERO		## Получаем направление рывка
var _dash_timer : float = 0.0					## Сколько осталось рывка

## Кулдаун атаки
var _cooldown_timer : float = 0.0

### Функции


func _ready() -> void:
	## Проверяет наличие рейкаста у игрока ( на всякий случай )
	if _raycast == null:
		push_error("AttackComponent: не найден дочерний RayCast3D!")
		return
	
	## Включаем рейкаст ( на всякий случай )
	_raycast.enabled = true
	## Устанавливаем сторону рейкаста ( радиус атаки игрока ) [param attack_range]
	_raycast.target_position = Vector3(0.0, -attack_range, 0.0)
	## Дополнительно ставим маску рейкаста, чтоб он реагировал на объекты в определенных группах
	_raycast.collision_mask = raycast_collision_mask
	
	## Получаем игрока
	_player = _get_parent_of_type(self, CharacterBody3D)
	## Проверяем удалось-ли найти игрока
	if _player != null:
		_raycast.add_exception(_player)		## Добавляет игрока в список исключений проверки рейкаста
	else:
		push_error("AttackComponent: CharacterBody3D не найден в родителях!")


## Если нажимаем атаку - пытаемся атакавать 
func _unhandled_input(event: InputEvent) -> void:
	## Проверяем нажатие на кнопку атаки
	if event.is_action_pressed(attack_action):
		_try_attack()


## Всякие обработки
func _physics_process(delta: float) -> void:
	## Тикаем таймеры
	if _cooldown_timer > 0.0:
		_cooldown_timer -= delta

	if _dash_timer > 0.0:
		_dash_timer -= delta

		## Добавляем скорость рывка ПОВЕРХ текущей velocity игрока
		## Так движение от ввода не блокируется — просто получает доп. импульс
		if _player != null:
			_player.velocity.x += _dash_velocity.x * delta		## Двигаем игрока в сторону врага по оси Х
			_player.velocity.z += _dash_velocity.z * delta		## Двигаем игрока в сторону врага по оси Z
		
		## Если таймерк кулдауна рывка <= 0 - то обнуляем скорость рывка к врагу
		if _dash_timer <= 0.0:
			_dash_velocity = Vector3.ZERO
			
			## Если вклчен дебаг
			if debug:
				print("AttackComponent: рывок завершён")
	
	## Если включен дебаг
	if debug and _raycast.is_colliding():
		print("RayCast видит: ", _raycast.get_collider().name)


## --- Приватные методы ---

## Попытка атаки
func _try_attack() -> void:
	## Кулдаун ещё не прошёл
	if _cooldown_timer > 0.0:
		if debug:
			print("AttackComponent: кулдаун %.2f сек" % _cooldown_timer)
		return

	if can_attack:
		if debug:
			print("AttackComponent: атака заблокирована — в руках предмет")
		return

	if not _raycast.is_colliding():
		if debug:
			print("AttackComponent: промах")
		return

	var target := _raycast.get_collider()

	if target is Enemy:
		target.take_damage(attack_damage)
		_start_dash_to_target(target)
		_cooldown_timer = attack_cooldown  # Запускаем кулдаун после успешной атаки
		if debug:
			print("AttackComponent: удар по ", target.name)
	else:
		if debug:
			print("AttackComponent: попал в '%s', но это не Enemy" % target.name)


func _start_dash_to_target(target: Node3D) -> void:
	if _player == null:
		return

	var to_target : Vector3 = target.global_position - _player.global_position

	if to_target.length() < 0.01:
		return

	## Скорость рывка = расстояние / время. delta потом превратит её в м/кадр
	## Но мы не хотим лететь дальше dash_distance — ограничиваем реальным расстоянием
	var actual_distance : float = minf(to_target.length(), dash_distance)
	var speed : float = actual_distance / dash_duration

	_dash_velocity = to_target.normalized() * speed
	_dash_timer = dash_duration

	if debug:
		print("AttackComponent: рывок %.2f м за %.2f сек" % [actual_distance, dash_duration])


func _get_parent_of_type(node: Node, type) -> Node:
	var parent := node.get_parent()
	while parent != null:
		if is_instance_of(parent, type):
			return parent
		parent = parent.get_parent()
	return null

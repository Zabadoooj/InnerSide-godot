class_name Enemy extends CharacterBody3D


@onready var nav_agent : NavigationAgent3D = $NavigationAgent3D
@onready var visuals: Node3D = $Model

@export_category("Настройки врага")
@export var max_health : int = 3 # Количество ударов до смерти
@export var flash_duration : float = 0.15 # Длительность мигания при уроне
@export var enemy_walk_speed : float = 5.0

@export_category("Дроп")

@export var has_drop: bool = false
@export var drop_scene: PackedScene
@export var drop_count: int = 2


var _current_health : int
var _mesh_instance : MeshInstance3D       # Ссылка на меш для эффекта мигания
var rotation_speed: float = 8.0 


func find_path() -> void:
	var random_position : Vector3 = Vector3.ZERO
	random_position.x = randf_range(-10.0, 10.0)
	random_position.z = randf_range(-10.0, 10.0)
	nav_agent.set_target_position(random_position)
	
	


func _ready() -> void:
	_current_health = max_health
	
	if randi_range(0, 1) == 1:
		has_drop = true
	else:
		has_drop = false

	# Ищем меш-ноду среди дочерних (капсула создаётся в редакторе)
	_mesh_instance = _find_mesh_instance(self)

	if _mesh_instance == null:
		push_warning("Enemy: не найден MeshInstance3D среди дочерних нодов")
	
	
	find_path()


func _physics_process(delta: float) -> void:
	var destanation = nav_agent.get_next_path_position()
	var local_destanation = destanation - global_position
	var direction = local_destanation.normalized()
	
	velocity = direction * enemy_walk_speed
	
	move_and_slide()
	
	var move_direction: Vector3 = Vector3(velocity.x, 0, velocity.z)
	
	if move_direction.length() > 0.1:
		# Создаем целевую матрицу вращения (базис), направленную в сторону движения
		# Vector3.UP указывает, где у объекта находится "верх"
		var target_basis: Basis = Basis.looking_at(move_direction, Vector3.UP)
		
		# Плавно интерполируем текущий базис визуальной модели к целевому
		visuals.global_basis = visuals.global_basis.slerp(target_basis, rotation_speed * delta)


# --- Публичный метод — вызывается из AttackComponent ---

func take_damage(amount: int = 1) -> void:
	if _current_health <= 0:
		return

	_current_health -= amount

	_flash_damage()

	if _current_health <= 0:
		_die()


# --- Приватные методы ---

func _throw_drop(drop: Node3D) -> void:
	var start_pos := drop.global_position

	var random_dir := Vector3(
		randf_range(-1.0, 1.0),
		0.0,
		randf_range(-1.0, 1.0)
	).normalized()

	var peak_pos := start_pos + Vector3.UP * randf_range(1.0, 1.5)
	var end_pos := peak_pos + random_dir * randf_range(0.5, 1.5)

	var tween := create_tween()

	tween.tween_property(
		drop,
		"global_position",
		peak_pos,
		0.2
	).set_trans(Tween.TRANS_QUAD)

	tween.tween_property(
		drop,
		"global_position",
		end_pos,
		0.25
	).set_trans(Tween.TRANS_BOUNCE)

func _spawn_drop() -> void:
	if drop_scene == null:
		return

	for i in drop_count:
		var drop := drop_scene.instantiate()

		get_parent().add_child(drop)

		drop.global_position = global_position + Vector3(randf_range(-1.0, 1.0), 0, randf_range(-1.0, 1.0))

		# Случайный тип улучшения
		drop.upgrade_type = randi() % DropItem.UpgradeType.size()

		_throw_drop(drop)


func _die() -> void:

	if has_drop:
		_spawn_drop()

	queue_free()


func _flash_damage() -> void:
	if _mesh_instance == null:
		return

	# Меняем цвет меша на красный и возвращаем обратно
	var _original_material := _mesh_instance.get_active_material(0)
	var flash_material := StandardMaterial3D.new()
	flash_material.albedo_color = Color.WHITE

	_mesh_instance.set_surface_override_material(0, flash_material)
	await get_tree().create_timer(flash_duration).timeout
	_mesh_instance.set_surface_override_material(0, null)  # Возвращаем оригинальный материал


func _find_mesh_instance(node: Node) -> MeshInstance3D:
	for child in node.get_children():
		if child is MeshInstance3D:
			return child
		var result := _find_mesh_instance(child)
		if result != null:
			return result
	return null

class_name Enemy extends CharacterBody3D


@export_category("Настройки врага")
@export var max_health : int = 3          # Количество ударов до смерти
@export var flash_duration : float = 0.15 # Длительность мигания при уроне

var _current_health : int
var _mesh_instance : MeshInstance3D       # Ссылка на меш для эффекта мигания


func _ready() -> void:
	_current_health = max_health

	# Ищем меш-ноду среди дочерних (капсула создаётся в редакторе)
	_mesh_instance = _find_mesh_instance(self)

	if _mesh_instance == null:
		push_warning("Enemy: не найден MeshInstance3D среди дочерних нодов")


# --- Публичный метод — вызывается из AttackComponent ---

func take_damage(amount: int = 1) -> void:
	if _current_health <= 0:
		return

	_current_health -= amount
	print("Enemy HP: %d / %d" % [_current_health, max_health])

	_flash_damage()

	if _current_health <= 0:
		_die()


# --- Приватные методы ---

func _die() -> void:
	print("Enemy: погиб")
	# Здесь можно добавить анимацию смерти, дроп лута и т.д.
	queue_free()


func _flash_damage() -> void:
	if _mesh_instance == null:
		return

	# Меняем цвет меша на красный и возвращаем обратно
	var original_material := _mesh_instance.get_active_material(0)
	var flash_material := StandardMaterial3D.new()
	flash_material.albedo_color = Color.RED

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

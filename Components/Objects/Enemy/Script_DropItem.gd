class_name DropItem
extends Node3D

enum UpgradeType {
	HEALTH,
	DAMAGE,
	SPEED,
	ATTACK_SPEED
}

@export var upgrade_type: UpgradeType


func _ready() -> void:
	print("Drop type:", UpgradeType.keys()[upgrade_type])

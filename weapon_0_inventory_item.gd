extends InventoryItem
class_name WeaponItem

enum Types {
	RANGE,
	MELEE,
}

@export var damage := 10.0
@export var speed := 1.0
@export var weapon_type:int = Types.MELEE

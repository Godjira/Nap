extends InventoryItem
class_name ArmorItem

enum Types {
	SKIN,
	IRON,
}

@export var armor := 2.0
@export var armor_type:Types = Types.SKIN

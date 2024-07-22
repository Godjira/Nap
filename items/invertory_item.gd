extends Resource
class_name InventoryItem

enum {
	DEFAULT,
	WEAPON,
	POTION
}

@export var name:String = ""
@export var texture:Texture2D
@export var type:int = DEFAULT

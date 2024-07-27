extends Resource
class_name InventoryItem

enum Type {
	DEFAULT,
	WEAPON,
	POTION
}

@export var name:String = ""
@export var texture:Texture2D
@export var type:Type = Type.DEFAULT

# TilePosition.gd
class_name TilePosition

@export var position: Vector2
@export var global_position: Vector2

func _init(p_position: Vector2 = Vector2.ZERO, p_global_position: Vector2 = Vector2.ZERO):
	position = p_position
	global_position = p_global_position

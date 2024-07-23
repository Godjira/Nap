# TilePosition.gd
class_name TilePosition

@export var coordinate: Vector2
@export var global_position: Vector2

func _init(p_coordinate: Vector2 = Vector2.ZERO, p_global_position: Vector2 = Vector2.ZERO):
	coordinate = p_coordinate
	global_position = p_global_position

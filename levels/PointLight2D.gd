extends PointLight2D
@export var follow: Node2D

func _process(delta:float)->void:
	position = follow.position

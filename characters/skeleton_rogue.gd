extends Node3D

@onready var model = $Rig


func _ready():
	var meshInstance = get_node("Rig/Skeleton3D")
	# loop over all the children of the meshInstance
	for child in meshInstance.get_children():
		# if the child is a MeshInstance
		if is_instance_of(child, MeshInstance3D):
			print(child)

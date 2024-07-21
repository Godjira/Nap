extends Camera3D

@export var target_path: NodePath
@export var bone_name: String = "mixamorig_HeadTop_End"  # The name of the bone to track, e.g., "Head"
@export var distance: float = 0.1
@export var height: float = 12.0

var target: Node3D
var skeleton: Skeleton3D

func _ready():
	# Get the target node (character)
	target = get_node(target_path)
	
	# Ensure the target is valid
	if not target:
		printerr("Target node not found!")
		set_process(false)
		return
	
	# Find the Skeleton3D node
	skeleton = find_skeleton(target)
	if not skeleton:
		printerr("Skeleton3D not found in the target or its children!")
		set_process(false)

func find_skeleton(node: Node) -> Skeleton3D:
	if node is Skeleton3D:
		return node
	for child in node.get_children():
		var found = find_skeleton(child)
		if found:
			return found
	return null

func _process(delta):
	if target and skeleton:
		var bone_idx = skeleton.find_bone(bone_name)
		if bone_idx != -1:
			# Get the global position of the bone
			var bone_global_pos = skeleton.global_transform * skeleton.get_bone_global_pose(bone_idx).origin
			
			# Calculate the desired position behind the bone
			var camera_pos = bone_global_pos - target.global_transform.basis.z * distance
			camera_pos.y += height
			camera_pos.x += 40.0
			
			# Set the camera position
			global_transform.origin = camera_pos
			
			# Make the camera look at the bone
			look_at(bone_global_pos, Vector3.UP)
		else:
			printerr("Bone '", bone_name, "' not found in the skeleton!")

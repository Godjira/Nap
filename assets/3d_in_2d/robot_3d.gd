extends Node

@onready var model = $Model	
var velocity := Vector3()

func _process(delta):
	var input_direction = Vector3()
	if Input.is_action_pressed("left"):
		input_direction.x -= 1
	if Input.is_action_pressed("right"):
		input_direction.x += 1
	if Input.is_action_pressed("up"):
		input_direction.z -= 1
	if Input.is_action_pressed("down"):
		input_direction.z += 1


	if input_direction.length() > 0:
		# calculate the angle between the input direction and the forward direction
		var angle = atan2(input_direction.x, input_direction.z)
		# rotate the model to face the input direction
		model.rotation_degrees.y = angle * 180 / PI

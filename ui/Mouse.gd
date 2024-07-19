extends CanvasLayer


# Load the custom images for the mouse cursor.
var arrow = load("res://assets/art/sword.png")


func _ready():
	# Changes only the arrow shape of the cursor.
	# This is similar to changing it in the project settings.
	Input.set_custom_mouse_cursor(arrow)

#func _input(event):
	#if event is InputEventMouseMotion:
		#$Canvas.position = event.position
		#print("Mouse Motion at: ", event.position)

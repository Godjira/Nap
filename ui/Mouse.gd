extends CanvasLayer


# Load the custom images for the mouse cursor.
var arrow = load("res://assets/RavenmoreIconPack.02.2014/64/swordWood.png")


func _ready():
	var img = Image.new()
	img.load("res://assets/RavenmoreIconPack.02.2014/64/swordWood.png")
	var tex = ImageTexture.new()
	tex.create_from_image(img)
	Input.set_custom_mouse_cursor(tex, Input.CURSOR_ARROW, Vector2(tex.get_width() * 0.5, tex.get_height()) * 0.25)
	#Input.set_custom_mouse_cursor(arrow)



#func _input(event):
	#if event is InputEventMouseMotion:
		#$Canvas.position = event.position
		#print("Mouse Motion at: ", event.position)

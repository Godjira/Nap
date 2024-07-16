extends AnimatedSprite2D

var num_frames = 10
var frame_delay = 0.1
var desired_fps = 30

# Called when the node enters the scene tree for the first time.
func _ready():
	var texture = AnimatedTexture.new()
	# Set number of frames
	texture.frames = num_frames
	var cursor = load("res://assets/art/sword")
	# hide the default cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	Input.set_custom_mouse_cursor(texture, Input.CURSOR_ARROW, Vector2())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

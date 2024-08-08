extends SubViewport

func _ready():
	# Set the size of the viewport (adjust as needed)
	size = Vector2(200, 200)
	
	# Disable transparent background
	transparent_bg = false
	
	# Set render target settings
	render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
	render_target_update_mode = SubViewport.UPDATE_ALWAYS
	
	# Add a colored rectangle as background (optional)
	var background = ColorRect.new()
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.color = Color(0.1, 0.1, 0.1)  # Dark gray
	add_child(background)
	
	# Ensure the camera is set up correctly
	var camera = get_node("Camera2D")
	if camera:
		camera.make_current()
		# Set zoom if needed
		# camera.zoom = Vector2(0.1, 0.1)

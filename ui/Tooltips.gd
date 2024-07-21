extends Control


# Called when the node enters the scene tree for the first time.
func _process(delta):
	if Input.is_action_pressed("up"):
		set_ui_color($Up, Color.RED)
	else:
		set_ui_color($Up, Color.WHITE)
		
	if Input.is_action_pressed("left"):
		set_ui_color($Left, Color.RED)
	else:
		set_ui_color($Left, Color.WHITE)
	
	if Input.is_action_pressed("right"):
		set_ui_color($Right, Color.RED)
	else:
		set_ui_color($Right, Color.WHITE)
	
	if Input.is_action_pressed("down"):
		set_ui_color($Down, Color.RED)
	else:
		set_ui_color($Down, Color.WHITE)
	
	if Input.is_action_pressed("sprint"):
		set_ui_color($Sprint, Color.RED)
	else:
		set_ui_color($Sprint, Color.WHITE)
	
	if Input.is_action_pressed("dash"):
		set_ui_color($Dash, Color.RED)
	else:
		set_ui_color($Dash, Color.WHITE)
	
	if Input.is_action_pressed("attack"):
		set_ui_color($Attack, Color.RED)
	else:
		set_ui_color($Attack, Color.WHITE)


func set_ui_color(l:Label, c:Color) -> void:
	l.add_theme_color_override("font_color", c)

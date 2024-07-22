extends CanvasLayer

@onready var up := $wasd/Up
@onready var left := $wasd/Left
@onready var right := $wasd/Right
@onready var down := $wasd/Down

@onready var sprint := $Tooltips/Sprint
@onready var dash := $Tooltips/Dash
@onready var attack := $Tooltips/Attack

func _ready():
	var actions = InputMap.get_actions()
	for action in actions:
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			var event := events[0] as InputEvent
			var key_name := ""
			if event is InputEventKey:
				key_name = OS.get_keycode_string(event.physical_keycode)
			elif event is InputEventMouseButton:
				key_name = "Mouse " + str(event.button_index)
			
			match action:
				"up":
					up.text = key_name
				"down":
					down.text = key_name
				"left":
					left.text = key_name
				"right":
					right.text = key_name
				"sprint":
					sprint.text = key_name
				"dash":
					dash.text = key_name
				"attack":
					attack.text = key_name

func _process(delta):
	update_ui_color("up", up)
	update_ui_color("down", down)
	update_ui_color("left", left)
	update_ui_color("right", right)
	update_ui_color("sprint", sprint)
	update_ui_color("dash", dash)
	update_ui_color("attack", $Tooltips/Attack)

func update_ui_color(action: String, label: Label):
	if Input.is_action_pressed(action):
		set_ui_color(label, Color.RED)
	else:
		set_ui_color(label, Color.WHITE)

func set_ui_color(l: Label, c: Color) -> void:
	l.add_theme_color_override("font_color", c)


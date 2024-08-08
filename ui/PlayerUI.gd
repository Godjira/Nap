extends CanvasLayer
class_name PlayerUI

@onready var up := $wasd/Up
@onready var left := $wasd/Left
@onready var right := $wasd/Right
@onready var down := $wasd/Down

@onready var sprint := $Tooltips/Sprint
@onready var dash := $Tooltips/Dash
@onready var attack := $Tooltips/Attack
@onready var screen_ui = $"/root/ScreenUi"
@onready var game_global := $"/root/GameGlobalNode"

var time_in_game := ""
var time_in_begging := ""
@onready var time_in_game_ui := $TimeInGame

static var player: Character0

func parse_time_string(time_str: String) -> int:
	if time_str.length() > 0:
		var parts = time_str.split(":")
		var hours = int(parts[0])
		var minutes = int(parts[1])
		var seconds = int(parts[2])
		return hours * 3600 + minutes * 60 + seconds
	return 0

func format_time_string(total_seconds: int) -> String:
	var hours = total_seconds / 3600
	var minutes = (total_seconds % 3600) / 60
	var seconds = total_seconds % 60
	return "%02d:%02d:%02d" % [hours, minutes, seconds]

func calculate_time_difference(time1: String, time2: String) -> String:
	var seconds1 = parse_time_string(time1)
	var seconds2 = parse_time_string(time2)
	var diff_seconds = abs(seconds2 - seconds1)
	return format_time_string(diff_seconds)
	
func attach_player(player: Character0):
	if player:
		var ui_slots = $Inventory/NinePatchRect/GridContainer.get_children() as Array[Panel] 
		ui_slots.append_array($Inventory/NinePatchRect2.get_children() as Array[Panel])
		for slot in ui_slots:
			slot.attach_player(player)
		$Minimap.attach_player(player)
	
func _ready():
	# reset timer on restart
	screen_ui.connect(
		"start_game", 
		func(): 
			time_in_begging = Time.get_time_string_from_system()
			
	)
	time_in_begging = Time.get_time_string_from_system()
	# display actual keys in ui
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
	var current_time = Time.get_time_string_from_system()
	var time_diff = calculate_time_difference(current_time, time_in_begging)
	time_in_game_ui.text = time_diff
	game_global.update_time(time_diff)
	


func update_ui_color(action: String, label: Label):
	if Input.is_action_pressed(action):
		set_ui_color(label, Color.RED)
	else:
		set_ui_color(label, Color.BLACK)

func set_ui_color(l: Label, c: Color) -> void:
	l.add_theme_color_override("font_color", c)



func _on_inventory_update_slot(slot: InventorySlot):
	if player: player.show_equipment(slot)

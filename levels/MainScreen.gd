extends CanvasLayer

# Notifies `Main` node that the button has been pressed
signal start_game

@onready var start_button = $Control/StartButton
@onready var custom_pass = $Control/CustomPass
@onready var game_global = $"/root/GameGlobalNode"
@export var hidden = false

func _ready():
	var material: ShaderMaterial = custom_pass.material as ShaderMaterial
	material.set_shader_parameter("blurAmount", 0.0)

var on_start_game

var default_message = 'N.A.P Assottiation Security'

func change_pass_blur(value, dur):
	# Get the ShaderMaterial of the Sprite
	var material: ShaderMaterial = custom_pass.material as ShaderMaterial
	# Now you can set shader parameters
	var tween = get_tree().create_tween()
	tween.tween_property(material, "shader_parameter/blurAmount", value, dur)
	return tween

func show_message(text):
	$Control/Message2.text = text
	$Control/MessageTimer.start()
	
	
func show_game_over():
	var score = game_global.get_score() as Dictionary
	var jstr = JSON.stringify(score)
	show_message("Game Over")
	show_score(score)
	show_ui()

func show_score(score:Dictionary) -> void:
	$Control/Message.text = "Kills: " + str(score.kills) + "\nTime in game: " + score.time_in_game

func handle_pause():
	$Control/Message2.text = default_message
	var tween = change_pass_blur(.8, 0.5)
	await tween.finished
	var tween2 = change_pass_blur(0.05, 0.01)
	await tween2.finished
	show_ui()
	# Make a one-shot timer and wait for it to finish.
	await get_tree().create_timer(1.0).timeout
	

func _on_start_button_pressed():
	hide_ui()
	start_game.emit()
	var tween = change_pass_blur(0.0, 1.0)
	await tween.finished
	

func _on_message_timer_timeout():
	$Control/Message.hide()
	$Control/Message2.hide()
	
#handle escape pressed
func _unhandled_key_input(_event):
	if Input.is_action_pressed('pause'):
		if hidden:
			handle_pause()
		else:
			hide_ui()

func hide_ui():
	$Control/BG.hide()
	$Control/Message.hide()
	$Control/Message2.hide()
	$Control/StartButton.hide()
	get_tree().paused = false
	hidden = true

func show_ui():
	$Control/BG.show()
	$Control/Message.show()
	$Control/Message2.hide()
	$Control/StartButton.show()
	get_tree().paused = true
	hidden = false

extends CanvasLayer

# Notifies `Main` node that the button has been pressed
signal start_game

@onready var start_button = $StartButton
@onready var custom_pass = $CustomPass

var default_message = 'N.A.P Assottiation Security'

func change_pass_blur(value, dur):
		# Get the ShaderMaterial of the Sprite
	var material: ShaderMaterial = custom_pass.material as ShaderMaterial
	# Now you can set shader parameters
	var tween = get_tree().create_tween()
	tween.tween_property(material, "shader_parameter/blurAmount", value, dur)
	return tween

func show_message(text):
	$Message.text = text
	show_ui()
	$MessageTimer.start()
	
	
func show_game_over():
	show_message("Game Over")
	# Wait until the MessageTimer has counted down.
	await $MessageTimer.timeout
	show_ui()
	# Make a one-shot timer and wait for it to finish.
	await get_tree().create_timer(1.0).timeout

func handle_pause():
	$Message.text = default_message
	var tween = change_pass_blur(.8, 0.5)
	await tween.finished
	var tween2 = change_pass_blur(0.05, 0.1)
	await tween2.finished
	show_ui()
	# Make a one-shot timer and wait for it to finish.
	await get_tree().create_timer(1.0).timeout
	

func _on_start_button_pressed():
	hide_ui()
	var tween = change_pass_blur(0.0, 1.0)
	await tween.finished
	start_game.emit()

func _on_message_timer_timeout():
	$Message.hide()
	
@export var hidden = false
#handle escape pressed
func _unhandled_key_input(_event):
	if Input.is_action_pressed('pause'):
		if hidden:
			handle_pause()
		else:
			hide_ui()

func hide_ui():
	$BG.hide()
	$Message.hide()
	$StartButton.hide()
	get_tree().paused = false
	hidden = true

func show_ui():
	$BG.show()
	$Message.show()
	$StartButton.show()
	get_tree().paused = true
	hidden = false

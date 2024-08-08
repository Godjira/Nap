extends CanvasModulate
@onready var animation_player := $AnimationPlayer
@onready var timer := $Timer
@onready var game_global := $"/root/GameGlobalNode"

func _process(delta:float) -> void:
	var time_passed = timer.wait_time - timer.time_left
	var animation_frame := remap(time_passed, 0, timer.wait_time, 0, 24)
	game_global.day_night_time = animation_frame
	animation_player.seek(animation_frame)

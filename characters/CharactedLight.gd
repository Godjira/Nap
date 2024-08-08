extends PointLight2D
@onready var game_global := $"/root/GameGlobalNode"

func _process(delta:float)->void:
	if game_global:
		if game_global.day_night_time > 20 or game_global.day_night_time < 8:
			show()
		else:
			hide()
	

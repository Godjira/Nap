extends DirectionalLight2D
@onready var game_global := $"/root/GameGlobalNode"

func _process(delta:float)->void:
	rotation_degrees = lerp(rotation_degrees, game_global.day_night_time * 15.0, 0.1)
	if game_global.day_night_time < 8 || game_global.day_night_time > 20:
		energy = 0
	else:
		energy = lerp(energy, game_global.day_night_time * 0.01, 0.1)

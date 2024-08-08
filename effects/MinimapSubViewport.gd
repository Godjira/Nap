extends SubViewport

@onready var player_marker := $PlayerMarker
@onready var camera := $Camera2D
var player: Character0

func _process(delta):
	if player:
		var viewport_size = get_size()
		#/ $TileMap.cell_quadrant_size
		var relative_position = player.global_position 
		#camera.global_position = relative_position 
		player_marker.global_position = relative_position 

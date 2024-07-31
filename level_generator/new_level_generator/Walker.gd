# Walker.gd
extends Object

class_name Walker

var position: Vector2i
var direction: Vector2i
var thickness: int

static var directions = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]

# Constructor
func _init(position: Vector2i = Vector2i(0, 0), thickness: int = 1) -> void:
	self.position = position
	self.direction = directions.pick_random()
	self.thickness = thickness
	print("thickness" + str(thickness))

func move(change_direction_chance: float, min_x: int, max_x: int, min_y: int, max_y: int) -> void:
	# Check if we should change direction
	if randi() % 100 < change_direction_chance * 100:
		direction = directions[randi() % directions.size()]
	
	# Calculate new position
	var new_position = position + direction
	
	# Clamp the new position within bounds
	new_position.x = clamp(new_position.x, min_x, max_x - 1 - thickness)
	new_position.y = clamp(new_position.y, min_y, max_y - 1 - thickness)
	
	# Update the position
	position = new_position

func positions() -> Array:
	var positions = []
	for y in range(0, thickness):
		for x in range(0, thickness):
			var pos_with_thikness = position + Vector2i(x, y)
			print(pos_with_thikness)
			positions.append(pos_with_thikness)
	return positions

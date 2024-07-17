extends Node2D

@onready var tileMap = $TileMap
@onready var spriteGen = $SpriteGen
@onready var player = $TileMap/Character0
@export var Mob = preload("res://characters/Mob0.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var script = spriteGen.get_script()
	var cells = tileMap.get_used_cells_by_id(0, 0, Vector2i(0, 5))
	var global_positions: Array[Vector2] = []
	
	for pos in cells:
		var global_pos = tileMap.to_global(tileMap.map_to_local(pos))
		global_positions.append(global_pos)

	# Sort global positions by distance from the player
	global_positions.sort_custom(func(a: Vector2, b: Vector2) -> bool:
		return a.distance_squared_to(player.global_position) < b.distance_squared_to(player.global_position)
)
	
	var placed_sprites = []
	var min_distance = 100  # Adjust this value to control the minimum distance between sprites
	
	for global_pos in global_positions:
		var too_close = false
		
		# Check distance from player for the first sprite
		if placed_sprites.is_empty():
			if global_pos.distance_to(player.global_position) < min_distance:
				continue
		
		for placed_pos in placed_sprites:
			if global_pos.distance_to(placed_pos) < min_distance:
				too_close = true
				break
		
		if not too_close:
			var mob_instance = Mob.instantiate()
			mob_instance.position = global_pos
			mob_instance.player = player
			add_child(mob_instance)
			placed_sprites.append(global_pos)





# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

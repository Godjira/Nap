extends Node2D

@onready var tileMap = $TileMap
@onready var spriteGen = $SpriteGen
@onready var player = $TileMap/Character0
@export var Mob = preload("res://characters/Mob0.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var script = spriteGen.get_script()
	var cells = tileMap.get_used_cells_by_id(0, 0, Vector2i(0, 5))
	var tilePositions: Array[TilePosition] = []
	
	for pos in cells:
		var global_pos = tileMap.to_global(tileMap.map_to_local(pos))
		var tilePosition = TilePosition.new(pos, global_pos)
		tilePositions.append(tilePosition)

	print(tilePositions)
	# Sort global positions by distance from the player
	tilePositions.sort_custom(func(a: TilePosition, b: TilePosition) -> bool:
		return a.global_position.distance_squared_to(player.global_position) < b.global_pos.distance_squared_to(player.global_position)
)
	#Create outdoor

	var doorSprite = Sprite2D.new()
	doorSprite.position = 	tilePositions.back().globalPos
	tileMap.get_surrounding_cells()
	doorSprite.texture = load("res://artwork/outdoor.png")
	doorSprite.scale = Vector2(0.1, 0.1)
	add_child(doorSprite)
	
	
	var placed_sprites = []
	var min_distance = 200  # Adjust this value to control the minimum distance between sprites
	
	for tile_position in tilePositions:
		var too_close = false
		
		# Check distance from player for the first sprite
		if placed_sprites.is_empty():
			if tile_position.global_position.distance_to(player.global_position) < min_distance:
				continue
		
		for placed_pos in placed_sprites:
			if tile_position.global_position.distance_to(placed_pos) < min_distance:
				too_close = true
				break
		
		if not too_close:
			var mob_instance = Mob.instantiate()
			mob_instance.position = tile_position.global_position
			mob_instance.player = player
			add_child(mob_instance)
			placed_sprites.append(tile_position.global_position)





# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

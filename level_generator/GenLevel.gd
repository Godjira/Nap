extends Node2D

@onready var tileMap = $TileMap
@onready var spriteGen = $SpriteGen
@onready var player = $Character0
@export var Mob = preload("res://characters/Mob0.tscn")

@onready var walker = $Walker
@onready var portal = $Portal
# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().create_timer(0.2).timeout
	player.position += Vector2(0, 8)
	var script = spriteGen.get_script()	
	var cells = tileMap.get_used_cells_by_id(0, 0, Vector2i(0, 5))
	var tilePositions: Array[TilePosition] = []
	
	for pos in cells:
		var global_pos = tileMap.to_global(tileMap.map_to_local(pos))
		var tilePosition = TilePosition.new(pos, global_pos)
		tilePositions.append(tilePosition)

	# Sort global positions by distance from the player
	tilePositions.sort_custom(func(a: TilePosition, b: TilePosition) -> bool:
		return a.global_position.distance_squared_to(player.global_position) < b.global_position.distance_squared_to(player.global_position)
)
	#Create portal
	var portalGlobalPosition = tilePositions.back().global_position
	portal_generation(tilePositions)

	var placed_sprites = [portalGlobalPosition, position]
	var min_distance = 100  # Adjust this value to control the minimum distance between sprites
	
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

func portal_generation(tilePositions: Array[TilePosition]):
	if tilePositions.is_empty():
		print("No positions provided to place a portal.")
		return

	# Start from the end of the array and move towards the beginning
	var reversedTilePositions = tilePositions.duplicate()
	reversedTilePositions.reverse()
	
	for cell in reversedTilePositions:
		if not isAreaBusy(cell.coordinate):
			_place_portal(cell)
			print("Placed portal at position ", cell.coordinate)
			return  # Exit the function after placing a portal

	# If all positions are busy, use the very last position
	_place_portal(tilePositions[-1])
	print("All positions were busy. Placed portal at the last position.")

func _place_portal(tilePosition: TilePosition):
	portal.position = tilePosition.global_position
	markAsBusySurrounding(tilePosition.coordinate)

func markAsBusy(tile_position: Vector2):
	tileMap.get_cell_tile_data(0, tile_position).set_custom_data("Busy", true)
	
func markAsBusySurrounding(tile_position: Vector2, area_size: int = 1):
	for x in range(-area_size, area_size + 1):
		for y in range(-area_size, area_size + 1):
			if x == 0 and y == 0:
				continue  # Skip the center tile
			var cell = tile_position + Vector2(x, y)
			markAsBusy(cell)
			
func isAreaBusy(tile_position: Vector2, area_size: int = 1) -> bool:
	for x in range(-area_size, area_size + 1):
		for y in range(-area_size, area_size + 1):
			var cell = tile_position + Vector2(x, y)
			var tile_data = tileMap.get_cell_tile_data(0, cell)
			if tile_data:
				# Assuming "Busy" is the name of your custom data layer
				var is_busy = tile_data.get_custom_data("Busy")
				if is_busy:
					return true
	return false


func _on_walker_generation_started() -> void:
		walker.settings.max_tiles = GenerationData.get_max_tiles()
		print("MAx tiles ")
		print(walker.settings.max_tiles)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.get_groups().has("Player"):
		get_tree().reload_current_scene()

extends Node

@export_category("TileMap Settings")
@export var tile_map: TileMap
@export var terrain_set: int = 0  # The terrain set to use
@export var floor_terrain: int = 0  # Terrain index for floor
@export var wall_terrain: int = 1  # Terrain index for walls
@export var filling_terrain: int = 2  # Terrain index for filling

@export_category("Map Dimensions")
@export var map_width: int = 10
@export var map_height: int = 10
@export var min_margin: int = 4

@export_category("Walker Settings")
@export var max_walkers: int = 5
@export var max_tile: int = 10
@export_range(0, 1) var walker_death_chance: float = 0.02
@export_range(0, 1) var walker_spawn_chance: float = 0.05
@export_range(1, 5) var min_walker_thickness: int = 1
@export_range(1, 5) var max_walker_thickness: int = 2

var current_walkers: Array[Walker] = []
var floor_cells: Array[Vector2i] = []
var wall_cells: Array[Vector2i] = []

@export_range(0, 1) var change_direction_chance = 0.4

var min_x
var max_x
var min_y
var max_y

func _ready() -> void:
	setup()
	randomize()
	generate_terrain()
	
func setup():
	min_x = -map_width / 2
	max_x = map_width / 2
	min_y = -map_height / 2
	max_y = map_height / 2
	
func generate_terrain() -> void:
	generateFilling()
	generate_floor()
	generate_walls()
	
	
func generateFilling():
	for y in range(min_y - min_margin, max_y + min_margin):
		for x in range(min_x - min_margin, max_x + min_margin):
			var pos = Vector2i(x, y)
			set_terrain_cell(pos, filling_terrain)
				
func generate_walls() -> void:
	var added_floor_cells = []
	for pos in floor_cells:
		var above_pos = pos + Vector2i.UP
		var above_wall_pos = above_pos + Vector2i.UP
		
		# If the tile above is within bounds and not already a floor tile
		if is_within_bounds_for_walls(above_pos) and is_within_bounds_for_walls(above_wall_pos):
			if not above_pos in floor_cells and not above_pos in added_floor_cells:
				if not above_wall_pos in floor_cells and not above_wall_pos in added_floor_cells:
					set_terrain_cell(above_pos, wall_terrain)
					wall_cells.append(above_pos)
				else:
					# If the tile above is a floor tile, make the current tile also a floor
					set_terrain_cell(pos, floor_terrain)
					set_terrain_cell(above_pos, floor_terrain)
					added_floor_cells.append(pos)
					added_floor_cells.append(above_pos)
					
	floor_cells.append_array(added_floor_cells)
	
func generate_floor():
	spawn_first_walker()
	
	var i = 0
	
	while floor_cells.size() < max_tile:
		var walkers_to_remove = []
		
		for walker in current_walkers:
			if floor_cells.size() < max_tile:
				i += 1
				print(i)
				if randf() < walker_death_chance / current_walkers.size() and current_walkers.size() > 1:
					walkers_to_remove.append(walker)
				else:
					move_walker(walker)
		
		for walker in walkers_to_remove:
			current_walkers.erase(walker)
		
		if randf() < walker_spawn_chance and current_walkers.size() < max_walkers:
			var new_walker = create_walker(current_walkers.pick_random().position)
			current_walkers.append(new_walker)

func spawn_first_walker() -> void:
	var center = Vector2i.ZERO
	var walker = create_walker(center)
	current_walkers.append(walker)
	carve_floor(walker)


func carve_floor(walker: Walker) -> void:
	for pos in walker.positions():
		if is_within_bounds(pos):
			set_terrain_cell(pos, floor_terrain)
			if pos not in floor_cells:
				floor_cells.append(pos)

func move_walker(walker: Walker) -> void:
	# Check if we should change direction
	walker.move(change_direction_chance, min_x, max_x, min_y, max_y)
	# If using a list of walkers, update the walker in the list
	current_walkers[current_walkers.find(walker)] = walker
	carve_floor(walker)

func set_terrain_cell(pos: Vector2i, terrain: int) -> void:
	tile_map.set_cell(0, pos, 0, Vector2i.ZERO, terrain_set)
	tile_map.set_cells_terrain_connect(0, [pos], terrain_set, terrain)

func is_within_bounds(pos: Vector2i) -> bool:
	return pos.x >= min_x and pos.x < max_x and pos.y >= min_y and pos.y < max_y

func is_within_bounds_for_walls(pos: Vector2i) -> bool:
	return pos.x >= min_x - min_margin and pos.x < max_x + min_margin and pos.y >= min_y - min_margin and pos.y < max_y + min_margin

func _process(delta: float) -> void:
	pass  # You can remove this function if you don't need per-frame updates

func create_walker(position: Vector2) -> Walker:
	return Walker.new(position, randi_range(min_walker_thickness, max_walker_thickness))

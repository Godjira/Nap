extends Node2D

class_name SpriteCreator

# Preload the image you want to use
@export var sprite_texture: Texture2D

func create_sprite_at_position(position: Vector2) -> Sprite2D:
	var sprite = Sprite2D.new()
	sprite.texture = sprite_texture
	sprite.position = position
	sprite.scale = Vector2(0.1, 0.1)  # Set the scale
	add_child(sprite)
	return sprite

func create_sprite_at_tile(tile_pos: Vector2i, tilemap: TileMap) -> Sprite2D:
	var world_pos = tilemap.map_to_local(tile_pos)
	return create_sprite_at_position(world_pos)

# Example usage
func _ready():
	if not sprite_texture:
		push_error("Sprite texture not set!")
		return
	
	# Create a sprite at a specific world position
	var world_sprite = create_sprite_at_position(Vector2(100, 100))
	print("Sprite created at world position: ", world_sprite.position)
	
	# If you're using a TileMap, you can create a sprite at a tile position
	var tilemap = get_node_or_null("../TileMap")  # Adjust this path to your TileMap
	if tilemap:
		var tile_sprite = create_sprite_at_tile(Vector2i(5, 3), tilemap)
		print("Sprite created at tile position: ", tilemap.local_to_map(tile_sprite.position))

# Optional: Add method to create multiple sprites
func create_sprites_at_positions(positions: Array[Vector2]) -> Array[Sprite2D]:
	var sprites: Array[Sprite2D] = []
	for pos in positions:
		sprites.append(create_sprite_at_position(pos))
	return sprites

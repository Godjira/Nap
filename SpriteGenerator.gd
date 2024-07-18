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

# Optional: Add method to create multiple sprites
func create_sprites_at_positions(positions: Array[Vector2]) -> Array[Sprite2D]:
	var sprites: Array[Sprite2D] = []
	for pos in positions:
		sprites.append(create_sprite_at_position(pos))
	return sprites

extends Control

@onready var sub_viewport := $SubViewportContainer/SubViewport
@onready var texture_rect := $TextureRect
@onready var player_marker := $SubViewportContainer/SubViewport/PlayerMarker
@onready var camera := $SubViewportContainer/SubViewport/Camera2D
var minimap_texture: ViewportTexture
var mask_texture: ImageTexture
var player: Character0

func _ready():
	minimap_texture = sub_viewport.get_texture()
	var tile_map = sub_viewport.get_node("TileMap") as TileMap
	var tile_map_size = Vector2(tile_map.get_used_rect().size.x * 16, tile_map.get_used_rect().size.y * 16)
	
	var mask_image = Image.create(1000, 1000, false, Image.FORMAT_RGBA8)
	mask_image.fill(Color(0, 0, 0, 1))  # Start with a black (unexplored) mask
	mask_texture = ImageTexture.create_from_image(mask_image)
	texture_rect.material.set_shader_parameter("mask_texture", mask_texture)

func _physics_process(delta):
	if player:
		update_mask()

func attach_player(p: Character0) -> void:
	self.player = p
	sub_viewport.player = p

func update_mask():
	var mask_image = mask_texture.get_image()
	var reveal_radius = 30  # Adjust as needed
	var pos_x = player_marker.global_position.x + 660
	var pos_y = player_marker.global_position.y + 660
	
	for x in range(-reveal_radius, reveal_radius + 1):
		for y in range(-reveal_radius, reveal_radius + 1):
			if x*x + y*y <= reveal_radius*reveal_radius:
				var _pos_x = int(pos_x + x)
				var _pos_y = int(pos_y + y)
				if _pos_x >= 0 and _pos_x < mask_image.get_width() and _pos_y >= 0 and _pos_y < mask_image.get_height():
					mask_image.set_pixel(_pos_x, _pos_y, Color(0, 0, 0, 0))  # Set to transparent (explored)
	
	mask_texture.update(mask_image)
	texture_rect.material.set_shader_parameter("mask_texture", mask_texture)

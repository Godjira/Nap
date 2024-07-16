extends Node2D

@onready var tileMap = $TileMap
@onready var spriteGen = $SpriteGen

# Called when the node enters the scene tree for the first time.
func _ready():
	var script = spriteGen.get_script()
	var cells = tileMap.get_used_cells_by_id(0, 0, Vector2i(0, 5))
	for pos in cells:
		spriteGen.create_sprite_at_position(tileMap.to_global(tileMap.map_to_local(pos)))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

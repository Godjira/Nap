extends StaticBody2D
@export var item : InventoryItem
var original_pos := Vector2.ZERO
var offset := Vector2.ZERO
@onready var sprite := $Sprite2D

func _ready():
	original_pos = sprite.global_position

func _process(delta):
	sprite.global_position = lerp(sprite.global_position, original_pos + Vector2.UP * randf(), 0.1)

func _on_interactable_area_body_entered(body):
	if body.is_in_group("Player"):
		body.collect(item, 1)
		await get_tree().create_timer(0.1).timeout
		queue_free()

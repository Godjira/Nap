extends StaticBody2D
@export var item : InventoryItem
var original_pos := Vector2.ZERO
var offset := Vector2.ZERO
@onready var sprite := $Sprite2D
@onready var delay_timer := $DelayTimer
var disabled := false
var amount := 1

func _ready():
	original_pos = sprite.global_position
	$Sprite2D.texture = item.texture

func _process(delta):
	sprite.global_position = lerp(sprite.global_position, original_pos + Vector2.UP * randf(), 0.1)

func _on_interactable_area_body_entered(body):
	if body.is_in_group("Player") and not disabled:
		body.collect(item, amount)
		await get_tree().create_timer(0.1).timeout
		queue_free()


func _on_delay_timer_timeout():
	disabled = false

extends Area2D

@export var speed := 400.0
@export var rotation_speed := 10.0
var velocity := Vector2.ZERO
@onready var sprite := $AmmoTexture
var initial_position:Vector2
var weapon_item:WeaponItem
var is_already_make_damage := false
var add_damage_display:Callable
var damage_scene := preload("res://characters/mob_damage.tscn")

func _ready() -> void:
	# Ensure the sprite is pointing to the right initially
	sprite.rotation = 0
	position = initial_position

func _physics_process(delta: float) -> void:
	# Move the arrow
	position +=  velocity * delta
	
	# Rotate the arrow to face its movement direction
	if velocity != Vector2.ZERO:
		var target_rotation = velocity.angle() + PI/2
		# Use rotation_speed to smoothly rotate the sprite
		sprite.rotation = target_rotation

func shoot(direction: Vector2) -> void:
	velocity = direction.normalized() * speed
	# Immediately set the correct rotation when shooting
	if sprite: sprite.rotation = velocity.angle()

func _on_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body.is_in_group("Enemy") and weapon_item and not is_already_make_damage:
		var damage_scene_instance = damage_scene.instantiate()
		add_child(damage_scene_instance)
		damage_scene_instance.set_damage(weapon_item.damage)
		damage_scene_instance.global_position = body.global_position
		body.on_hit(weapon_item.damage)
		is_already_make_damage = true
		queue_free()


func _on_life_span_timeout():
	queue_free()

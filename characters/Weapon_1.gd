extends Node2D

@export var player: CharacterBody2D
@onready var weapon_sprite := $Sprite2D
@onready var attack_timer := $"AttackTimer"
var item: WeaponItem
var initial_position: Vector2
var initial_rotation: float
var is_attacking := false
var attack_direction := Vector2.ZERO
var ammo_sprite_texture:Texture2D
var can_make_attack := true
var damage_scene := preload("res://characters/mob_damage.tscn")

func _ready():
	initial_position = position
	initial_rotation = rotation

func set_texture_for_weapon(t:Texture2D):
	weapon_sprite.texture = t

func set_texture_for_ammo(t:Texture2D):
	ammo_sprite_texture = t

func _process(delta):
   # Trigger attack animation
	if item and item.weapon_type != item.Types.RANGE:
		#  get the global mouse position but max distance is 10
		global_position.x = clamp(get_global_mouse_position().x, player.global_position.x - 20, player.global_position.x + 20)
		global_position.y = clamp(get_global_mouse_position().y, player.global_position.y - 20, player.global_position.y + 20)
		$Sprite2D.scale = lerp($Sprite2D.scale, Vector2(0.4, 0.4), delta)
	elif item:
		global_position = player.global_position
		$Sprite2D.scale = lerp($Sprite2D.scale, Vector2(0.25, 0.25), delta)
		#rotate(global_position.angle() + PI/2)
	  	# Get the mouse position in global coordinates
		var mouse_pos = get_global_mouse_position()
		
		# Calculate the direction from the bow to the mouse
		var direction = (mouse_pos - global_position).normalized()
		
		# Calculate the angle to the mouse position
		var target_angle = direction.angle()
		
		var rotation_speed = 10.0
		
		# Smoothly rotate the bow sprite towards the target angle
		weapon_sprite.rotation = lerp_angle(weapon_sprite.rotation, target_angle, rotation_speed * delta)
		
		# Flip the sprite vertically if aiming to the left
		if abs(target_angle) > PI/2:
			weapon_sprite.flip_v = true
		else:
			weapon_sprite.flip_v = false
		
	if Input.is_action_just_pressed("attack") and !is_attacking:
		perform_attack()

func update_weapon_position():
	initial_position = position

@onready var arrow = preload("res://items/arrow_area.tscn")

func perform_attack():
	if not can_make_attack: return
	can_make_attack = false
	attack_timer.start()
	is_attacking = true
	if item and item.weapon_type == item.Types.RANGE:
		var arrow_scene = arrow.instantiate()
		arrow_scene.initial_position = position
		arrow_scene.weapon_item = item
		arrow_scene.get_node("AmmoTexture").texture = ammo_sprite_texture
		arrow_scene.shoot(attack_direction)
		add_child(arrow_scene)
	else:
		# Calculate the end position for the slide attack
		var start_pos = position
		var tween2 = get_tree().create_tween()
		tween2.tween_property(self, "rotation", initial_rotation + rotation + PI * 2 , 0.25)
		# Reset the attacking state after the animation is complete
		await tween2.finished
	
	is_attacking = false

func set_attack_direction(dir:Vector2) -> void:
	attack_direction = dir
	
func add_damage_display(body:Node2D):
	var damage_scene_instance = damage_scene.instantiate()
	damage_scene_instance.posiition = body.position
	damage_scene_instance.set_damage(item.damage)
	add_child(damage_scene_instance)

func _on_attack_body_entered(body):
	if body.is_in_group("Enemy") and is_attacking and not body.is_dead and item:
		#add_damage_display(body)
		body.on_hit(item.damage)


func _on_attack_timer_timeout():
	can_make_attack = true

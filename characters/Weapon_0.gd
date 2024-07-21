extends Node2D

@export var player: CharacterBody2D
@export var shake_amount: float = 1.0
@export var shake_speed: float = 20.0
@export var rotation_speed: float = 5.0
@export var attack_shake_amount: float = 5.0
@export var attack_shake_duration: float = 0.2

@onready var weapon_sprite := $Sprite2D

var initial_position: Vector2
var shake_time: float = 0.0
var is_attacking: bool = false
var attack_shake_timer: float = 0.0

func _ready():
	initial_position = weapon_sprite.position

func _process(delta):
	if player:
		# Weapon rotation based on player movement
		var movement = player.velocity.normalized()
		#if movement != Vector2.ZERO:
			#var target_rotation = movement.angle()
			#weapon_sprite.rotation = lerp_angle(rotation, target_rotation, rotation_speed * delta)
		if movement.x == -1 and movement.y == 0:
			global_position.x = player.global_position.x - 18
		if movement.x == 1 and movement.y == 0:
			global_position.x = player.global_position.x

		# Weapon shaking based on player movement
		shake_time += delta * shake_speed
		var shake_offset = Vector2(sin(shake_time), cos(shake_time * 0.8)) * shake_amount * min(player.velocity.length() / 100, 1)
		weapon_sprite.position = initial_position + shake_offset

		# Weapon shaking during attack
		if is_attacking:
			attack_shake_timer -= delta
			weapon_sprite.rotation+=rotation*0.1
			if attack_shake_timer > 0:
				var attack_shake_offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * attack_shake_amount
				weapon_sprite.position += attack_shake_offset
			else:
				is_attacking = false

func trigger_attack():
	is_attacking = true
	attack_shake_timer = attack_shake_duration

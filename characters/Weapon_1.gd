extends Node2D

@export var player: CharacterBody2D
@onready var weapon_sprite := $Sprite2D

var initial_position: Vector2
var initial_rotation: float
var shake_time := 0.0
var is_attacking := false
var attack_shake_timer := 0.0
var attack_shake_duration := .5
var attack_direction := Vector2.ZERO

# Weapon properties
@export var weapon_offset := Vector2(10, 0)
@export var attack_duration := 0.3
@export var slide_distance := 10
# Current state
var current_position := "right"

func _ready():
	initial_position = position
	initial_rotation = rotation

func _process(delta):
   # Trigger attack animation
	#  get the global mouse position but max distance is 10
	global_position.x = clamp(get_global_mouse_position().x, player.global_position.x - 20, player.global_position.x + 20)
	global_position.y = clamp(get_global_mouse_position().y, player.global_position.y - 20, player.global_position.y + 20)
	if Input.is_action_just_pressed("attack") and !is_attacking:
		perform_attack()

func update_weapon_position(new_position):
	current_position = new_position
	initial_position = position

func perform_attack():
	is_attacking = true
	
	# Calculate the end position for the slide attack
	var start_pos = position
	var tween2 = get_tree().create_tween()
	tween2.tween_property(self, "rotation", initial_rotation + rotation + PI * 2 , 0.25)
	
	# Reset the attacking state after the animation is complete
	await  tween2.finished
	is_attacking = false

func set_attack_direction(dir:Vector2) -> void:
	attack_direction = dir


func _on_attack_body_entered(body):
	pass # Replace with function body.

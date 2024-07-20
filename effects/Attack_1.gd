extends AnimatedSprite2D

var is_attacking = false
var attack_direction = Vector2.RIGHT  # Default attack direction
var attack_distance = 10  # Distance the sprite moves during attack
var attack_speed = 200  # Speed of the attack movement
var return_speed = 0  # Speed of returning to original position

var original_position = Vector2.ZERO
var target_position = Vector2.ZERO

func _ready():
	original_position = position
	hide()

func _process(delta):
	if Input.is_action_just_pressed("attack") and not is_attacking:
		perform_slash_attack()
	
	if is_attacking:
		position = position.move_toward(target_position, attack_speed * delta)
		if position.is_equal_approx(target_position):
			is_attacking = false
	else:
		position = position.move_toward(original_position, return_speed * delta)

func perform_slash_attack():
	is_attacking = true
	target_position = original_position + attack_direction * attack_distance
	var tween = get_tree().create_tween()
	scale = Vector2.ZERO
	tween.tween_property(self, "scale", Vector2(0.05, 0.05), 0.1)
	# rotate the sprite to face the attack direction
	rotation = atan2(attack_direction.y, attack_direction.x) + PI * 0.5

func set_attack_direction(direction: Vector2):
	attack_direction = direction.normalized()
	show()
	$EffectTimer.start()


func _on_effect_timer_timeout():
	hide()
	pass # Replace with function body.

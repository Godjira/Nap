extends Mob0
@onready var sprite_mob_2 = $AnimatedSprite2D

func _init():
	attack_timer = $"AttackTimer"

func _ready() -> void:
	initialize_health()
	initialize_position()
	damage = 2.5

func _physics_process(delta: float) -> void:
	if !player or is_dead: return
	
	sensor_distance.from_vector = global_position
	sensor_distance.to_vector = player.global_position 
	
	# Update the AI.
	$UtilityAIAgent.evaluate_options(delta)
	# Move based on movement speed.
	if global_position.distance_to(player.global_position) < attack_area_radius:
		pass
	else:
		self.velocity = -sensor_distance.direction_vector * speed
	move_and_slide()
	
	# Flip the sprite horizontally based on the direction vector horizontal (x)
	# value.
	sprite_mob.flip_h = (sensor_distance.direction_vector.x < 0)
	# If the movement speed is negative, the entity is moving away so
	# we should flip the sprite again.
	if speed < 0.0:
		sprite_mob.flip_h = !sprite_mob.flip_h

func initialize_health() -> void:
	health = max_health
	health_bar.max_value = max_health
	health_bar.value = health

func initialize_position() -> void:
	base_position = global_position

func handle_hit() -> void:
	if is_dead:
		return
	sprite_mob.play("attack")
	$Attack0.run_effect()
	player.on_hit(damage)
	#anim_state.travel(ATTACK_ANIMATIONS.pick_random())

func on_hit(damage: float) -> bool:
	if is_dead:
		return false

	sprite_mob.play("hit")
	$Attack0.run_effect()
	health -= damage
	health_bar.value = health
	var is_dead_now:bool = health <= 0

	if is_dead_now:
		die()
		return is_dead_now
	else:
		await get_tree().create_timer(1.0).timeout
		sprite_mob.play("default")

	return is_dead_now


func die() -> void:
	is_dead = true
	sprite_mob_2.play("deth")
	sprite_mob_2.texture_repeat = CanvasItem.TEXTURE_REPEAT_DISABLED
	current_state = State.DEAD
	for index in [1, 2, 4]:
		set_collision_mask_value(index, false)
		set_collision_layer_value(index, false)
	z_index = 0
	deth_timer.start()
	await get_tree().create_timer(1.0).timeout
	sprite_mob_2.stop()
	if item:
		var node = item_collectable.instantiate()
		node.item = item
		node.global_position = global_position
		get_tree().current_scene.add_child(node)
	queue_free()

func _on_mob_sensor_body_entered(body: CharacterBody2D) -> void:
	if body.is_in_group("Player"):
		idle_timer.stop()
		player = body
		current_state = State.SURROUND

func _on_mob_sensor_body_exited(body: CharacterBody2D) -> void:
	if body.is_in_group("Player"):
		idle_timer.start()

func _on_idle_timer_timeout() -> void:
	if not is_dead:
		current_state = State.IDLE


func _on_deth_timer_timeout():
	if item:
		var node = item_collectable.instantiate()
		node.item = item
		node.global_position = global_position
		get_tree().current_scene.add_child(node)
	queue_free()


func _on_attack_timer_timeout():
	handle_hit()


func _on_utility_ai_agent_behaviour_changed(behaviour_node):
	if behaviour_node == null:
		return

	#if behaviour_node.name == "Approach":
		#speed -= 50
		#sprite_mob_2.play("default")
	#elif behaviour_node.name == "Flee":
		#speed += 20
		#sprite_mob_2.play("default")
	#elif behaviour_node.name == "Attack":
	if behaviour_node.name == "Wait":
		speed = 0
	sprite_mob_2.play("default")
		



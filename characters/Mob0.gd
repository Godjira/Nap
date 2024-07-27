extends CharacterBody2D
class_name Mob0

# Enums
enum State { SURROUND, HIT, IDLE, DEAD }

# Export variables for easy tuning
@export var speed := 50.2
@export var attack_area_radius := 10
@export var max_health := 10.0
@export var damage := 3.0
@export var avoidance_distance := 1.0
@export var avoidance_force := 2.0

@export var item: InventoryItem
@onready var item_collectable: PackedScene = load("res://items/item_collactable.tscn")

# Onready variables
@onready var sprite_mob := $AnimatedSprite2D as AnimatedSprite2D
@onready var attack_timer := $AttackTimer
@onready var health_bar := $HelthsBar
@onready var idle_timer := $IdleTimer
@onready var deth_timer := $DethTimer

# This is the distance sensor. 
@onready var sensor_distance:UtilityAIDistanceVector2Sensor = $UtilityAIAgent/UtilityAIDistanceVector2Sensor


# Member variables
var dangers := [0, 0, 0, 0, 0, 0, 0, 0]
var player: Character0
var is_dead := false
var base_position: Vector2
var current_state
var health = 10
var is_active := false

func _ready() -> void:
	initialize_health()
	initialize_position()

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

func on_hit(damage: float) -> void:
	if is_dead:
		return
	

	sprite_mob.play("take_hit")
	$Attack0.run_effect()
	health -= damage
	
	await get_tree().create_timer(0.5).timeout
	sprite_mob.play("default")

	if health <= 0:
		die()

	animate_hit()
	health_bar.value = health

	

func animate_hit() -> void:
	var tween = create_tween()
	tween.tween_property(sprite_mob.material, "shader_parameter/hit_intesity", 0.5, 0.3)
	tween.tween_property(sprite_mob.material, "shader_parameter/hit_intesity", 0.0, 0.3)

func die() -> void:
	sprite_mob.play("deth")
	current_state = State.DEAD
	for index in [1, 2, 4]:
		set_collision_mask_value(index, false)
		set_collision_layer_value(index, false)
	z_index = 0
	is_dead = true
	deth_timer.start()
	await get_tree().create_timer(0.25).timeout
	sprite_mob.stop()

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
	pass # Replace with function body.


func _on_visible_on_screen_notifier_2d_screen_entered():
	is_active = true


func _on_visible_on_screen_notifier_2d_screen_exited():
	is_active = false

func _on_utility_ai_agent_behaviour_changed(behaviour_node):
	if behaviour_node == null:
		return
	print("behavior_node", behaviour_node.name)
	
	if behaviour_node.name == "Approach":
		speed -= 50
		sprite_mob.play("run")
	elif behaviour_node.name == "Flee":
		#speed += 50
		sprite_mob.play("run")
		pass
	else:
		speed = 0
		sprite_mob.play("default")


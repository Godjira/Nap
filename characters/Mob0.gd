extends CharacterBody2D
class_name Mob0

# Constants
const ATTACK_ANIMATIONS = [
	"1h_slice_diagonal",
	"1h_slice_horizontal",
	"1h_attack_chop"
]

var ALL_DIRECTIONS := [
	Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN,
	Vector2(1, 1).normalized(), Vector2(1, -1).normalized(),
	Vector2(-1, 1).normalized(), Vector2(-1, -1).normalized()
]

# Enums
enum State { SURROUND, HIT, IDLE, DEAD }

# Export variables for easy tuning
@export var speed := 35
@export var attack_area_radius := 10
@export var max_health := 10.0
@export var damage := 1.0
@export var jump_speed := 8.0
@export var avoidance_distance := 1.0
@export var avoidance_force := 10.0

# Onready variables
@onready var sub_viewport := $SubViewport
@onready var sprite_texture := $Sprite2D
@onready var attack_timer := $AttackTimer
@onready var health_bar := $HelthsBar
@onready var idle_timer := $IdleTimer
@onready var deth_timer := $DethTimer

# Member variables
var dangers := [0, 0, 0, 0, 0, 0, 0, 0]
var anim_state: AnimationNodeStateMachinePlayback
var anim_tree: AnimationTree
var model: Node3D
var camera_3D: Camera3D
var player: Character0
var velocity_sub_viewport := Vector3.ZERO
var is_dead := false
var base_position: Vector2
var current_state = State.IDLE
var health = 10

func _ready() -> void:
	initialize_viewport()
	initialize_health()
	initialize_position()

func _physics_process(delta: float) -> void:
	if current_state == State.DEAD:
		return

	apply_avoidance()
	update_rotation()

	match current_state:
		State.IDLE:
			move_to_idle(delta)
		State.SURROUND:
			move_towards_player(delta)
		State.HIT:
			pass  # Handle hit state if needed

func initialize_viewport() -> void:
	var character_model = sub_viewport.get_children()[0]
	model = character_model.get_node("Rig")
	camera_3D = character_model.get_node("Camera")
	anim_tree = character_model.get_node("AnimationTree")
	anim_state = anim_tree.get('parameters/playback')

	var anim_player = character_model.get_node("AnimationPlayer")
	for animation in anim_player.get_animation_list():
		if "Idle" in animation or "Walking" in animation or "Running" in animation:
			anim_player.get_animation(animation).loop = true

func initialize_health() -> void:
	health = max_health
	health_bar.max_value = max_health
	health_bar.value = health

func initialize_position() -> void:
	base_position = global_position

func move_towards_player(delta: float) -> void:
	if is_dead or not player:
		return

	var direction = (player.global_position - global_position).normalized()
	var desired_velocity = direction * speed
	velocity = velocity.move_toward(desired_velocity, delta * speed)
	move_and_slide()

func move_to_idle(delta: float) -> void:
	if is_dead:
		return

	var direction = (base_position - global_position).normalized()
	velocity = velocity.move_toward(direction * speed, delta * speed * 2.5)
	move_and_slide()

func update_rotation() -> void:
	var target = player.global_position if player else base_position
	model.rotation.y = atan2(-velocity.x, -velocity.y)
	anim_tree.set("parameters/IWR/blend_position", velocity_sub_viewport * model.transform.basis)

func apply_avoidance() -> void:
	#var space_state = get_world_2d().direct_space_state
	#for direction in ALL_DIRECTIONS:
		#var query = PhysicsRayQueryParameters2D.create(global_position, global_position + direction * avoidance_distance)
		#query.collision_mask = 0b111  # Adjust this mask to match your collision layers
		#var result = space_state.intersect_ray(query)
		#if result:
			#velocity += direction * avoidance_force * (1.0 - result.position.distance_to(global_position) / avoidance_distance)
	pass

func handle_hit() -> void:
	if is_dead:
		return

	$Attack0.run_effect()
	player.on_hit(damage)
	anim_state.travel(ATTACK_ANIMATIONS.pick_random())

func on_hit(damage: float) -> void:
	if is_dead:
		return

	$Attack0.run_effect()
	health -= damage
	animate_hit()
	health_bar.value = health

	if health <= 0:
		die()

func animate_hit() -> void:
	var tween = create_tween()
	tween.tween_property(sprite_texture.material, "shader_parameter/hit_intesity", 0.5, 0.3)
	tween.tween_property(sprite_texture.material, "shader_parameter/hit_intesity", 0.0, 0.3)

func die() -> void:
	anim_state.travel("Death_A")
	anim_tree.set("parameters/conditions/running", false)
	anim_tree.set('parameters/conditions/live', false)
	current_state = State.DEAD
	for index in [1, 2, 4]:
		set_collision_mask_value(index, false)
		set_collision_layer_value(index, false)
	z_index = 0
	is_dead = true
	deth_timer.start()

func _on_mob_sensor_body_entered(body: CharacterBody2D) -> void:
	if body.is_in_group("Player"):
		idle_timer.stop()
		player = body
		current_state = State.SURROUND

func _on_mob_sensor_body_exited(body: CharacterBody2D) -> void:
	if body.is_in_group("Player"):
		idle_timer.start()

func _on_mob_sensor_area_entered(area: Area2D) -> void:
	if not area.has_method("get_collision_mask"):
		return

	for i in range(ALL_DIRECTIONS.size()):
		dangers[i] = 0
		for index in [1, 2, 4]:
			if area.get_collision_mask_value(index) and area.get_collision_layer_value(index):
				dangers[i] = 5
				break
		if dangers[i] == 0:
			var closest_direction_index = get_closest_direction_index(ALL_DIRECTIONS[i])
			dangers[closest_direction_index] = 2

func get_closest_direction_index(direction: Vector2) -> int:
	var max_dot = -1
	var closest_index = 0
	for i in range(ALL_DIRECTIONS.size()):
		var dot = ALL_DIRECTIONS[i].dot(direction)
		if dot > max_dot:
			max_dot = dot
			closest_index = i
	return closest_index

func _on_idle_timer_timeout() -> void:
	if not is_dead:
		current_state = State.IDLE


func _on_deth_timer_timeout():
	queue_free()


func _on_attack_timer_timeout():
	handle_hit()
	pass # Replace with function body.

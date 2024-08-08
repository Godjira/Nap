extends CharacterBody2D
class_name Mob1
#
## Variables from current context
@onready var sprite_texture := $Sprite2D
@onready var attack_timer := $AttackTimer

@onready var skill_0 : Skill0 = $Skill0


var all_directions : Array[Vector2] =[Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN, 
					  Vector2(1, 1).normalized(), Vector2(1, -1).normalized(), 
					  Vector2(-1, 1).normalized(), Vector2(-1, -1).normalized()]
# for avoiding collision tails
var dangers : Array[int] = [0,0,0,0,0,0,0,0]

# Controls
var model : Node3D 
var player: Character0
var target: Vector2
var attack_happens := false
@export var damage := 1.5
var helths  := 15.0
@export var max_helths := 15.0
var is_dead := false
var base_position: Vector2
var idle_timer: Timer
@export var speed := 35
@export var avoidance_distance := 1
@export var avoidance_force := 10
@export var item:InventoryItem

enum {
	SURROUND,
	HIT,
	IDLE,
	DEAD,
	FIRE
}

var current_state := IDLE

func move(target: Vector2, delta: float) -> void:
	if is_dead: return
	var direction = (target - global_position).normalized()
	var desired_velocity = direction * speed
	var steering = (desired_velocity - velocity) * delta
	velocity += steering
	move_and_slide()

	
func move_to_idle(delta:float) -> void:
	if is_dead: return
	# get difference between target and current positionsa
	var direction = (base_position - global_position).normalized()
	# get steering
	var steering = (direction - velocity) * delta * 2.5
	# add steering to velocity
	velocity += steering
	# move and slide
	move_and_slide()
	
func pick_rotation():
	if player:
		# Calculate direction to player
		var direction := player.global_position - global_position
		# Calculate angle to player
		var angle_to_player := direction.angle()
		# Set the rotation
		$Sprite2D.rotation = angle_to_player
	else:
		# If no player is found, rotate randomly
		rotation = randf_range(0, 2 * PI)
	
func apply_avoidance() -> void:
	var space_state = get_world_2d().direct_space_state
	for i in range(all_directions.size()):
		var direction := all_directions[i]
		var query := PhysicsRayQueryParameters2D.create(global_position, global_position + direction * avoidance_distance)
		query.collision_mask = 0b01  # Adjust this mask to match your collision layers
		var result := space_state.intersect_ray(query)
		if result:
			velocity += direction * avoidance_force * (1.0 - result.position.distance_to(global_position) / avoidance_distance)

	
func _physics_process(delta:float) -> void:
	if current_state == DEAD or is_dead:
		return
	else: if current_state == IDLE:
			move_to_idle(delta)
	else: if current_state == HIT:
		return
	else:
		pick_direction_move(delta)
	apply_avoidance()	
	#update 3d inside sprite texture
	pick_rotation()

func pick_direction_move(delta:float) -> void:
	if is_dead : return

	# get current position
	var current_position := global_position
	# get vector towards player
	var direction : Vector2
	if player:
		direction = (player.global_position - current_position).normalized()
	else:
		direction = (base_position - current_position).normalized()
	# get local towards player
	var local_direction = transform.affine_inverse().basis_xform(direction)
	if player:
		move(player.global_position * 0.9, delta)

func _ready() -> void:
	# Because we use SubViewport node needs to get that from inner context
	base_position = global_position
	$HelthsBar.max_value = max_helths
	$HelthsBar.value = helths
	
func _on_attack_timer_timeout():
	if not is_dead: 
		print("Mob start attack")
		handle_hit()

func handle_hit() -> void:
	if not is_dead: 
		$Attack0.run_effect()
		player.on_hit(damage)

func on_hit(damage: float) -> bool:
	if not is_dead: 
		$Attack0.run_effect()
		self.helths =  self.helths - damage
		if self.helths < 0: self.helths = 0
		$HelthsBar.value = self.helths
		# death mob
		if self.helths == 0 and not is_dead:
			# play death animation
			current_state = DEAD
			# remove collision mask
			for index in [1, 2, 4]:
				set_collision_mask_value(index, false)
				set_collision_layer_value(index, false)
			var material := $Sprite2D.material as ShaderMaterial
			# change shader colors
			material.set_shader_parameter("is_dead", true)
			# partiles on top of the sprite
			$Attack0.z_index = 10
			var part := $Attack0.get_node("CPUParticles2D") as CPUParticles2D
			$Attack0.apply_scale(Vector2(5, 5))
			part.amount = 400
			part.one_shot = false
			part.speed_scale = 0.2
			part.emitting = true
			# run particle effect one more time
			
			self.z_index = 0
			is_dead = true# Replace with function body.
			var tween := get_tree().create_tween()
			tween.tween_property(self, "global_position", self.global_position * 0.9, 1.5)
			await tween.finished
			queue_free()
		return is_dead
	return false


func _on_mob_sensor_body_entered(body: CharacterBody2D) -> void:
	# start following mode
	if body.is_in_group("Player"):
		$IdleTimer.stop()
		player = body
		current_state = SURROUND

func _on_mob_sensor_body_exited(body: CharacterBody2D) -> void:
	# after a while return to idle pose
	if body.is_in_group("Player"):
		$IdleTimer.start()

func _on_mob_sensor_area_entered(area:Area2D):
	var mob_collision = get_collision_mask()
	var mob_layer = get_collision_layer()

func _process(delta:float) -> void:
	if current_state == FIRE and player:
		fireball()

func fireball() -> void:
	skill_0.run_skill(self, player.global_position)
	

func _on_idle_timer_timeout() -> void:
	if not is_dead:
		current_state = IDLE

func _on_area_2d_body_entered(body):
	if body.is_in_group("Player") and not is_dead:
		current_state = FIRE

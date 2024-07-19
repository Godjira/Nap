extends CharacterBody2D
class_name Mob0

# Variables from current context
@onready var sub_viewport := $SubViewport
@onready var sprite_texture := $Sprite2D
@onready var attack_timer := $AttackTimer

var all_directions : Array[Vector2] = [
	# 8 directions
	Vector2(1, 0),
	Vector2(1, 1),
	Vector2(0, 1),
	Vector2(-1, 1),
	Vector2(-1, 0),
	Vector2(-1, -1),
	Vector2(0, -1),
	Vector2(1, -1)
]
# for avoiding collision tails
var dangers : Array[int] = [0,0,0,0,0,0,0,0]

# Controls
var anim_state  = null
var anim_tree : AnimationTree = null
var model : Node3D = null
var camera_3D :Camera3D = null
var jump_speed := 8.0
var player: Character0
var target: Vector2
var velocity_sub_viewport := Vector3.ZERO
var attack_happens := false
var damage := 1.0
var helths  := 3.0
var max_helths := 3.0
var is_dead := false
var base_position: Vector2
var idle_timer: Timer
var speed := 20
var attack_area_radius := 20

var attacks : Array[String] = [
	"1h_slice_diagonal",
	"1h_slice_horizontal",
	"1h_attack_chop"
]

enum {
	SURROUND,
	HIT,
	IDLE,
	DEAD
}

var state := IDLE

func get_viewport_context() -> void:
	# Get all the child nodes of the sub_viewport.
	var childrenNodes = sub_viewport.get_children()
	var characterModel = childrenNodes[0]
	model = characterModel.get_node("Rig")
	camera_3D = characterModel.get_node("Camera")
	anim_tree = characterModel.get_node("AnimationTree")
	anim_state = anim_tree.get('parameters/playback')
	var anim_player = characterModel.get_node("AnimationPlayer")
	#Loop through each animation and set their loop property to true
	for animation in anim_player.get_animation_list():
		if animation.contains("Idle") or animation.contains("Walking") or animation.contains("Running"):
			anim_player.get_animation(animation).loop = true
	


func move(target: Vector2, delta: float) -> void:
	if is_dead: return
	var direction  = (target - global_position).normalized()
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
	
	
func _physics_process(delta:float) -> void:
	if state == DEAD:
		return
	else: if state == IDLE:
			move_to_idle(delta)
	else: if state == HIT:
		return
	else:
		pick_direction_move(delta)
		#update 3d inside sprite texture
	if player:
		var direction = velocity.angle_to(player.global_position)
		var vl = velocity_sub_viewport * model.transform.basis
		# rotate Y axis of 3d model
		model.rotation.y = atan2(-velocity.x, -velocity.y)	
		anim_tree.set("parameters/IWR/blend_position", vl)
	else: 
		var direction = velocity.angle_to(base_position)
		var vl = velocity_sub_viewport * model.transform.basis
		# rotate Y axis of 3d model
		model.rotation.y = atan2(-velocity.x, -velocity.y)	
		anim_tree.set("parameters/IWR/blend_position", vl)

func pick_direction_move(delta:float) -> void:
	if is_dead : return

	# get current position
	var current_position = global_position
	# get vector towards player
	var direction 
	if player:
		direction = (player.global_position - current_position).normalized()
		
	else:
		direction = (base_position - current_position).normalized()
	# get local towards player
	var local_direction = transform.affine_inverse().basis_xform(direction)
	# normalize local direction
	local_direction = local_direction.normalized()

	# get dot product
	var max_dot := -1
	var max_dot_index := 0
	var dot_products : Array[float] = []
	for i in range(all_directions.size()):
		var dot = all_directions[i].dot(local_direction)
		if dot > max_dot:
			dot_products.append(dot)
			max_dot = dot
			max_dot_index = i
	# get new direction
	var new_direction = all_directions[max_dot_index]
	# get new position
	var new_position = current_position + new_direction
	# check the distance between new position and player if player exists
	if player:
		var distance := new_position.distance_to(player.global_position)
		#print("distance", distance)
		if distance < attack_area_radius:
			# if distance is less than 50, move to the close position usin sin and cos
			var angle := atan2(player.global_position.y - current_position.y, player.global_position.x - current_position.x)
			var dir := Vector2(cos(angle), sin(angle))
			move(dir, delta)
		else:
			move(new_position, delta)
	else:
		# move to new position
		move(new_position, delta)

func _ready() -> void:
	# Because we use SubViewport node needs to get that from inner context
	get_viewport_context()
	base_position = global_position
	
func _on_attack_timer_timeout():
	if not is_dead: 
		print("Mob start attack")
		handle_hit()

func handle_hit() -> void:
	if not is_dead: 
		$Attack0.run_effect()
		player.on_hit(damage)
		anim_state.travel(attacks.pick_random())

func on_hit(damage: float) -> void:
	if not is_dead: 
		$Attack0.run_effect()
		self.helths = min(0, self.helths - damage)
		#start hit shader animation
		var tween := get_tree().create_tween()
		tween.tween_property(sprite_texture.material, "shader_parameter/hit_intesity", 0.5, 0.3)
		await tween.finished
		var tween2 := get_tree().create_tween()
		tween2.tween_property(sprite_texture.material, "shader_parameter/hit_intesity", 0.0, 0.3)
		await tween2.finished
		# death mob
		if self.helths <= 0:
			# play death animation
			anim_state.travel("Death_A")
			anim_tree.set("parameters/conditions/running", false)
			anim_tree.set('parameters/conditions/live', false)
			state = DEAD
			# remove collision mask
			for index in [1, 2, 4]:
				set_collision_mask_value(index, false)
				set_collision_layer_value(index, false)
			
			self.z_index = 0
			is_dead = true# Replace with function body.


func _on_mob_sensor_body_entered(body: CharacterBody2D) -> void:
	# start following mode
	if body.is_in_group("Player"):
		$IdleTimer.stop()
		player = body
		state = SURROUND

func _on_mob_sensor_body_exited(body: CharacterBody2D) -> void:
	# after a while return to idle pose
	if body.is_in_group("Player"):
		$IdleTimer.start()
		
		

func _on_mob_sensor_area_entered(area:Area2D):
	var mob_collision = get_collision_mask()
	var mob_layer = get_collision_layer()

	# check 8 directions and add highest number to dangers array
	var i := 0
	for direction in all_directions:
		dangers.insert(i, 0)
		# check if area is tile with high collision
		# if area don't have collision mask or layer return
		if not "get_collision_mask" in area:
			return

		for index in [1, 2, 4]:
			var have_col := area.get_collision_mask_value(index)
			var have_layer := area.get_collision_layer_value(index)
			# if new_collision & area.get_collision_layer() > 0:
			if have_col and have_layer:
				dangers.insert(i, 5)
			else:
			# get the closest direction
				var closest_direction := all_directions[i]
				var closest_direction_index := i
				var closest_direction_value := 0
				for j in range(all_directions.size()):
					if i != j:
						var dot := all_directions[j].dot(direction)
						if dot > closest_direction_value:
							closest_direction_value = dot
							closest_direction = all_directions[j]
							closest_direction_index = j
				# set danger to 2
				dangers.insert(closest_direction_index, 2)

var avoidance_distance := 10
var avoidance_force := 20

func _process(delta:float) -> void:
	# Move mob away from high collision area
	var high_collision_areas := get_tree().get_nodes_in_group("high_collision_tiles")
	for area in high_collision_areas:
		var direction_to_area := global_position.direction_to(area.global_position)
		
		if direction_to_area.length() < avoidance_distance: # avoidnace_distance is a constant that you define
			velocity -= direction_to_area.normalized() * avoidance_force # avoidance_force is a constant that you define
			

func _on_idle_timer_timeout() -> void:
	if not is_dead:
		state = IDLE

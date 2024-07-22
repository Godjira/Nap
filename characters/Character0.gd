extends CharacterBody2D
class_name Character0

# Signals
signal hit
signal died

# Controls
@export var speed := 80.0
@export var acceleration := 14.0
@export var jump_speed := 8.0
@export var mouse_sensitivity := 0.0015
@export var rotation_speed := 12.0
@export var ghost_node : PackedScene

@onready var weapon : Node2D = $Weapon_1
@onready var dash_timer := $DashTimer

var velocity_sub_viewport := Vector3()
var mobs_close : Array[CharacterBody2D] = []

# Global variables
static var anim_state  = null
static var anim_tree : AnimationTree = null
static var model : Node3D = null
static var camera_3D :Camera3D = null
var default_healths := 10
var helths := 10.0
var max_helths := 10.
var damage := 2.5
@export var active_weapon: WeaponItem = WeaponItem.new()
var attacking: bool
var is_dash_posible := true

enum State { SURROUND, HIT, IDLE, DEAD }

# Variables from current context
@onready var sub_viewport = $SubViewport
@onready var camera = $Camera2D
@onready var viewport_sprite = $ViewportSprite
@onready var particles = $GPUParticles2D
@export var inventory: Inventory

var jumping := false
var running := false

@onready var inventory_ui  := $"/root/PlayerUi/Inventory"
@onready var helths_material : ShaderMaterial = $"/root/PlayerUi/ParentControl/Helth/HelthTexture".material

func show_equipment() -> void:
	if active_weapon:
		if active_weapon.name.contains("Axe"):
			weapon = $Weapon_0
			weapon.show()
		if active_weapon.name.contains("Sword"):
			weapon = $Weapon_1
			weapon.show()

func _process(delta:float) -> void:
	#Pass data to helths shader
	if helths_material != null:
		helths_material.set_shader_parameter("health", 1.0 - ((max_helths - helths)/max_helths))


func _ready() -> void:
	# Set the player to the Equipment node
	$Equipment.player = self
	# Because we use SubViewport node needs to get that from inner context
	get_viewport_context()
	# Equip items
	show_equipment()

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
	var list_loop := ["Idle", "Walking", "Running", "idle", 'run', 'walk', "walk_backwords", "walk_01"]
	for animation in anim_player.get_animation_list():
		# anim_player.get_animation(animation).loop = true
		var an = anim_player.get_animation(animation) as Animation
		an.loop_mode = false
		for anim_name in list_loop:
				if anim_name == animation:
					an.loop_mode = true

var attacks : Array[String] = [
	"1h_slice_diagonal",
	"1h_slice_horizontal",
	"1h_attack_chop"
]

func get_move_input(delta: float) -> void:
	if !camera_3D: return
	var direction = Input.get_vector("left", "right", "up", "down")
	# Handle movement
	# If the sprint key is pressed, set the speed to 120, otherwise set it to 80
	if Input.is_action_pressed('sprint'):
		speed = 150
		running = true
		# running animation
		anim_tree.set("parameters/conditions/running", running)
		anim_tree.set("parameters/conditions/not running", !running)
	else:
		speed = lerp(speed, 80., 0.1)
		running = false
		anim_tree.set("parameters/conditions/running", running)
		anim_tree.set("parameters/conditions/not running", !running)
		
	if direction:
		velocity = direction * speed * delta * 50
		var dir = Vector3(direction.x, 0, direction.y).rotated(Vector3.UP, camera_3D.rotation.y)
		velocity_sub_viewport = lerp(velocity_sub_viewport, dir * speed, acceleration * delta)
		var vl = velocity_sub_viewport * model.transform.basis
		anim_tree.set("parameters/IWR/blend_position", Vector2(vl.x, -vl.z) / speed)
	else:
		velocity = lerp(velocity, Vector2(0.0, 0.0), 0.1)
		velocity_sub_viewport = Vector3(0, velocity_sub_viewport.y, 0)
		anim_tree.set("parameters/IWR/blend_position", velocity)

func _physics_process(delta:float) -> void:
	get_move_input(delta)
	move_and_slide()
	# stop actions except moving
	if inventory_ui and inventory_ui.is_open: 
			return
	
	# handle attack
	if Input.is_action_just_pressed("attack"):
		attacking = true
		var mouse_dir := get_global_mouse_position()  - get_global_position()
		$Attack1.set_attack_direction(mouse_dir)
		# charater 3d animation
		if anim_state: anim_state.travel(attacks.pick_random())
		# sprite animation
		weapon.trigger_attack()
		# actual attack logic
		attack()

	if velocity.length() > 0.1:
		# Rotate the character model to the direction of movement
		var rot := model.rotation
		rot.y = lerp_angle(rot.y, atan2(-velocity.x, -velocity.y), rotation_speed * delta)
		model.rotation = rot
	# Handle jumping
	if Input.is_action_just_pressed("jump"):
		velocity_sub_viewport.y = jump_speed
		jumping = true
		anim_tree.set("parameters/conditions/jumping", true)
		anim_tree.set("parameters/conditions/grounded", false)
	# when Jump_Idle animation ends, set jumping to false
	if anim_state.get_current_node() == "Jump_Idle":
		jumping = false
		anim_tree.set("parameters/conditions/jumping", false)
		anim_tree.set("parameters/conditions/grounded", true)
	
	# handle dash
	if Input.is_action_just_pressed('dash'):
		dash()

func _unhandled_input(event: InputEvent) -> void:
	# rotate the character model on mouse move
	if event is InputEventMouseMotion:
		if !model: return
		var rot = model.rotation
		rot.y += event.relative.x * mouse_sensitivity
		model.rotation = rot

func start() -> void:
	show()

func _on_attack_body_entered(body:CharacterBody2D) -> void:
	if body.is_in_group("Enemy"):
		print("Mob in attack area", body)	
		body.current_state = State.HIT
		var timer = body.attack_timer as Timer
		if !timer.is_processing(): 
			timer.start()
		mobs_close.append(body)

func _on_attack_body_exited(body:CharacterBody2D) -> void:
	if body.is_in_group("Enemy"):
		print("Mob stop attack", body)
		body.current_state = State.SURROUND
		body.attack_timer.stop()
		mobs_close.erase(body)


func on_hit(damage:float) -> void:
	print("god damn they hit me!", damage)
	self.helths -= damage
	
	var effect = $"/root/PlayerUi/ParentControl/ColorRect" as damaged_effect
	effect.on_player_hit(damage, self.helths)
	
	#start hit shader animation
	var tween := get_tree().create_tween()
	tween.tween_property(viewport_sprite.material, "shader_parameter/hit_intesity", 0.5, 0.3)
	await tween.finished
	var tween2 := get_tree().create_tween()
	tween2.tween_property(viewport_sprite.material, "shader_parameter/hit_intesity", 0.0, 0.3)
	await tween2.finished
	
	if 	1.0 - ((max_helths - helths)/max_helths) <= 0:
		anim_state.travel("Death_A")
		anim_tree.set("parameters/conditions/running", false)
		anim_tree.set('parameters/conditions/live', false)
		$DiedTimer.start()

func attack() -> void:
	# check collision in attack area
	if mobs_close.size() > 0:
		for mob in mobs_close:
			mob.on_hit(self.damage)

func _on_died_timer_timeout() -> void:
	died.emit()
	$DiedTimer.stop()

func add_ghost() -> void:
	var ghost := ghost_node.instantiate()
	ghost.set_property(global_position, $ViewportSprite.scale)
	get_tree().current_scene.add_child(ghost)
	# pass data to shader
	var dash_direction := Vector2(velocity.x, velocity.y).normalized()
	ghost.material.set_shader_parameter("dash_direction", dash_direction)


func _on_ghost_timer_timeout() -> void:
	add_ghost()
		

func dash() -> void:
	if is_dash_posible:
		particles.emitting = true
		is_dash_posible = false
		$GhostTimer.start()
		dash_timer.start()
		
		var dash_duration := 0.20  # Duration of the dash in seconds
		var dash_distance := velocity * .5  # Total distance to dash
		var dash_start_pos := global_position
		var elapsed_time := 0.0
		anim_tree.set("parameters/conditions/dash", true)
		
		while elapsed_time < dash_duration:
			var delta := get_process_delta_time()
			elapsed_time += delta
			
			# Calculate the new position
			var t := elapsed_time / dash_duration
			var new_position := dash_start_pos.lerp(dash_start_pos + dash_distance, t)
			
			# Move and check for collision
			var collision := move_and_collide(new_position - global_position)
			if collision:
				# Handle collision (e.g., stop the dash, slide, or bounce)
				handle_dash_collision(collision)
				break
			
			await get_tree().process_frame
			anim_tree.set("parameters/conditions/dash", false)
		
		$GhostTimer.stop()
		particles.emitting = false

func handle_dash_collision(collision: KinematicCollision2D) -> void:
	# Implement your collision response here
	# For example, you might want to stop the dash, slide along the surface, or bounce
	print("Collided with: ", collision.get_collider().name)
	# You can access collision normal, collision point, etc. from the collision object


func _on_dash_timer_timeout() -> void:
	is_dash_posible = true

func collect(item: InventoryItem, amount: int) -> void:
	inventory.insert(item, amount or int(randf() * PI))

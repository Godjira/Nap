extends CharacterBody2D

class_name Character0
# Signals
signal hit
signal died

# Controls
@export var speed = 80.0
@export var acceleration = 14.0
@export var jump_speed = 8.0
@export var mouse_sensitivity = 0.0015
@export var rotation_speed = 12.0
@export var ghost_node : PackedScene

var velocity_sub_viewport = Vector3()
var mobs_close = []

# Global variables
static var anim_state = null
static var anim_tree = null
static var model = null
static var camera_3D = null
var last_floor = true
var default_healths = 10
var helths = 10.0
var max_helths = 10.
var damage = 2.5
var active_weapon
var attacking

# Variables from current context
@onready var sub_viewport = $SubViewport
@onready var camera = $Camera2D
@onready var viewport_sprite = $ViewportSprite
@onready var particles = $GPUParticles2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var jumping = false
var running = false

# Create rayscast from character to world
@export var raycasts = []
@export var lines = []
@onready var helths_material = $"/root/PlayerUi/ParentControl/Helth/HelthTexture".material as ShaderMaterial

func show_equipment():
	$Equipment.show_items()
	active_weapon = $Equipment.items[0]

func _process(delta):
	#Pass data to helths shader
	if helths_material != null:
		helths_material.set_shader_parameter("health", 1.0 - ((max_helths - helths)/max_helths))


func _ready():
	# Set the player to the Equipment node
	$Equipment.player = self
	# Because we use SubViewport node needs to get that from inner context
	get_viewport_context()
	# Equip items
	show_equipment()

func get_viewport_context():
	# Get all the child nodes of the sub_viewport.
	var childrenNodes = sub_viewport.get_children()
	# First childrent is 3d node with character model.
	var characterModel = childrenNodes[0]
	# get child Rig from the characterModel.
	model = characterModel.get_node("Rig")
	# get child Camera from the characterModel.
	camera_3D = characterModel.get_node("Camera")
	# get child AnimationTree from the characterModel.
	anim_tree = characterModel.get_node("AnimationTree")
	# get child AnimationPlayer from the characterModel.
	anim_state = anim_tree.get('parameters/playback')
	var anim_player = characterModel.get_node("AnimationPlayer")
	#Loop through each animation and set their loop property to true
	for animation in anim_player.get_animation_list():
		# anim_player.get_animation(animation).loop = true
		if animation.contains("Idle") or animation.contains("Walking") or animation.contains("Running"):
			anim_player.get_animation(animation).loop = true
		#print(animation)
	

var attacks = [
	"1h_slice_diagonal",
	"1h_slice_horizontal",
	"1h_attack_chop"
]

func get_move_input(delta):
	if !camera_3D: return
	var direction = Input.get_vector("left", "right", "up", "down")
	# Handle movement
	# If the sprint key is pressed, set the speed to 120, otherwise set it to 80
	if Input.is_action_pressed('sprint'):
		speed = lerp(speed, 120., 0.1)
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

func _physics_process(delta):
	get_move_input(delta)
	move_and_slide()

	if velocity.length() > 0.1:
		# Rotate the character model to the direction of movement
		var rot = model.rotation
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
	last_floor = is_on_floor()
	
	# handle dash
	if Input.is_action_just_pressed('dash'):
		dash()

func _unhandled_input(event):
	# rotate the character model on mouse move
	if event is InputEventMouseMotion:
		if !model: return
		var rot = model.rotation
		rot.y += event.relative.x * mouse_sensitivity
		model.rotation = rot

	# handle attack
	if Input.is_action_just_pressed("attack"):
		if attacking: 
				#print("Attack ignore, prev is not end yet!")
				pass

		attacking = true
		if anim_state: anim_state.travel(attacks.pick_random())
		# animate weapon mesh in 360 degree rotation
		#var m = active_weapon.mesh as MeshInstance3D
		var tween = get_tree().create_tween()
		tween.tween_property(active_weapon.mesh, 'rotation_degrees:z',active_weapon.mesh.rotation_degrees.z+90,0.1)
		tween.tween_property(active_weapon.mesh, 'rotation_degrees:z',active_weapon.mesh.rotation_degrees.z-90,0.1)
		await tween.finished
		attack()
		
	if Input.is_action_just_pressed("skill"):
		$Skill0.run_skill(self)
		

func start():
	show()

func _on_attack_body_entered(body):
	if body.is_in_group("Enemy"):
		print("Mob in attack area", body)	
		body.state = body.HIT
		body.attack_timer.start()
		mobs_close.append(body)

func _on_attack_body_exited(body):
	if body.is_in_group("Enemy"):
		print("Mob stop attack", body)
		body.state = body.SURROUND
		body.attack_timer.stop()
		mobs_close.erase(body)


func on_hit(damage):
	print("god damn they hit me!", damage)
	self.helths -= damage
	
	#start hit shader animation
	var tween = get_tree().create_tween()
	tween.tween_property(viewport_sprite.material, "shader_parameter/hit_intesity", 0.5, 0.3)
	await tween.finished
	var tween2 = get_tree().create_tween()
	tween2.tween_property(viewport_sprite.material, "shader_parameter/hit_intesity", 0.0, 0.3)
	await tween2.finished
	
	if 	1.0 - ((max_helths - helths)/max_helths) <= 0:
		anim_state.travel("Death_A")
		anim_tree.set("parameters/conditions/running", false)
		anim_tree.set('parameters/conditions/live', false)
		$DiedTimer.start()

func attack():
	# check collision in attack area
	if mobs_close.size() > 0:
		for mob in mobs_close:
			if not mob.is_dead: mob.on_hit(self.damage)

func _on_died_timer_timeout():
	died.emit()
	$DiedTimer.stop()

func add_ghost():
	var ghost = ghost_node.instantiate()
	ghost.set_property(global_position, $ViewportSprite.scale)
	get_tree().current_scene.add_child(ghost)
	# pass data to shader
	var dash_direction = Vector2(velocity.x, velocity.y).normalized()
	ghost.material.set_shader_parameter("dash_direction", dash_direction)


func _on_ghost_timer_timeout():
	add_ghost()
		

func dash():
	particles.emitting = true
	$GhostTimer.start()
	# dash animation
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", global_position + velocity * 1.5, 0.20)
	await tween.finished
	$GhostTimer.stop()
	particles.emitting = false
	

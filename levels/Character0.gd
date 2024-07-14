extends CharacterBody2D

# Controls
@export var speed = 80
@export var acceleration = 14.0
@export var jump_speed = 8.0
@export var mouse_sensitivity = 0.0015
@export var rotation_speed = 12.0
@export var velocity_subViewport = Vector3()

# Global variables
static var anim_state = null
static var anim_tree = null
static var model = null
static var camera3D = null
var last_floor = true

# Variables from current context
@onready var subViewport = $SubViewport
@onready var camera = $Camera2D


var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var jumping = false
var running = false

func _ready():
	# Because we use SubViewport node needs to get that from inner context
	get_viewport_context()

func get_viewport_context():
	# Get all the child nodes of the subViewport.
	var childrenNodes = subViewport.get_children()
	# First childrent is 3d node with character model.
	var characterModel = childrenNodes[0]
	# get child Rig from the characterModel.
	model = characterModel.get_node("Rig")
	# get child Camera from the characterModel.
	camera3D = characterModel.get_node("Camera")
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
		print(animation)
	

var attacks = [
	"1h_slice_diagonal",
	"1h_slice_horizontal",
	"1h_attack_chop"
]

func get_move_input(delta):
	if !camera3D: return
	var direction = Input.get_vector("left", "right", "up", "down")
	# Handle movement
	# If the sprint key is pressed, set the speed to 120, otherwise set it to 80
	if Input.is_action_pressed('sprint'):
		speed = 120
		running = true
		# running animation
		anim_tree.set("parameters/conditions/running", running)
		anim_tree.set("parameters/conditions/not running", !running)
	else:
		speed = 80
		running = false
		anim_tree.set("parameters/conditions/running", running)
		anim_tree.set("parameters/conditions/not running", !running)
	# If the character is on the floor, set the speed to 80
	if direction:
		velocity = direction * speed * delta * 50
		var dir = Vector3(direction.x, 0, direction.y).rotated(Vector3.UP, camera3D.rotation.y)
		velocity_subViewport = lerp(velocity_subViewport, dir * speed, acceleration * delta)
		var vl = velocity_subViewport * model.transform.basis
		anim_tree.set("parameters/IWR/blend_position", Vector2(vl.x, -vl.z) / speed)
	else:
		velocity = Vector2.ZERO
		velocity_subViewport = Vector3(0, velocity_subViewport.y, 0)
		anim_tree.set("parameters/IWR/blend_position", Vector2.ZERO)

func _physics_process(delta):
	get_move_input(delta)
	move_and_slide()

	if velocity.length() > 0.1:
		# Rotate the character model to the direction of movement
		var rot = model.rotation
		rot.y = lerp_angle(rot.y, atan2(velocity.x, -velocity.y), rotation_speed * delta)
		model.rotation = rot
	# Handle jumping
	if Input.is_action_just_pressed("jump"):
		velocity_subViewport.y = jump_speed
		jumping = true
		anim_tree.set("parameters/conditions/jumping", true)
		anim_tree.set("parameters/conditions/grounded", false)
	# when Jump_Idle animation ends, set jumping to false
	if anim_state.get_current_node() == "Jump_Idle":
		jumping = false
		anim_tree.set("parameters/conditions/jumping", false)
		anim_tree.set("parameters/conditions/grounded", true)
	last_floor = is_on_floor()


func _unhandled_input(event):
	# rotate the character model on mouse move
	if event is InputEventMouseMotion:
		if !model: return
		var rot = model.rotation
		rot.y += event.relative.x * mouse_sensitivity
		model.rotation = rot
	# attack on left mouse button click
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		if anim_state: anim_state.travel(attacks.pick_random())

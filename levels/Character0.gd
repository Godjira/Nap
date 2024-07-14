extends CharacterBody2D

@export var speed = 60
@export var acceleration = 4.0
@export var jump_speed = 8.0
@export var mouse_sensitivity = 0.0015
@export var rotation_speed = 12.0
# Variable to store AnimationPlayer state.
static var animState = null

func get_input():
	print(subViewport)
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed

# 

func _physics_process(delta):
	get_input()
	move_and_slide()

var last_floor = true


@onready var model = $Rig	
@onready var anim_tree = $AnimationTree
@onready var subViewport = $SubViewport
#@onready var anim_state = $AnimationTree.get('parameters/playback')
@onready var camera = $Camera


func _init():
	if !subViewport: return
	# Get all the child nodes of the subViewport.
	var childrenNodes = subViewport.get_children()

	# Iterate over each child node.
	for child in childrenNodes:
		# Check if the child node is an instance of AnimationPlayer.
		if child is AnimationPlayer:
			# If it is, set the animState to the current animation's state.
			animState = child.get_current_animation()

	if animState != null:
		print("Current animation state: " + animState)
	else:
		print("AnimationPlayer not found.")



var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var jumping = false

var attacks = [
	"1h_slice_diagonal",
	"1h_slice_horizontal",
	"1h_attack_chop"
]

func get_move_input(delta):
	var vy = velocity.y
	velocity.y = 0
	var input = Input.get_vector("left", "right", "forward", "back")
	var dir = Vector3(input.x, 0, input.y).rotated(Vector3.UP, camera.rotation.y)
	velocity = lerp(velocity, dir * speed, acceleration * delta)
	var vl = velocity * model.transform.basis
	anim_tree.set("parameters/IWR/blend_position", Vector2(vl.x, -vl.z) / speed)
	velocity.y = vy
	print(delta)

func _unhandled_input(event):
	#if event is InputEventMouseMotion:
		#camera.rotation.x -= event.relative.y * mouse_sensitivity
		#camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -90.0, 30.0)
		#camera.rotation.y -= event.relative.x * mouse_sensitivity
	
	if event is InputEventMouseButton  and event.is_pressed():
		print("Left Mouse Button Clicked")
		#anim_state.travel(attacks.pick_random())

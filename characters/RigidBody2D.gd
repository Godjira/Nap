extends RigidBody2D

# Controls
@export var speed = 80
@export var acceleration = 14.0
@export var jump_speed = 8.0
@export var mouse_sensitivity = 0.0015
@export var rotation_speed = 12.0
@export var velocity_sub_viewport = Vector3()

# Global variables
static var anim_state = null
static var anim_tree = null
static var model = null
static var camera3D = null
var last_floor = true

# Variables from current context
@onready var sub_viewport = $SubViewport
@onready var sprite_texture = $Sprite2D


var gravity = Vector2.ZERO
var jumping = false
var running = false
	

func get_viewport_context():
	# Get all the child nodes of the sub_viewport.
	var childrenNodes = sub_viewport.get_children()
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
		#print(animation)
	

var attacks = [
	"1h_slice_diagonal",
	"1h_slice_horizontal",
	"1h_attack_chop"
]

func _ready():
	#print(sprite_texture)	
	# Because we use SubViewport node needs to get that from inner context
	get_viewport_context()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

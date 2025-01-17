extends CharacterBody2D
class_name Mob0

# Variables from current context
@onready var sub_viewport = $SubViewport
@onready var sprite_texture = $Sprite2D
@onready var attack_timer = $AttackTimer

# Controls
var jump_speed = 8.0
var anim_state = null
var anim_tree = null
var model = null
var camera_3D = null
var acceleration = 0.8
var gravity = Vector2.ZERO
var jumping = false
var running = false
var player
var random_num
var target
var velocity_sub_viewport = Vector3.ZERO
var vissible_on_screen = false

var attacks = [
	"1h_slice_diagonal",
	"1h_slice_horizontal",
	"1h_attack_chop"
]

enum {
	SURROUND,
	ATTACK,
	HIT,
	IDLE
}

var state = IDLE



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
		if animation.contains("Idle") or animation.contains("Walking") or animation.contains("Running"):
			anim_player.get_animation(animation).loop = true
		#print(animation)
	


func move(target, delta):
	# var direction = (target - global_position).normalized()
	# var speed = 50
	# var desired_velocity = direction * speed
	# var stearing = (desired_velocity - velocity) * delta * 2.5
	# velocity += stearing
	var speed = 30
	var direction  = (target - global_position).normalized()
	var desired_velocity = direction * speed
	var steering = (desired_velocity - velocity) * delta * 2.5
	velocity += steering

	# rotate Y axis of 3d model
	model.rotation.y = atan2(-velocity.x, -velocity.y)
	move_and_slide()
	
func _physics_process(delta):
	var speed = 50	
	match state:
		IDLE:
			pass
		SURROUND:
			move(get_circle_position(random_num), delta)
		ATTACK:
			move(global_position, delta)
		HIT:
			anim_state.travel(attacks.pick_random())
			move(global_position, delta)
			
	var direction = velocity.angle_to(player.global_position)
	var vl = velocity_sub_viewport * model.transform.basis
	anim_tree.set("parameters/IWR/blend_position", vl)

func get_circle_position(random):
	var kill_circle_center = player.global_position
	var radius = 40
	var angle = random * PI * 2
	var x = kill_circle_center.x + cos(angle) * radius
	var y = kill_circle_center.y + sin(angle) * radius
	return Vector2(x, y)

func _ready():
	# Because we use SubViewport node needs to get that from inner context
	get_viewport_context()
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	random_num = rng.randf()
	

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
	print("Mob not visible")
	vissible_on_screen = false
	state = IDLE

func _on_visible_on_screen_notifier_2d_screen_entered():
	print('Mob visible')
	vissible_on_screen = true


func _on_attack_timer_timeout():
	print("Mob start attack")
	state = ATTACK

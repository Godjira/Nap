extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

	
var active = false
var player
@onready var voidNode = $Void
@onready var explosionNode = $Void/Mesh/Explosion

func run_skill(p):
	if active || !p: return
	
	player = p
	active = true
	voidNode.show()
	$SkillEnd.start()
	# get dirrection to mouse from player
	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - global_position).normalized()
	var tween = get_tree().create_tween()
	var speed = 5
	# add acceleration to the void
	var acceleration = 0.5

	tween.tween_property($Void/Mesh, 'global_position', mouse_pos, 0.5)
	
	await tween.finished
	explosionNode.run_effect()


func _on_skill_end_timeout():
	voidNode.hide()
	$Void/Mesh.global_position = player.global_position

	# add screen shake
	var camera = player.get_node("Camera2D") as Camera2D

	active = false


	explosionNode.stop_effect()
	
func _physics_process(delta):
	if active:
		var m = $Void/Mesh.material as ShaderMaterial
		m.set_shader_parameter("progress", $SkillEnd.time_left - 0.5)
	#check collisions


#func _on_rigid_body_2d_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	#_on_skill_end_timeout()
	#pass


func _on_void_body_entered(body):
	print(body)
	if active:
		_on_skill_end_timeout()

extends Node2D

func _ready():
	$Mesh.hide()

var active := false
var player : CharacterBody2D
@onready var voidNode = $Void
@onready var explosionNode = $Explosion
var acceleration := 0.5
var velocity := Vector2.ZERO
var speed := 5
var target := Vector2.ZERO
var damage := 1.5
var idle := true

func run_skill(p:CharacterBody2D, _target:Vector2):
	if !active and !idle:
		player = p
		active = true
		$SkillEnd.start()
		$Mesh.show()
		target = _target

func end_skill():
	if active:
		explosionNode.global_position = $Mesh.global_position
		explosionNode.run_effect()
		$Mesh.global_position = player.global_position
		$Mesh.hide()
	idle = true

func _on_skill_end_timeout():
	if not idle:
		end_skill()
	active = false
	idle = false
	
func _process(delta):
	if active:
		var m = $Mesh.material as ShaderMaterial
		$Mesh.global_position = lerp($Mesh.global_position, target, 0.33)
		var distance = $Mesh.global_position.distance_to(target)
		m.set_shader_parameter("progress", distance * 0.01)
		if distance < 2.5:
			end_skill()

func _on_void_body_entered(body):
	if body.is_in_group("Enemy") and active and not idle:
		end_skill()
		body.on_hit(damage)

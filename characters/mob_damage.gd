extends Node2D
@onready var label := $MobDamage/Label


func _process(delta:float)->void:
	label.position.y += delta * 4.4
	
func set_damage(d:float)->void:
	$MobDamage/Label.text = str(d)
	

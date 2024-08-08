extends Node2D
@export var player:Character0
var time := 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time+=1
	#global_position = lerp(player.global_position, player.global_position * sin(time*0.1)*0.1 * cos(time*0.1)*-0.1, delta + 0.1)
	global_position.x = lerp(player.global_position.x, player.global_position.x - sin(time*0.1)*2.3, 0.1)
	global_position.y = lerp(player.global_position.y, player.global_position.y + player.global_position.y * delta, 0.1)
	rotate(delta)

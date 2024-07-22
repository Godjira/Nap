extends Node

@export var mob_scene: PackedScene
@export var mobs : Array[CharacterBody2D] = []
@onready var player := $Character0
@onready var ui_node := $"/root/ScreenUi"

# handle on click to ui_node/Control/StartButton
func _on_start_game():
	new_game()

func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	ui_node.show_game_over()
	for mob in mobs:
		if mob: mob.queue_free()
	mobs.clear()
	player.helths = player.default_healths

func new_game():
	player.anim_tree.set('parameters/conditions/live', true)	
	
	$StartTimer.start()
	$MobTimer.start()
	var screenUI = $ScreenUI
	if screenUI:
		screenUI.hide_ui()
		


func _on_start_timer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()

func _on_mob_timer_timeout():
	if(mobs.size() > 100):
		return
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instantiate()
	# Choose a random location on Path2D.
	var mob_spawn_location := $MobPath/MobSpawnLocation
	var randomG := RandomNumberGenerator.new()
	var r := randomG.randf() * 0.2
	mob_spawn_location.progress_ratio = randf()
	# Set the mob's position to a random location.
	mob.position = mob_spawn_location.position
	# Spawn the mob by adding it to the Main scene.
	var node = mob.get_node("Sprite2D") as Sprite2D
	var col_shape = mob.get_node("CollisionShape2D")
	if node: node.scale += Vector2(r, r)
	if col_shape: col_shape.scale += Vector2(r, r)
	add_child(mob)
	mobs.push_back(mob)

func _ready():
	# get signal from ui_node called start_game
	if ui_node: 
		ui_node.connect("start_game", self._on_start_game)


func _on_character_0_died():
	game_over()

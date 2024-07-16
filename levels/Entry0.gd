extends Node

@export var mob_scene: PackedScene
@export var mobs = Array()

@onready var player = $TileMap/Character0

@onready var ui_node = $"/root/ScreenUi"

# handle on click to ui_node/Control/StartButton
func _on_start_game():
	new_game()

func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	ui_node.show_game_over()
	$Music.stop()
	$DeathSound.play()
	for mob in mobs:
		mob.queue_free()
	mobs.clear()
	player.helths = player.default_healths

func new_game():
	player.anim_tree.set('parameters/conditions/live', true)	
	
	$StartTimer.start()
	$MobTimer.start()
	#$Music.play()
	var screenUI = $ScreenUI
	if screenUI:
		screenUI.hide_ui()
		


func _on_start_timer_timeout():
	print("start timer begin")
	$MobTimer.start()
	$ScoreTimer.start()

func _on_mob_timer_timeout():
	if(mobs.size() > 10):
		return
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instantiate()
	# Choose a random location on Path2D.
	var mob_spawn_location = $MobPath/MobSpawnLocation
	mob_spawn_location.progress_ratio = randf()
	# Set the mob's position to a random location.
	mob.position = mob_spawn_location.position
	mob.player = player
	# Spawn the mob by adding it to the Main scene.
	add_child(mob)
	mobs.push_back(mob)
	print(mob)

func _ready():
	# get signal from ui_node called start_game
	if ui_node: 
		ui_node.connect("start_game", self._on_start_game)


func _on_character_0_died():
	game_over()

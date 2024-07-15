extends Node

@export var mob_scene: PackedScene
@export var mobs = Array()

@onready var player = $TileMap/Character0

func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	$ScreenUI.show_game_over()
	$Music.stop()
	$DeathSound.play()

func new_game():
	for mob in mobs:
		mob.queue_free()
	mobs.clear()
	
	$StartTimer.start()
	var screenUI = $ScreenUI
	#$Music.play()
	get_tree().call_group("mobs", "queue_free")
	if screenUI:
		#screenUI.show_message("Get Ready")
		screenUI.hide_ui()
	_on_mob_timer_timeout()
		


func _on_start_timer_timeout():
	print("Start")
	$MobTimer.start()
	$ScoreTimer.start()

func _on_mob_timer_timeout():
	for i in range(0, 9):
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

func _ready():
	print(mob_scene)
	


func _on_screen_ui_start_game():
	new_game()

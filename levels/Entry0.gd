extends Node

@export var mobs : Array[CharacterBody2D] = []
@onready var player := $Character0
@onready var ui_node := $"/root/ScreenUi"
@onready var mob_0_template:PackedScene = preload("res://characters/Mob0.tscn")
@onready var mob_1_template:PackedScene = preload("res://characters/Mob1.tscn")
@onready var mob_2_template:PackedScene = preload("res://characters/mob_2.tscn")
@onready var mob_3_template:PackedScene = preload("res://characters/mob_3.tscn")
@onready var game_global = $"/root/GameGlobalNode"
var mouse_position:Vector2

# handle on click to ui_node/Control/StartButton
func _on_start_game():
	new_game()

func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	ui_node.show_game_over()
	for i in range(mobs.size() - 1, -1, -1):
		var mob = mobs[i]
		if is_instance_valid(mob):
			if not mob.is_dead:
				mob.queue_free()
			mobs.remove_at(i)
	mobs.clear()
	player.helths = player.default_healths

func new_game():
	game_global.clean_scores()
	$StartTimer.start()
	$MobTimer.start()
	player.show()
	var screenUI = $ScreenUI
	if screenUI:
		screenUI.hide_ui()
		


func _on_start_timer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()



func _on_mob_timer_timeout():
	var coin = load("res://items/coin.tres")
	var heal = load("res://items/heal_potion_1.tres")
	var shiny_ring = load("res://items/shiny_ring.tres")
	
	for mob_scene in [mob_0_template,mob_1_template,mob_2_template, mob_3_template]:
		randomize()
		
		if mobs.size() > 20:
			return
		# Create a new instance of the Mob scene.
		var mob = mob_scene.instantiate()
		# Choose a random location on Path2D.
		var mob_spawn_location := $MobPath/MobSpawnLocation
		var randomG := RandomNumberGenerator.new()
		var r := randomG.randf() * 0.2
		mob_spawn_location.progress_ratio = randf()
		# Set the mob's position to a random location.
		mob.position = mob_spawn_location.position * r
		
		var empty = null
		var random_entity = [coin, heal, empty, shiny_ring, coin, heal, empty, coin, heal, empty].pick_random()
		#var random_entity = [shiny_ring].pick_random()
		mob.item = random_entity
		
		#if col_shape: col_shape.scale += Vector2(r, r)
		add_child(mob)
		mobs.push_back(mob)

func _ready():
	# get signal from ui_node called start_game
	if ui_node: 
		ui_node.connect("start_game", self._on_start_game)
	AIPerformanceMonitor.initialize_performance_counters()
	NodeQuerySystem.initialize_performance_counters()

func _physics_process(delta):
	AIPerformanceMonitor.update_performance_counters()
	NodeQuerySystem.initialize_performance_counters()
	# Set the mouse cursor position as the to-vector.
	mouse_position = get_viewport().get_mouse_position()


func _on_character_0_died():
	game_over()

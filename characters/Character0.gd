extends CharacterBody2D
class_name Character0

# Signals
signal hit
signal died

# Controls
@export var speed := 80.0
@export var acceleration := 14.0
@export var jump_speed := 8.0
@export var mouse_sensitivity := 0.0015
@export var rotation_speed := 12.0
@export var ghost_node : PackedScene
var input_direction:Vector2
var swing := false
var direction = Vector2.ZERO
@onready var animation_tree := $AnimationTree
@onready var weapon : Node2D = $Weapon_1
@onready var dash_timer := $DashTimer
@onready var game_global := $"/root/GameGlobalNode"
@onready var attack_timer := $'AttackTimer'

var velocity_sub_viewport := Vector3()
var mobs_close : Array[CharacterBody2D] = []

# Global variables
#static var anim_state  = null
#static var anim_tree : AnimationTree = null
#static var model : Node3D = null
#static var camera_3D :Camera3D = null
var default_healths := 10
var helths := 13.0
var max_helths := 13.0
var max_stamina := 10.0
var stamina := 10.0
var damage := 2.5
@export var active_weapon: WeaponItem = WeaponItem.new()
@export var active_armor: ArmorItem
var attacking: bool
var is_dash_posible := true

enum State { SURROUND, HIT, IDLE, DEAD }

# Variables from current conte
#@onready var sub_viewport = $SubViewport
@onready var camera = $Camera2D
#@onready var viewport_sprite = $ViewportSprite
@onready var animated_sprite = $AnimatedSprite2D
@onready var particles = $GPUParticles2D
@export var inventory: Inventory
var artefacts:Array[ArtefactItem] = []

var jumping := false
var running := false

@onready var player_ui := $"/root/PlayerUi"
@onready var inventory_ui  := $"/root/PlayerUi/Inventory"
@onready var helths_material : ShaderMaterial = $"/root/PlayerUi/ParentControl/Helth/HelthTexture".material
@onready var stamina_material : ShaderMaterial = $"/root/PlayerUi/ParentControl/Stamina/StaminaTexture".material

func show_equipment(slot:InventorySlot = null) -> void:
	weapon = $Weapon_1
	weapon.item = active_weapon
	var sprite = weapon.get_node("Sprite2D") as Sprite2D
	if active_weapon:
		if active_weapon.weapon_type == active_weapon.Types.RANGE:
			sprite.scale = Vector2(0.03, 0.03)
		else: 
			sprite.scale = Vector2(-0.306, 0.374)

		weapon.set_texture_for_weapon(active_weapon.texture)
		if active_weapon.ammo_texture:
			weapon.set_texture_for_ammo(active_weapon.ammo_texture)
	else:
		weapon.set_texture_for_weapon(null)
		weapon.set_texture_for_ammo(null)

func _process(delta:float) -> void:
	direction = Input.get_vector("left", "right", "up", "down")

	if Input.is_action_pressed('sprint') and stamina > 0.1:
		speed = 150
		running = true
		self.stamina -= 0.1
	else:
		speed = lerp(speed, 80., 0.1)
		running = false

	update_blend_position(direction)
	
	#Pass data to helths shader
	if helths_material != null:
		helths_material.set_shader_parameter("health", 1.0 - ((max_helths - helths)/max_helths))
	if stamina_material != null:
		stamina_material.set_shader_parameter("stamina", 1.0 - (self.max_stamina - self.stamina)/self.max_stamina)

#func handle_attack_2() -> void:
	

#func set_walking(arg:bool) -> void:
	#animation_tree["parameters/conditions/running"] = arg
	
	#var timer = get_tree().create_timer(1)
	#await timer.timeout
	#animation_tree["parameters/conditions/running"] = not arg

func update_blend_position(direction:Vector2):
	var normalized_velocity = direction.normalized() * speed * 0.01
	animation_tree["parameters/Idle/blend_position"] = normalized_velocity
	

func _ready() -> void:
	# Set the player to the Equipment node
	player_ui.attach_player(self)
	# Equip items
	show_equipment()
	


func get_move_input(delta: float) -> void:
	input_direction = Input.get_vector("left", "right", "up", "down")
	
	if input_direction.x <= -.5:
		#if animated_sprite.scale.x > 0.0: animated_sprite.scale.x *= -1
		if $WeaponAnimationSprite.scale.x < 0.0: $WeaponAnimationSprite.scale.x *= -1
		#$WeaponAnimationSprite.play("default")
	if input_direction.x >= .5:
		#if animated_sprite.scale.x < 0.0: animated_sprite.scale.x *= -1
		if $WeaponAnimationSprite.scale.x > 0.0: $WeaponAnimationSprite.scale.x *= -1
		#$WeaponAnimationSprite.play("idle_right")
				
	# Handle movement
	if input_direction:
		velocity = input_direction * speed * delta * 50
	else:
		velocity = lerp(velocity, Vector2(0.0, 0.0), 0.1)

func _physics_process(delta:float) -> void:
	get_move_input(delta)
	move_and_slide()
	
	# handle attack
	if Input.is_action_just_pressed("attack") and not swing:
		attacking = true
		var mouse_dir := get_global_mouse_position()  - get_global_position()
		$Attack1.set_attack_direction(mouse_dir)
		weapon.set_attack_direction(mouse_dir)
		weapon.perform_attack()
		

		if input_direction.x <= -.5:
			$WeaponAnimationSprite.play("attack_right")
		else:
			$WeaponAnimationSprite.play("attack_left")
		#attack()

	# handle dash
	if Input.is_action_just_pressed('dash') and stamina > 8.0:
		dash()
		self.stamina -= 8.0
		

func start() -> void:
	show()

func on_hit(d:float) -> void:
	self.helths -= d
	
	var effect = $"/root/PlayerUi/ParentControl/ColorRect" as damaged_effect
	effect.on_player_hit(d, self.helths)
	
	#start hit shader animation
	var tween := get_tree().create_tween()
	tween.tween_property(animated_sprite.material, "shader_parameter/hit_intesity", 0.5, 0.3)
	await tween.finished
	var tween2 := get_tree().create_tween()
	tween2.tween_property(animated_sprite.material, "shader_parameter/hit_intesity", 0.0, 0.3)
	await tween2.finished
	
	if 	1.0 - ((max_helths - helths)/max_helths) <= 0:
		animation_tree["parameters/conditions/is_dead"] = true
		$DiedTimer.start()

#func attack() -> void:
	# attack mob around attack area, can be used as kick or someting like that
	#if mobs_close.size() > 0:
		#for mob in mobs_close:
			#if mob and not mob.is_dead: 
				#var d = self.damage
				## take damage from mele weapon
				#if not active_weapon or active_weapon.weapon_type == active_weapon.Types.MELEE:
					#d = active_weapon.damage
				#var mob_is_dead:bool = await mob.on_hit(d)
				#if mob_is_dead:
					#game_global.update_kills()

func _on_died_timer_timeout() -> void:
	died.emit()
	$DiedTimer.stop()
	animation_tree["parameters/conditions/is_dead"] = false

func add_ghost() -> void:
	var ghost := ghost_node.instantiate()
	ghost.global_position = global_position
	ghost.global_position.y -= 5.0
	 
	var frames = animated_sprite.sprite_frames as SpriteFrames
	var texture : Texture2D = frames.get_frame_texture(animated_sprite.animation,animated_sprite.frame)
	ghost.scale = animated_sprite.scale
	ghost.scale *= 1.2
	ghost.texture = texture
	get_tree().current_scene.add_child(ghost)
	# pass data to shader
	var dash_direction := Vector2(velocity.x, velocity.y).normalized()
	ghost.material.set_shader_parameter("dash_direction", dash_direction)


func _on_ghost_timer_timeout() -> void:
	add_ghost()
		

func dash() -> void:
	if is_dash_posible:
		#animated_sprite.play("slide")
		is_dash_posible = false
		particles.emitting = true
		$GhostTimer.start()
		dash_timer.start()
		
		#animation_tree["parameters/conditions/running"] = false
		#animation_tree["parameters/conditions/dash"] = true
		
		var dash_duration := 0.20  # Duration of the dash in seconds
		var dash_distance := velocity * .5  # Total distance to dash
		var dash_start_pos := global_position
		var elapsed_time := 0.0
		#anim_tree.set("parameters/conditions/dash", true)
		
		while elapsed_time < dash_duration:
			var delta := get_process_delta_time()
			elapsed_time += delta
			
			# Calculate the new position
			var t := elapsed_time / dash_duration
			var new_position := dash_start_pos.lerp(dash_start_pos + dash_distance, t)
			
			# Move and check for collision
			var collision := move_and_collide(new_position - global_position)
			if collision:
				# Handle collision (e.g., stop the dash, slide, or bounce)
				handle_dash_collision(collision)
				break
			
			await get_tree().process_frame
		
		$GhostTimer.stop()
		particles.emitting = false

func handle_dash_collision(collision: KinematicCollision2D) -> void:
	# Implement your collision response here
	# For example, you might want to stop the dash, slide along the surface, or bounce
	print("Collided with: ", collision.get_collider().name)
	# You can access collision normal, collision point, etc. from the collision object


func _on_dash_timer_timeout() -> void:
	particles.emitting = false
	#animation_tree["parameters/conditions/dash"] = false
	is_dash_posible = true

func collect(item: InventoryItem, amount: int) -> void:
	inventory.insert(item, amount)
	
	if item.name.match("Shiny ring"):
		$PointLight2D.show()
		item.active = true

func use_potion(item: PotionItem):
	if item.potion_type == item.PotionType.H:
		helths = min(max_helths, helths + item.potion_power)

func _on_attack_body_body_entered(body:CharacterBody2D) -> void:
	if body.is_in_group("Enemy"):
		print("Mob in attack area", body)	
		body.current_state = State.HIT
		var timer = body.attack_timer as Timer
		timer.start()
		mobs_close.append(body)


func _on_attack_body_body_exited(body:CharacterBody2D) -> void:
	if body.is_in_group("Enemy"):
		print("Mob stop attack", body)
		body.current_state = State.SURROUND
		body.attack_timer.stop()
		mobs_close.erase(body)


func _on_attack_body_entered(body):
	if not body in mobs_close and body.is_in_group("Enemy"):
		mobs_close.append(body)


func _on_attack_body_exited(body):
	if body.is_in_group("Enemy"):
		mobs_close.erase(body)
		
func _input(event):
	if input_direction.x <= -.5:
		#if animated_sprite.scale.x > 0.0: animated_sprite.scale.x *= -1
		if $WeaponAnimationSprite.scale.x < 0.0: $WeaponAnimationSprite.scale.x *= -1
		#$WeaponAnimationSprite.play("default")
	if input_direction.x >= .5:
		#if animated_sprite.scale.x < 0.0: animated_sprite.scale.x *= -1
		if $WeaponAnimationSprite.scale.x > 0.0: $WeaponAnimationSprite.scale.x *= -1
		#$WeaponAnimationSprite.play("idle_right")
	if Input.is_action_just_pressed("ability_0"):
		for slot in inventory.slots:
			if slot.item and slot.item.name.match("Shiny ring"):
				slot.item.active = !slot.item.active
				if slot.item.active:
					$PointLight2D.show()
				else:
					$PointLight2D.hide()

func _on_restore_stamina_timer_timeout():
	if self.stamina < self.max_stamina and not running:
		self.stamina += 1

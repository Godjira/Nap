extends Node2D
class_name Portal

@onready var player_sensor := $"PlayerSensor"
@onready var active_sensor := $"ActiveSensor"
@onready var a_sprite := $"AnimatedSprite2D"
@onready var portal_timer := $"PortalTimer"
@export var connected_to: Portal
var entered_body

func _ready():
	a_sprite.play("close")

func _on_player_sensor_body_entered(body):
	if body.is_in_group("Player"):
		a_sprite.play("opening")
		await a_sprite.animation_finished
		a_sprite.play("default")

func _on_player_sensor_body_exited(body):
	if body.is_in_group("Player"):
		a_sprite.play("close")

func _on_active_sensor_body_entered(body):
	portal_timer.start()
	entered_body = body
	apply_portal_effect(body, true)

func _on_portal_timer_timeout():
	portal_body()

func portal_body() -> void:
	if entered_body and connected_to:
		entered_body.global_position = connected_to.global_position
	else:
		print("Portal fails")

func _on_active_sensor_body_exited(body):
	entered_body = null
	apply_portal_effect(body, false)

func apply_portal_effect(body: Node2D, start: bool) -> void:
	if body.is_in_group("Player"):
		if start:
			# Start the portal effect animation
			var tween = create_tween()
			tween.tween_property(a_sprite.material, "shader_parameter/effect_strength", 0.1, 0.5)
		else:
			# End the portal effect animation
			if a_sprite.material:
				var tween = create_tween()
				tween.tween_property(a_sprite.material, "shader_parameter/effect_strength", 0.0, 0.5)

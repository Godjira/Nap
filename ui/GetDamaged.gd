extends ColorRect
class_name damaged_effect

var damage_tween: Tween

func trigger_damage_effect(intensity: float = 0.5, duration: float = 0.5) -> void:
	# Cancel any existing tween
	if damage_tween:
		damage_tween.kill()
	
	# Create a new tween
	damage_tween = create_tween()
	
	# Set the initial damage intensity
	material.set_shader_parameter("damage_intensity", intensity)
	
	# Animate the damage intensity from the set value to 0
	damage_tween.tween_property(material, "shader_parameter/damage_intensity", 0.0, duration)

# Call this function when the player takes damage
func on_player_hit(damage_amount: float, max_health: float) -> void:
	var intensity = clamp(damage_amount / max_health, 0.1, 1.0)  # Adjust as needed
	trigger_damage_effect(intensity)

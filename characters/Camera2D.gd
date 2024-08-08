extends Camera2D

@export var min_zoom := 1.0
@export var max_zoom := 10.0
@export var zoom_speed := 0.9
@export var shake_strength := 5.0
@export var shake_decay := 0.8

var _current_zoom := 8.5
var _shake_strength := 0.2
var _initial_offset := Vector2.ZERO

func _ready():
	_initial_offset = offset

func _process(delta):
	# Handle zooming
	if Input.is_action_pressed("zoom_in"):
		_current_zoom += zoom_speed * delta
	elif Input.is_action_pressed("zoom_out"):
		_current_zoom -= zoom_speed * delta
	_current_zoom = clamp(_current_zoom, min_zoom, max_zoom)
	zoom = Vector2(_current_zoom, _current_zoom)
	# Handle camera shake
	if _shake_strength > 0:
		_shake_strength *= shake_decay
		offset = _initial_offset + Vector2(
			randf_range(-1, 1) * _shake_strength,
			randf_range(-1, 1) * _shake_strength
		)
	else:
		offset = _initial_offset

func shake():
	_shake_strength = shake_strength

# Call this method when the character moves
func on_character_moved():
	shake()

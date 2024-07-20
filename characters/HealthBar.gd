extends Control
@onready var bg_theme = self.theme

# Called when the node enters the scene tree for the first time.
func _ready():
	bg_theme.set_color("fill", "Colors", Color.BLUE)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass

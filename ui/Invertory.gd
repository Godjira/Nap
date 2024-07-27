extends Control

var is_open = false

@onready var inventory: Inventory = preload("res://items/player.tres")

@onready var slots: Array[Node] = $NinePatchRect/GridContainer.get_children()

func _ready() -> void:
	inventory.update.connect(update_slots)
	update_slots()
	close()

func open() -> void:
	visible = true
	is_open = true
	Engine.time_scale = 0.1

func close() -> void:
	visible = false
	is_open = false
	Engine.time_scale = 1.0

func _process(delta: float) -> void:
	if Input.is_action_just_pressed('inventory'):
		if is_open:
			close()
		else:
			open()

func update_slots() -> void:
	for i in range(min(inventory.slots.size(), slots.size())):
		slots[i].update(inventory.slots[i])

func _input(event):
	if Input.is_action_just_pressed("pause"):
		close()


func _on_gui_input(event):
	print(event)
	pass # Replace with function body.

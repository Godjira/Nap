extends Control

var is_open = false

signal update_slot

@onready var inventory: Inventory = preload("res://items/player.tres")
@onready var slots: Array[Node] = $NinePatchRect/GridContainer.get_children()
@onready var items_slots: Array[Node] = $NinePatchRect2.get_children()
@onready var tooltip := $Tooltip

func _ready() -> void:
	inventory.update.connect(update_slots)
	update_slots()
	close()
	$Tooltip.hide()

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
		update_slot.emit(inventory.slots[i])
		#print(inventory.slots[i].is_armor)
		#var item = inventory.slots[i].item
		#if item and inventory.slots[i].item.type == inventory.slots[i].item.Type.ARTEFACT:
			#is_shiny_ring_inside = true
			#if item.artefact_id == item.ArtifactID.SHINY_RING:
				#print("shiny ring ready to shane")
	for i in range(items_slots.size()):
		var slot = items_slots[i]
		slot.update(slot.inventory_slot)
		update_slot.emit(slot.inventory_slot)
func _input(event):
	if Input.is_action_just_pressed("pause"):
		close()
	if event is InputEventMouseMotion:
		var pos = event.position
		pos.y -= 120
		pos.x += 80
		$Tooltip.position = pos
		


func _on_gui_input(event):
	print(event)
	pass # Replace with function body.

func check_for_item(name:String)->bool:
	for slot in inventory.slots:
		if not slot.item: return false
		if slot.item.name.match(name):
			print("Yes it match!")
			return true
	return false

extends Panel

var is_inventory_open := true
var shake_amount := 2.5
var shake_speed := 0.2
var original_position := Vector2.ZERO
var is_hovering := false
var item_selected := false
var item: InventorySlot

@onready var sprite := $Sprite2D
@onready var item_visual: Sprite2D = $CenterContainer/Panel/ItemDisplay
@onready var item_amount := $CenterContainer/Panel/ItemCount

# New variables for drag and drop
var drag_start_position := Vector2.ZERO
var is_dragging := false

func update(inv_slot: InventorySlot) -> void:
	if !inv_slot || !inv_slot.item:
		item_visual.visible = false
		item_amount.visible = false
	else:
		item_visual.visible = true
		item_amount.visible = true
		if inv_slot.item.texture:
			item_visual.texture = inv_slot.item.texture
		if inv_slot.amount:
			item_amount.text = str(inv_slot.amount)
	
	item = inv_slot

func _ready():
	original_position = sprite.position

func _process(delta):
	sprite.position = original_position
	if is_dragging:
		item_visual.global_position = get_global_mouse_position()

func _on_mouse_entered():
	is_hovering = true
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _on_mouse_exited():
	is_hovering = false
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_start_drag()
			else:
				_end_drag()

func _start_drag():
	if item and item.item:
		item_amount.hide()
		is_dragging = true

func _end_drag():
	if is_dragging:
		is_dragging = false
		item_amount.show()
		# Check if the item is dropped on another inventory slot
		var target_slot = _get_slot_under_mouse()
		if target_slot and target_slot != self:
			_swap_items(target_slot)
		else:
			# If not dropped on another slot, return the item to its original position
			item_visual.position = Vector2.ZERO

func _get_slot_under_mouse() -> Node:
	# Implement this method to raycast or otherwise determine which slot (if any) 
	# the mouse is over when the drag ends
	# This will depend on how your inventory UI is structured
	return null  # Placeholder

func _swap_items(target_slot):
	# Implement the logic to swap items between this slot and the target slot
	var temp_item = item
	var temp_amount = item_amount.text
	
	update(target_slot.item)
	target_slot.update(temp_item)
	
	# Update the visual representations
	item_visual.texture = item.item.texture if item and item.item else null
	item_amount.text = str(item.amount) if item else ""
	
	target_slot.item_visual.texture = temp_item.item.texture if temp_item and temp_item.item else null
	target_slot.item_amount.text = temp_amount

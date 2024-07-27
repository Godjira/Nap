extends Panel
class_name InventorySlotUI

var is_inventory_open := true
var shake_amount := 2.5
var shake_speed := 0.2
var original_position := Vector2.ZERO
var is_hovering := false
var item_selected := false
var inventory_slot: InventorySlot

@onready var sprite := $Sprite2D
@onready var item_visual: Sprite2D = $CenterContainer/Panel/ItemDisplay
@onready var item_amount := $CenterContainer/Panel/ItemCount
static var player: Character0


# New variables for drag and drop
var drag_start_position := Vector2.ZERO
var is_dragging := false

func attach_player(p:Character0):
	self.player = p

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
	
	inventory_slot = inv_slot

func _ready():
	original_position = sprite.position

func _on_mouse_entered():
	is_hovering = true
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _on_mouse_exited():
	is_hovering = false
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _get_drag_data(at_position: Vector2) -> Panel:
	var preview_texture := TextureRect.new()
	preview_texture.texture = item_visual.texture
	preview_texture.expand_mode = 1
	preview_texture.size = Vector2(64, 64)
	
	var preview := Control.new()
	preview.add_child(preview_texture)
	
	set_drag_preview(preview)
	
	print("get drag data", at_position)
	return self

func _can_drop_data(at_position:Vector2, data) -> bool:
	print("can drop data", at_position, data)
	return data is Panel

func _drop_data(at_position:Vector2, data) -> void:
	var t = self.inventory_slot
	#if self.inventory_slot and self.inventory_slot.item:
		##swap items
		#self.inventory_slot = data.inventory_slot
		#data.inventory_slot = t
	#else:
	self.inventory_slot = data.inventory_slot
	data.inventory_slot = t
	data.update(data.inventory_slot)
	self.update(self.inventory_slot)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.double_click and is_hovering and inventory_slot.item:
			if inventory_slot.item is PotionItem: 
				self.player.use_potion(inventory_slot.item)
				inventory_slot.amount -= 1
				if inventory_slot.amount <= 0:
					inventory_slot.item = null
				update(inventory_slot)				

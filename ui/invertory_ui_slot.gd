extends Panel
class_name InventorySlotUI

var is_inventory_open := true
var shake_amount := 2.5
var shake_speed := 0.2
var original_position := Vector2.ZERO
var is_hovering := false
var item_selected := false
var inventory_slot: InventorySlot
@export var is_drop_slot:bool
@export var texture: Texture2D
var inventory_ui: Control
var dragging = false
var drag_start_position = Vector2.ZERO

@onready var item_collectable = preload("res://items/item_collactable.tscn")

@onready var sprite := $Sprite2D
@onready var item_visual: Sprite2D = $CenterContainer/Panel/ItemDisplay
@onready var item_amount := $CenterContainer/Panel/ItemCount
static var player: Character0



func attach_player(p:Character0):
	self.player = p

func _process(delta:float)->void:
	if texture:
		sprite.texture = texture

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
	inventory_ui = get_parent().get_parent().get_parent() as Control

func _on_mouse_entered():
	is_hovering = true
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	if inventory_ui and inventory_slot.item:
		var item := inventory_slot.item
		var descr:String = ""
		var name:String = item.name
		if item.type == item.Type.WEAPON:
			descr = "damage: " + str(item.damage)
		if item.type == item.Type.POTION:
			var p = item as PotionItem
			if p.potion_type == p.PotionType.H:
				descr = "restore " + str(p.potion_power) + " hp"
			if p.potion_type == p.PotionType.M:
				descr = "restore " + str(p.potion_power) + " mp"
		if item.type == item.Type.ARTEFACT:
			var p = item as ArtefactItem
			if p.artefact_id == p.ArtefactID.SHINY_RING:
				descr = "ring of light\npress L to toggle light"

		inventory_ui.tooltip.set_item_name(name)
		inventory_ui.tooltip.set_item_description(descr)
		inventory_ui.tooltip.show()

func _on_mouse_exited():
	is_hovering = false
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	if inventory_ui and inventory_slot.item:
		inventory_ui.tooltip.hide()

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
	return data is Panel

func _drop_data(at_position:Vector2, data) -> void:
	var t = self.inventory_slot
	
	var incoming_slot = data.inventory_slot
	var i_item = incoming_slot.item as InventoryItem
	self.inventory_slot = data.inventory_slot
	if i_item and i_item.type == i_item.Type.WEAPON:
		print("Drop weapon")
		if t.item and t.item.type == t.item.Type.WEAPON:
			player.active_weapon = t.item
		else:
			player.active_weapon = null
			
		player.show_equipment()
		
	data.inventory_slot = t
	data.update(data.inventory_slot)
	self.update(self.inventory_slot)
	var s = data.inventory_slot as InventorySlot
	print("dnd item slot", s)
	


var can_be_droped := false
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		# not sure if this needs to be in the next line, but it doesn't hurt to check
		# if the event is a mouse click before asking if it is a doubleclick
		if event.double_click and event.button_index == MOUSE_BUTTON_LEFT:
			print("double clicked!")
			if inventory_slot and inventory_slot.item is PotionItem: 
				self.player.use_potion(inventory_slot.item)
				inventory_slot.amount -= 1
				if inventory_slot.amount <= 0:
					inventory_slot.item = null
				update(inventory_slot)

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Start dragging
				if is_hovering and inventory_slot.item:
					dragging = true
					drag_start_position = event.global_position
					can_be_droped = false
					await get_tree().create_timer(0.5).timeout
					can_be_droped = true
			else:
				if can_be_droped:
					can_be_droped = false
					# End dragging
					if dragging:
						dragging = false
						var drop_position = event.global_position
						if not get_rect().has_point(drop_position):
							drop_item_to_world(drop_position)
		if event is InputEventMouseMotion:
			if dragging:
				# Update drag preview position
				get_tree().root.get_node("InventoryUI").update_drag_preview(event.global_position)				

func drop_item_to_world(global_position: Vector2) -> void:
	if inventory_slot and inventory_slot.item:
		# Instance the item_collectable scene
		var item_instance = item_collectable.instantiate()
		
		# Set the item properties
		item_instance.item = inventory_slot.item
		item_instance.amount = inventory_slot.amount
		item_instance.disabled = true
		
		# Convert global position to world position
		item_instance.global_position = player.global_position
		
		# Add the item to the world
		player.get_parent().add_child(item_instance)
		item_instance.delay_timer.start()

		# Clear the inventory slot
		inventory_slot.item = null
		inventory_slot.amount = 0
		update(inventory_slot)

# Add this function to update the drag preview
func update_drag_preview(global_position: Vector2) -> void:
	if dragging and inventory_slot.item:
		var preview = get_tree().root.get_node("InventoryUI/DragPreview")
		if preview:
			preview.global_position = global_position
			preview.texture = inventory_slot.item.texture

extends Resource
class_name Inventory

signal update

@export var slots: Array[InventorySlot]

func insert(item:InventoryItem, amount:int) -> void:
	var itemslots = slots.filter(func(slot): return slot.item == item)
	if !itemslots.is_empty():
		itemslots[0].amount += amount
	else:
		var emptyslots = slots.filter(func(slot): return slot.item == null)
		if !emptyslots.is_empty():
			emptyslots[0].item = item
			emptyslots[0].amount += amount
	update.emit()
	

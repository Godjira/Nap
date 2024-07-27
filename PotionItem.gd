extends InventoryItem
class_name PotionItem


enum PotionType {
# for now 2 types is health and mana
	H,
	M,
}

# how much potion will act
@export var potion_power:float
@export var potion_type: PotionType = PotionType.H

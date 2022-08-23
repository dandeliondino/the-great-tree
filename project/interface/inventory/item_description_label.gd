extends Label



func _ready():
	Events.connect("inventory_slot_focus_changed", self, "_on_inventory_slot_focus_changed")

func _on_inventory_slot_focus_changed(index):
	var item : Resource = Game.Inventory.slots[index]
	if item == null:
		text = ""
		return

	text = "%s: %s" % [item.display_name, item.description]

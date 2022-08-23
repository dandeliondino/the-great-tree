extends Button


var item : Resource = null

export(NodePath) onready var itemTexture = get_node(itemTexture) as TextureRect
export(NodePath) onready var quantityLabel = get_node(quantityLabel) as Label
export(int) var inventory_index = -1

func _ready():
	Events.connect("inventory_item_changed", self, "_on_inventory_item_changed")
	connect("visibility_changed", self, "_on_visibility_changed")
	if inventory_index == -1:
		inventory_index = get_index()

# TODO: drag/rearrange items
#func get_drag_data(_position):
#	if item == null:
#		return null
#
#	var drag_data = {
#		"index": inventory_index,
#		"item": Inventory.slots[inventory_index],
#	}
#	var rect = TextureRect.new()
#	rect.texture = item.icon_texture
#	set_drag_preview(rect)
#	return drag_data
#
#func can_drop_data(_position, drag_data):
#	return typeof(drag_data) == TYPE_DICTIONARY and drag_data.has("index")
#
#func drop_data(_position, drag_data):
#	Inventory.swap_items(drag_data["index"], inventory_index)

func update_display():
	item = Game.Inventory.slots[inventory_index]
	if item == null:
		update_empty_slot()
	else:
		update_item()
	

func update_empty_slot():
	itemTexture.texture = null
	quantityLabel.text = ""
	
func update_item():
	itemTexture.texture = item.icon_texture
	if item.always_show_count or item.quantity > 1:
		quantityLabel.text = str(item.quantity)
	else:
		quantityLabel.text = ""



# SIGNALS
func _on_inventory_item_changed(var item_index):
	if item_index == inventory_index:
		update_display()


func _on_visibility_changed():
	if is_visible_in_tree():
		update_display()


func _on_InventorySlot_focus_entered():
	Events.emit_signal("inventory_slot_focus_changed", inventory_index)

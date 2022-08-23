extends Node2D

export(int) var starting_currency_quantity : int = 100
var currency_slot = 16
var currency_id := "gold"

export(Array, Resource) var slots = [
	null, null, null, null, null, null, null, null, 
	null, null, null, null, null, null, null, null,
	null,
]

var items : Dictionary

var monitored_items : Dictionary = {}

func _ready():
	Game.Inventory = self
	load_items()
	set_up_currency()
	Events.connect("add_inventory_item", self, "_on_add_inventory_item")
	Events.connect("inventory_item_changed", self, "_on_inventory_item_changed")
	

func reset_inventory():
	for i in slots.size():
		slots[i] = null
	monitored_items = {}
	set_up_currency()

func send_notification(item_id, quantity_change):
	var verb : String
	if quantity_change > 0:
		verb = "added"
	elif quantity_change < 0:
		verb = "removed"
	else:
		print("Skipping notification for no quantity change")
		return
	
	var msg = "%s (%s) %s" % [items[item_id].display_name, abs(quantity_change), verb]
	Events.emit_signal("notification_requested", msg)
	if item_id == currency_id:
		Events.emit_signal("sfx_coins")
	else:
		Events.emit_signal("sfx_inventory_item")



func add_item(item_or_id, quantity=1, notify=true):
	print("adding item")
	var item = get_item(item_or_id)
	item.quantity = quantity
	
	var success = attempt_merge_added_item(item)
	if !success:
		success = attempt_add_added_item(item)
	
	if success:
		if notify:
			send_notification(item.id, quantity)
		return true
	else:
		if notify:
			Events.emit_signal("notification_requested", "Inventory full")
		return false


func remove_item(item_or_id, quantity, notify=true, all_or_nothing=false):
	print("removing: %s" % quantity)
	var item_id = get_item_id(item_or_id)
	var quantity_to_remove = quantity
	
	var inventory_count = get_inventory_count(item_id)
	
	if all_or_nothing:
		if inventory_count < quantity_to_remove:
			print("Error removing item (%s): has %s, tried to remove %s" % [item_id, inventory_count, quantity_to_remove])
			return false
	
	for item_index in slots.size():
		if quantity_to_remove <= 0:
			break
		var item : Resource = slots[item_index]
		if !item:
			continue
		
		print("id=%s" % item.id)
		print("items id=%s" % items["gold"].id)
		if item.id == item_id:
			var quantity_removed = min(item.quantity, quantity_to_remove)
			var new_quantity = item.quantity - quantity_removed
			change_quantity(item_index, new_quantity, false)
			quantity_to_remove -= quantity_removed
	
	
	
	var new_inventory_count = get_inventory_count(item_id)
	var inventory_change = new_inventory_count - inventory_count
	
	if !new_inventory_count:
		# notification already sent in change_quantity() if removed completely
		return
	
	if notify:
		send_notification(item_id, inventory_change)





func attempt_merge_added_item(item):
	for i in slots.size():
		var success = attempt_merge_items(item, i)
		if success:
			return true
	return false


func attempt_add_added_item(item):
	for i in slots.size():
		if slots[i] == null:
			set_item(i, item, false)
			return true
	return false


func set_item(item_index, item, make_unique=true):
	var previous_item = slots[item_index]
	if make_unique:
		slots[item_index] = item.duplicate() # make unique
	else:
		slots[item_index] = item
	Events.emit_signal("inventory_item_changed", item_index)
	return previous_item


func swap_items(item_index, target_item_index):
	# attempt merge first
	var merge_success = attempt_merge_items_at_index(item_index, target_item_index)
	if merge_success:
		return
	
	var target_item = slots[target_item_index]
	var item = slots[item_index]
	slots[target_item_index] = item
	slots[item_index] = target_item
	Events.emit_signal("inventory_item_changed", item_index)
	Events.emit_signal("inventory_item_changed", target_item_index)
	

func remove_item_at_index(item_index, notify=true):
	var previous_item = slots[item_index]
	slots[item_index] = null
	Events.emit_signal("inventory_item_changed", item_index)
	if notify and previous_item:
		previous_item.notify_dropped()
	return previous_item


func attempt_merge_items_at_index(item_index, target_item_index):
	var success = attempt_merge_items(slots[item_index], target_item_index)
	if success:
		remove_item_at_index(item_index, false)
	return success


func attempt_merge_items(item, target_item_index):
	var target_item = slots[target_item_index]
	if item == null or target_item == null or item.display_name != target_item.display_name:
		return false
		
	target_item.quantity = target_item.quantity + item.quantity
	Events.emit_signal("inventory_item_changed", target_item_index)
	return true


func change_quantity(index : int, new_quantity : int, notify=true):
	var item = slots[index]
	if item == null:
		print("Error: changing quantity of null item")
		return
	
	if new_quantity == 0 and !item.persistent_in_inventory:
		remove_item_at_index(index)
	else:
		item.quantity = new_quantity
		Events.emit_signal("inventory_item_changed", index)


# MONITORED ITEMS
func add_monitored_item(item_or_id):
	var item_id = get_item_id(item_or_id)
	if !monitored_items.keys().has(item_id):
		monitored_items[item_id] = get_inventory_count(item_id)
		

func remove_monitored_item(item_or_id):
	var item_id = get_item_id(item_or_id)
	if monitored_items.keys().has(item_id):
		monitored_items.erase(item_id)


func update_monitored_items():
	for item_id in monitored_items.keys():
		var previous_quantity = monitored_items[item_id]
		var new_quantity = get_inventory_count(item_id)
		if previous_quantity != new_quantity:
			Events.emit_signal("monitored_item_changed", item_id, new_quantity)
			monitored_items[item_id] = new_quantity


# HELPER FUNCTIONS
func get_item(value) -> Resource:
	var item : Resource
	if typeof(value) == TYPE_STRING:
		item = items[value].duplicate()
	else:
		item = value
	return item


func get_item_id(value) -> String:
	var item_id : String
	if typeof(value) == TYPE_STRING:
		item_id = value
	else:
		item_id = value.id
	return item_id


func get_item_slot(item_or_id) -> int:
	var item_id = get_item_id(item_or_id)
	for i in slots.size():
		if slots[i].id == item_id:
			return i
	return -1
	
	
func get_inventory_count(item_or_id) -> int:
	var item_id = get_item_id(item_or_id)
	var count := 0
	for item in slots:
		if !item:
			continue
		if item.id == item_id:
			count += item.quantity
	return count

# item loading

func load_items():
	var item_resource_path = "res://items/definitions/"
	var files = get_files(item_resource_path)
	for file_name in files:
		var file_path = item_resource_path + file_name
		var item = load(file_path)
		
#		var resource_id = file_name.rsplit('.')[0]
		items[item.id] = item.duplicate()
#		items[resource_id].id = resource_id


func get_files(path):
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin(true)

	var file = dir.get_next()
	while file != '':
		files += [file]
		file = dir.get_next()

	return files


func set_up_currency():
	add_item(items["gold"].id, starting_currency_quantity, false)
	swap_items(0, 16)
	

# signals
func _on_add_inventory_item(item_or_id, quantity=-1, notify=true):
	add_item(item_or_id, quantity, notify)

func _on_inventory_item_changed(index):
	update_monitored_items()

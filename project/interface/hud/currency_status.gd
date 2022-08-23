extends Control


onready var label := $Label
var currency_id := "gold"

func _ready():
	Events.connect("main_scene_ready", self, "_on_main_scene_ready")
	Events.connect("monitored_item_changed", self, "_on_monitored_item_changed")

func update_currency_label(quantity):
	label.text = str(quantity)

func _on_main_scene_ready():
	Game.Inventory.add_monitored_item(currency_id)
	update_currency_label(Game.Inventory.get_inventory_count(currency_id))

func _on_monitored_item_changed(item_id, quantity):
	if item_id == currency_id:
		update_currency_label(quantity)

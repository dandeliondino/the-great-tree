extends Container

var InventoryInputHints = preload("res://interface/hud/input_hints/input_hints_inventory.tscn")
var JournalInputHints = preload("res://interface/hud/input_hints/input_hints_journal.tscn")
var DialogueInputHints = preload("res://interface/hud/input_hints/input_hints_dialogue.tscn")
var WorldInputHints = preload("res://interface/hud/input_hints/input_hints_world.tscn")


func _ready():
	Events.connect("game_state_changed", self, "_on_game_state_changed")
	Events.connect("journal_panel_requested", self, "_on_journal_panel_requested")
	Events.connect("inventory_panel_requested", self, "_on_inventory_panel_requested")
	Events.connect("dialogue_started", self, "_on_dialogue_started")



func swap_input_hints(scene : PackedScene):
	clear_input_hints()
	add_input_hints(scene)

func clear_input_hints():
	for child in get_children():
		child.queue_free()

func add_input_hints(scene : PackedScene):
	var input_hints = scene.instance()
	add_child(input_hints)


func _on_game_state_changed(from_state, to_state):
	if to_state == Game.states.WORLD:
		swap_input_hints(WorldInputHints)
	if to_state == Game.states.DIALOGUE:
		swap_input_hints(DialogueInputHints)

func _on_journal_panel_requested():
	swap_input_hints(JournalInputHints)

func _on_inventory_panel_requested():
	swap_input_hints(InventoryInputHints)

#func _on_dialogue_started():
#	swap_input_hints(DialogueInputHints)

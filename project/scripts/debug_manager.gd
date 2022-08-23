extends Node

var ink_verbose = false
var ink_hide_continued = true
var entity_state_change = false
# true = print all ink text, tags and choices to console
# false = print ink signals only

var event_signals = [
	"dialogue_started", 
	"dialogue_ended", 
	"main_scene_ready", 
	"game_manager_ready",
	"disable_current_interactable",
	"inventory_panel_requested",
	"journal_panel_requested",
	"restart_game_requested",
	"journal_updated",
	"level_changing",
	"level_unloading",
	"level_unloaded",
	"level_loading",
	"level_loaded",
	"faded_to_black",
	"faded_to_game",
	"dialogue_typing_completed",
]

var ink_signals = ["InkEnded"]


func _ready():
	if Game.debug:
		connect_signals()

func connect_signals():
	Events.connect("debug_audio_played", self, "_on_debug_audio_played")
	Events.connect("game_state_changed", self, "_on_game_state_changed")
	Events.connect("current_interactable_changed", self, "_on_current_interactable_changed")
	Events.connect("monitored_item_changed", self, "_on_monitored_item_changed")
	Events.connect("inventory_item_changed", self, "_on_inventory_item_changed")
	
	Events.connect("entity_state_changed", self, "_on_entity_state_changed")
	
	for signal_name in event_signals:
		Events.connect(signal_name, self, "_on_Event_signal_emitted", [signal_name])
	
	Game.inkPlayer.connect("InkContinued", self, "_on_Ink_continued")
	
	for signal_name in ink_signals:
		Game.inkPlayer.connect(signal_name, self, "_on_Ink_signal_emitted", [signal_name])

func debug_print(text):
	var s = ": %s" % text
	print(s)

func _on_debug_audio_played(value):
	debug_print("[audio] %s" % value)

func _on_game_state_changed(from_state, to_state):
	debug_print("[game.state] %s -> %s" % [Game.states.keys()[from_state], Game.states.keys()[to_state]])

func _on_current_interactable_changed(from_node, to_node):
	var from_name = "null"
	var to_name = "null"
	if from_node != null:
		from_name = from_node.display_name
	if to_node != null:
		to_name = to_node.display_name

	debug_print("[game.current_interactable] %s -> %s" % [from_name, to_name])


func _on_Event_signal_emitted(firstArg, params = {}):
	if params:
		debug_print("[event] %s (%s)" % [firstArg, params])
	else:
		debug_print("[event] %s" % [firstArg])

func _on_Ink_signal_emitted(signal_name : String):
	debug_print("[ink] %s" % signal_name)

func _on_Ink_continued(text : String, tags : Array):
	if ink_hide_continued:
		return
	
	if ink_verbose:
		debug_print("[ink] InkContinued")
		debug_print("\t text = %s" % text)
		debug_print("\t tags = %s" % str(tags))
		debug_print("\t choices = %s" % str(Game.inkPlayer.CurrentChoices))
	else:
		debug_print("[ink] InkContinued ('%s')" % text.left(30))


func _on_monitored_item_changed(item_id, quantity):
	debug_print("[inventory] monitored item changed: %s = %s" % [item_id, str(quantity)])

func _on_inventory_item_changed(index):
	if !Game.Inventory.slots[index]:
		debug_print("[inventory] slot %s changed to [null]" % [index])
	else:
		debug_print("[inventory] slot %s changed to %s (%s)" % [index, Game.Inventory.slots[index].id, Game.Inventory.slots[index].quantity])

func _on_entity_state_changed(entity_name, canInteract, isQuestTarget):
	if entity_state_change:
		debug_print("[entity] %s state changed: canInteract=%s, isQuestTarget=%s" % [entity_name, canInteract, isQuestTarget])


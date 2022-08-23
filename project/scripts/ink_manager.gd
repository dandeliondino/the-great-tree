extends Node2D

const JOURNAL_PATH = "journal"
const DEFAULT_FLOW = "DEFAULT_FLOW"

var inkPlayer

var current_flow := DEFAULT_FLOW
var pending_flows : Array = []


func _ready():
	Game.inkPlayer = $InkPlayer
	Game.Ink = self
	inkPlayer = $InkPlayer
	Events.connect("main_scene_ready", self, "_on_main_scene_ready")
	Events.connect("ink_path_requested", self, "_on_ink_path_requested")
	inkPlayer.connect("InkError", self, "_on_ink_error")
	inkPlayer.connect("InkContinued", self, "_on_ink_continued")
	
	

func _on_main_scene_ready():
	story_setup()


func story_setup():
	bind_external_functions()
	refresh_entity_states()
	print("story setup complete")
	

func refresh_entity_states():
	inkPlayer.ChoosePathString("setup")
	while inkPlayer.CanContinue:
		inkPlayer.Continue()


func bind_external_functions():
	inkPlayer.BindExternalFunction("emit_signal", Events, "emit_signal")
	inkPlayer.BindExternalFunction("inventory_count", Game.Inventory, "get_inventory_count")
	inkPlayer.BindExternalFunction("add_item", Game.Inventory, "add_item")
	inkPlayer.BindExternalFunction("remove_item", Game.Inventory, "remove_item")
	inkPlayer.BindExternalFunction("disable_instance", self, "disable_instance")
	inkPlayer.BindExternalFunction("journal_updated", self, "journal_updated")
	inkPlayer.BindExternalFunction("emit_entity_state_changed", self, "entity_state_changed")
	inkPlayer.BindExternalFunction("change_level", self, "change_level")
	inkPlayer.BindExternalFunction("get_current_level", self, "get_current_level")



func reset_story():
	inkPlayer.LoadStory()	
	story_setup()

func _process_tags(tags : Array):
	for tag in tags:
		pass
#		_process_speaker_tag(tag)
#		_process_signal_tag(tag)

func has_in_inventory(item : String, quantity : int):
	return true


func get_quest_json():
	var quest_json : String = ""
	var previous_flow = current_flow
	inkPlayer.SwitchFlow("journal")
	inkPlayer.ChoosePathString("journal")
	
	while inkPlayer.CanContinue:
		inkPlayer.Continue()
		quest_json += inkPlayer.CurrentText
	
	inkPlayer.SwitchFlow(previous_flow)
	return quest_json


func start_dialogue(path : String):
	switch_to_flow(path)
	if is_flow_new():
		inkPlayer.ChoosePathString(path)
	
	var path_tags = inkPlayer.TagsForContentAtPath(path)
	if path_tags and path_tags.has("no_dialogue"):
		continue_path()
	else:
		Events.emit_signal("game_state_requested", Game.states.DIALOGUE)
	
	
func continue_path():
	while inkPlayer.CanContinue:
		inkPlayer.Continue()
	switch_to_default_flow()
	

# HELPER FUNCTIONS
func pend_or_end_flow():
	if inkPlayer.CanContinue:
		pend_flow()
	else:
		end_flow()


func pend_flow():
	if current_flow == DEFAULT_FLOW:
		return
		
	if !pending_flows.has(current_flow):
		pending_flows.append(current_flow)
	
	switch_to_default_flow()


func end_flow():
	if current_flow == DEFAULT_FLOW:
		return
		
	inkPlayer.RemoveFlow(current_flow)
	if pending_flows.has(current_flow):
		pending_flows.erase(current_flow)
	
	switch_to_default_flow()


func switch_to_flow(path : String):
	var flow = path.get_slice('.', 0)
	inkPlayer.SwitchFlow(flow)
	current_flow = flow


func switch_to_default_flow():
	inkPlayer.SwitchToDefaultFlow()
	current_flow = DEFAULT_FLOW


func is_flow_new() -> bool:
	if pending_flows.has(current_flow):
		return false
	return true


# EXTERNAL FUNCTIONS
func journal_updated():
#	Events.emit_signal("notification_requested", "Journal updated")
	Events.emit_signal("journal_updated")
	
func entity_state_changed(entity_name, canInteract, isQuestTarget):
	Events.emit_signal("entity_state_changed", entity_name, canInteract, isQuestTarget)

func disable_instance():
	Events.emit_signal("disable_current_interactable")

func change_level(level_name):
	Events.emit_signal("change_level_requested", level_name)

func get_current_level():
	return Game.current_level
		

# SIGNALS

func _on_ink_speaker_changed(_variable, new_speaker : String):
	Events.emit_signal("speaker_changed", new_speaker)	

func _on_ink_continued(ink_text : String, tags : Array):
	_process_tags(tags)

func _on_ink_path_requested(path : String):
	inkPlayer.ChoosePathString(path)
	var path_tags = inkPlayer.TagsForContentAtPath(path)
	
	if "dialogue" in path_tags:
		Events.emit_signal("game_state_requested", Game.states.DIALOGUE)


func _on_ink_error(message : String, isWarning : bool):
	var s = ""
	if isWarning:
		s = "Ink Warning: " + message
	else:
		s = "Ink Error: " + message
	print(s)

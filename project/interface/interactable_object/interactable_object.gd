tool
extends Node2D


# numbers match with Game vars in Ink
enum quest_states { QUEST_NONE=0, QUEST_IN_PROCESS=1, QUEST_NEW=2 }

enum interactable_states { INTERACTION_NONE=0, INTERACTION_OLD=1, INTERACTION_NEW=2 }
enum focus_states { FOCUS_OFF, FOCUS_ON }


export(Resource) var entity_def

var ink_path : String

var interactable_state : int setget set_interactable_state
var quest_state : int setget set_quest_state
var focus_state : int setget set_focus_state
var display_name : String setget , get_display_name
var enabled := true setget set_enabled

var interactable_state_paused = false setget set_interactable_state_paused

onready var sprite : Sprite = $Sprite
onready var interactArea : Area2D = $InteractArea
onready var animTree : AnimationTree = $AnimationTree
onready var animTree_quest_state = $AnimationTree.tree_root.get_node("QuestState")

func _ready():
	# tool
	if entity_def:
		if entity_def.sprite_texture:
			sprite.texture = entity_def.sprite_texture
		else:
			print("Warning: no sprite texture for object.")
	
	if !Engine.editor_hint:
		in_game_setup()


# SETUP
func in_game_setup():
	ink_path = entity_def.ink_path
	if ink_path == "":
		print("WARNING: No ink path for object")
	
	animTree.active = true
	
	Events.connect("current_interactable_changed", self, "_on_current_interactable_changed")
	Events.connect("entity_state_changed", self, "_on_entity_state_changed")
	
	reset_interact_area()





# STATES
func set_enabled(value : bool):
	if value == false:
		set_disabled_state()


func set_disabled_state():
	set_interactable_state(interactable_states.INTERACTION_NONE)
	set_focus_state(focus_states.FOCUS_OFF)
	set_quest_state(quest_states.QUEST_NONE)


func set_interactable_state(value : int):
#	print("%s: interactable_state = %s" % [self.display_name, self.interactable_states.keys()[value]])
	interactable_state = value
	if value == interactable_states.INTERACTION_NEW:
		animTree.set("parameters/ReminderState/current", 1)
	else:
		animTree.set("parameters/ReminderState/current", 0)
	reset_interact_area()


func set_quest_state(value : int):
#	print("%s: quest_state = %s" % [self.display_name, self.quest_states.keys()[value]])
	quest_state = value
	animTree.set("parameters/QuestState/current", value)
	
	
func set_focus_state(value : int):
#	print("%s: focus_state = %s" % [self.display_name, self.focus_states.keys()[value]])
	focus_state = value
	
#	print("focus anim: %s" % animTree.get("parameters/FocusState/current"))
	
	match value:
		focus_states.FOCUS_OFF:
			set_focus_off()
		focus_states.FOCUS_ON:
			set_focus_on()
			

func select_object():
	self.interactable_state_paused = true
	animTree.set("parameters/ReminderState/current", 0)
	animTree.set("parameters/SelectedOneShot/active", true)
	yield(get_tree().create_timer(0.25), "timeout")
	start_ink_story()
	

# HELPER FUNCTIONS
func get_display_name():
	if !entity_def:
		return "NULL"
	if !entity_def.display_name:
		return "UNNAMED_INTERACTABLE"
	return entity_def.display_name


func set_focus_on():
	animTree.set("parameters/FocusState/current", 1)
	toggle_interactable_connections(true)
	
func set_focus_off():
	animTree.set("parameters/FocusState/current", 0)
	toggle_interactable_connections(false)


func set_interactable_state_paused(value : bool):
	interactable_state_paused = value
	reset_interact_area()



func reset_interact_area():
	if interactable_state_paused:
		disable_interact_area()
	elif interactable_state == interactable_states.INTERACTION_NONE:
		disable_interact_area()
	else:
		enable_interact_area()


func enable_interact_area():
	interactArea.set_deferred("monitorable", true)
	interactArea.set_deferred("monitoring", true)


func disable_interact_area():
	interactArea.set_deferred("monitorable", false)
	interactArea.set_deferred("monitoring", false)


func toggle_interactable_connections(value : bool):
	var connections := [
		{
			"signal": "interact_button_pressed",
			"method": "_on_interact_button_pressed",
		},
		{
			"signal": "disable_current_interactable",
			"method": "_on_disable_current_interactable",
		}
	]
	
	toggle_connections(connections, value)


func toggle_connections(connections : Array, connect : bool):
	for connection in connections:
		var is_connection_connected = Events.is_connected(connection.signal, self, connection.method)
		if connect:
			if !is_connection_connected:
				Events.connect(connection.signal, self, connection.method)
		elif !connect:
			if is_connection_connected:
				Events.disconnect(connection.signal, self, connection.method)
			


func start_ink_story():
	if !ink_path:
		print("Error: No ink path for entity (%s/%s)" % [get_parent().name, name])
		return
		
	Game.Ink.start_dialogue(ink_path)



# SIGNALS
# on player focus / selection
func _on_current_interactable_changed(from_node : Node2D, to_node : Node2D):
	if interactable_state_paused:
		# resets for *next* interactable change
		self.focus_state = focus_states.FOCUS_OFF
		self.interactable_state_paused = false
		return
		
	if to_node == self:
		self.focus_state = focus_states.FOCUS_ON
	elif from_node == self:
		self.focus_state = focus_states.FOCUS_OFF


func _on_interact_button_pressed():
	select_object()
	


# on ink state variables changed
func _on_entity_state_changed(entity_name : String, canInteract : bool, isQuestTarget : bool):
	if entity_name != entity_def.ink_path:
		return
	if !enabled:
		return
	if canInteract:
		self.interactable_state = interactable_states.INTERACTION_OLD
	else:
		self.interactable_state = interactable_states.INTERACTION_NONE
	if isQuestTarget:
		self.quest_state = quest_states.QUEST_NEW
	else:
		self.quest_state = quest_states.QUEST_NONE


func _on_disable_current_interactable():
	self.enabled = false
	if entity_def.destroy_on_disable:
		get_parent().queue_free()

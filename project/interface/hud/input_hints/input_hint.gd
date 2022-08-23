tool
# TODO: error messages
extends Container

export(String) var keypress : String setget set_keypress
export(String) var action : String setget set_action
#export(NodePath) onready var keypressLabel = get_node(keypressLabel) as Label
#export(NodePath) onready var actionLabel = get_node(actionLabel) as Label


func _ready():
	self.keypress = keypress
	self.action = action

func set_keypress(value : String):
	keypress = value
	if !is_inside_tree():
		return
	
	var multi_keys = value.split("/")
	var keypress_string := ""
	for key in multi_keys:
		keypress_string += "[%s]/" % key
	keypress_string = keypress_string.trim_suffix("/")
	$KeypressLabel.text = keypress_string


func set_action(value : String):
	action = value
	if !is_inside_tree():
		return
		
	$ActionLabel.text = value

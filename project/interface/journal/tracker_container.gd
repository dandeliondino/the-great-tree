extends MarginContainer


export(NodePath) onready var trackerLabel = get_node(trackerLabel) as Label

var text : String setget set_text

func set_text(value : String):
	trackerLabel.text = value
	text = value

extends Container

#export(NodePath) onready var quitButton = get_node(quitButton)

func _ready():
	connect("visibility_changed", self, "_on_visibility_changed")
	connect("child_entered_tree", self, "_on_child_entered_or_exiting")
	connect("child_exiting_tree", self, "_on_child_entered_or_exiting")
	


func focus_first_button():
	if !is_visible_in_tree():
		return
	
	var buttons := get_children()
	for button in buttons:
		if button.get_class() == "Button":
			if button.visible:
				button.suppress_focus_sound = true
				button.grab_focus()
				button.suppress_focus_sound = false
				break



func _on_visibility_changed():
	call_deferred("focus_first_button")

func _on_child_entered_or_exiting(node : Node):
	call_deferred("focus_first_button")

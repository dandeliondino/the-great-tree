extends Button

var suppress_focus_sound := false

func _ready():
	connect("focus_entered", self, "_on_focus_entered")
	connect("pressed", self, "_on_pressed")
	


func _on_focus_entered():
	if suppress_focus_sound:
		return
	Events.emit_signal("UI_button_focused")


	
func _on_pressed():
	# for keyboard press "enter", button down and pressed will both fire
	Events.emit_signal("UI_button_pressed")




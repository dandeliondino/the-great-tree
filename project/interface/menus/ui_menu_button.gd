class_name UIMenuButton
extends Button

export(String) var signal_name
export(Array) var signal_params = []


var suppress_focus_sound = false


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
	
	if !signal_name:
		print("Error: No signal connected to button press (%s)" % name)
		return
	
	if signal_params.size() == 1:
		Events.emit_signal(signal_name, signal_params[0])
	elif signal_params.size() == 0:
		Events.emit_signal(signal_name)

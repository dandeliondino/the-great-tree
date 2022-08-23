extends CanvasItem


export(String) var show_signal : String
export(String) var hide_signal : String

func _ready():
	if show_signal:
		Events.connect(show_signal, self, "_on_show_signal_emitted")
	if hide_signal:
		Events.connect(hide_signal, self, "_on_hide_signal_emitted")
	
	if !show_signal and !hide_signal:
		print("ERROR: Signal node (%s) not connected to any signals" % name)


func _on_show_signal_emitted():
	visible = true	

func _on_hide_signal_emitted():
	visible = false	

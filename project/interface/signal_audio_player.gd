extends AudioStreamPlayer

export(String) var signal_name : String
export(String) var stop_signal_name : String

func _ready():
	if signal_name:
		Events.connect(signal_name, self, "_on_signal_emitted")
	else:
		print("ERROR: Audio (%s) not connected to signal" % name)
	
	if stop_signal_name:
		Events.connect(stop_signal_name, self, "_on_stop_signal_emitted")

func _on_signal_emitted(args = []):
	play()
	Events.emit_signal("debug_audio_played", name)
	
func _on_stop_signal_emitted(args = []):
	stop()
	Events.emit_signal("debug_audio_played", name + " (stopped)")

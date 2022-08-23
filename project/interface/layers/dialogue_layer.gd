extends InterfaceLayer

func _ready():
	layer_game_state = Game.states.DIALOGUE

func _process_unhandled_input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		pass
		# TODO: disabled ability to exit dialogue for now -- returning to flows is a bit buggy
#		Events.emit_signal("game_state_exit_requested")


extends InterfaceLayer

func _ready():
	layer_game_state = Game.states.WORLD
	additional_visible_states = [Game.states.DIALOGUE, Game.states.PANEL]

func _process_unhandled_input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		Events.emit_signal("pause_menu_requested")
	if event.is_action_pressed("inventory"):
		Events.emit_signal("inventory_panel_requested")
	if event.is_action_pressed("journal"):
		Events.emit_signal("journal_panel_requested")
	if event.is_action_pressed("ui_accept"):
		Events.emit_signal("interact_button_pressed")



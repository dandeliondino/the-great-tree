class_name InterfaceLayer
extends CanvasLayer

var layer_game_state : int
var additional_visible_states := []
var allow_repeat_input := false # change this to disable event.is_echo() check

func _enter_tree():
	visible = false
	Events.connect("game_state_changed", self, "_on_game_state_changed")


func _unhandled_input(event: InputEvent):	
	if !allow_repeat_input and event.is_echo():
		return
	
	_process_unhandled_input(event)


func _process_unhandled_input(event: InputEvent):
	# override this function
	pass


func _toggle_input(value : bool):
	set_process_input(value)
	set_process_unhandled_input(value)
	
func _is_visible_in_state(state):
	if state == layer_game_state:
		return true
	if state in additional_visible_states:
		return true
	return false


func _on_game_state_changed(from_state, to_state):
	if _is_visible_in_state(to_state):
		visible = true
	else:
		visible = false
	
	match layer_game_state:
		to_state:
			_toggle_input(true)
			_game_state_entered()
		from_state:
			_toggle_input(false)
			_game_state_exited()
		_:
			_toggle_input(false)


func _game_state_entered():
	# overrideable function
	pass

func _game_state_exited():
	# overrideable function
	pass


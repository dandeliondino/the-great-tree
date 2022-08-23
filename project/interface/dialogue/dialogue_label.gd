extends Label

export(Array, AudioStream) var typing_sounds

enum states { IDLE, TYPING }
var state = states.IDLE

var dialogue_text := ""
var current_length : int = 0

onready var timer := $Timer
onready var audioPlayer := $AudioStreamPlayer

func _input(event):
	if state != states.TYPING:
		return
		
	if event.is_action_pressed("ui_accept"):
		jump_to_end()
	

func display_dialogue(var new_text : String):
	dialogue_text = new_text.strip_edges()
	if dialogue_text == "":
		text = ""
		Events.emit_signal("dialogue_typing_completed")
		return
		
	start_typing()


	
func start_typing():
	state = states.TYPING
	current_length = 0
	type_next_letter()
	timer.start()
	
func type_next_letter():
	current_length += 1		
	text = dialogue_text.substr(0, current_length)
	audioPlayer.stream = get_typing_sound()
	audioPlayer.play()
	if current_length > dialogue_text.length():
		stop_typing()
		return

func get_typing_sound():
	return typing_sounds[randi() % typing_sounds.size()]

func stop_typing():
	Events.emit_signal("dialogue_typing_completed")
	state = states.IDLE
	timer.stop()
	audioPlayer.stop()

func jump_to_end():
	stop_typing()
	text = dialogue_text

func _on_Timer_timeout():
	type_next_letter()

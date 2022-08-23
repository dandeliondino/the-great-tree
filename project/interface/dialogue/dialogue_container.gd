extends PanelContainer

var ChoiceButton = preload("res://interface/dialogue/choice_button.tscn")

export(NodePath) onready var dialogueLabel = get_node(dialogueLabel) as Label
export(NodePath) onready var speakerLabel = get_node(speakerLabel) as Label
export(NodePath) onready var choiceContainer = get_node(choiceContainer) as Container

var inkPlayer : Node = null



func _ready():
	Events.connect("game_state_changed", self, "_on_game_state_changed")
	Events.connect("dialogue_typing_completed", self, "_on_dialogue_typing_completed")

func start_dialogue():
	if inkPlayer == null:
		inkPlayer = Game.inkPlayer
	
	_connect_ink_dialogue_signals()
	set_speaker_from_interactable()
	
	if Game.Ink.is_flow_new():
		inkPlayer.Continue()
	else:
		continue_processing()

func end_dialogue():
	if Game.state == Game.states.DIALOGUE:
		Events.emit_signal("game_state_exit_requested")


func set_speaker_from_interactable():
	if Game.current_interactable == null:
		return
		
	var speaker = Game.current_interactable.display_name
	change_speaker(speaker)

func change_speaker(speaker : String):
	speakerLabel.text = speaker

func _connect_ink_dialogue_signals():
	inkPlayer.connect("InkContinued", self, "_on_ink_continued")
	Events.connect("speaker_changed", self, "_on_speaker_changed")

func _disconnect_ink_dialogue_signals():
	inkPlayer.disconnect("InkContinued", self, "_on_ink_continued")
	Events.disconnect("speaker_changed", self, "_on_speaker_changed")


func continue_processing():
	if !inkPlayer.CurrentText and !inkPlayer.HasChoices:
		if inkPlayer.CanContinue:
			inkPlayer.Continue()
		else:
			end_dialogue()
		return
	
	_clear_choices()
	process_text()
	# will call with dialogue typing completed
#	process_choices()


func process_text():
	dialogueLabel.display_dialogue(inkPlayer.CurrentText)

func process_choices():
	_clear_choices()
	if inkPlayer.HasChoices:
		_add_choice_buttons(inkPlayer.CurrentChoices)
	elif inkPlayer.CanContinue:
		_add_continue_button()
	else:
		_add_end_button()


# CHOICES

func _clear_choices():
	for button in choiceContainer.get_children():
		button.queue_free()

func _add_choice_buttons(choices):
	for choice_index in choices.size():
		var choice_text = choices[choice_index]
		var button = ChoiceButton.instance()
		button.text = "> " + choice_text
		button.connect("pressed", self, "_on_choice_button_pressed", [choice_index])
		choiceContainer.add_child(button)

func _add_continue_button():
	var button = ChoiceButton.instance()
	button.text = "> [...]"
	button.connect("pressed", self, "_on_continue_button_pressed")
	choiceContainer.add_child(button)
	
func _add_end_button():
	var button = ChoiceButton.instance()
	button.text = "> [ x ]"
	button.connect("pressed", self, "_on_end_button_pressed")
	choiceContainer.add_child(button)



# SIGNALS
func _on_game_state_changed(from_state, to_state):
	if to_state == Game.states.DIALOGUE:
		start_dialogue()
	if from_state == Game.states.DIALOGUE:
		Game.Ink.pend_or_end_flow()
		_disconnect_ink_dialogue_signals()


func _on_ink_continued(_ink_text : String, _tags : Array):
	continue_processing()



func _on_choice_button_pressed(choice_index : int):
	inkPlayer.ChooseChoiceIndex(choice_index)
	if inkPlayer.CanContinue:
		inkPlayer.Continue()
	else:
		end_dialogue()

func _on_continue_button_pressed():
	inkPlayer.Continue()

func _on_end_button_pressed():
	end_dialogue()

func _on_speaker_changed(new_speaker):
	change_speaker(new_speaker)

func _on_dialogue_typing_completed():
	process_choices()


extends VBoxContainer

export(NodePath) onready var interactableNameLabel = get_node(interactableNameLabel) as Label
export(NodePath) onready var keypressLabel = get_node(keypressLabel) as Label
export(NodePath) onready var verbLabel = get_node(verbLabel) as Label

func _ready():
	Game.interact_hint = self
	hide()
	Events.connect("current_interactable_changed", self, "_on_current_interactable_changed")
	Events.connect("game_state_changed", self, "_on_game_state_changed")
	
func show_interact_hint(entity_def : Resource):
	if !entity_def:
		print("ERROR: Interact hint requested with null entity_def.")
		return
		
	interactableNameLabel.text = entity_def.display_name
	verbLabel.text = entity_def.interaction_verb
	show()


func _on_current_interactable_changed(from_node, to_node):
	if to_node == null:
		hide()
	else:
		show_interact_hint(to_node.entity_def)


func _on_game_state_changed(from_state, to_state):
	if to_state == Game.states.WORLD:
		if Game.current_interactable:
			show()
	else:
		hide()
	



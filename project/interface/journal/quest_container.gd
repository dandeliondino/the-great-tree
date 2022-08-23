extends Control

var StepContainer = preload("res://interface/journal/step_container.tscn")

export(Color) var normal_color
export(Color) var focused_color

export(NodePath) onready var titleLabel = get_node(titleLabel) as Label
export(NodePath) onready var statusLabel = get_node(statusLabel) as Label
export(NodePath) onready var descriptionLabel = get_node(descriptionLabel) as Label
export(NodePath) onready var stepListContainer = get_node(stepListContainer) as Container

var title : String setget set_title
var status : String setget set_status
var description : String setget set_description

func _ready():
	clear_steps()

func set_title(value : String):
	titleLabel.text = value
	title = value

func set_status(value : String):
	statusLabel.text = value
	status = value
	
func set_description(value : String):
	descriptionLabel.text = value
	description = value


func clear_steps():
	for child in stepListContainer.get_children():
		child.queue_free()
		
func add_step(step_title : String, step_status : String, step_completed : bool, trackers : Array = []):
	var step = StepContainer.instance()
	stepListContainer.add_child(step)
	step.title = step_title
	step.status = step_status
	step.completed = step_completed
	step.trackers = trackers
	

func _on_QuestContainer_focus_entered():
	titleLabel.set("modulate", focused_color)

func _on_QuestContainer_focus_exited():
	titleLabel.set("modulate", normal_color)





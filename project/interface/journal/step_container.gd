extends VBoxContainer

var TrackerContainer = preload("res://interface/journal/tracker_container.tscn")
var tickbox_normal_texture = preload("res://interface/textures/tickbox_empty.png")
var tickbox_ticked_texture = preload("res://interface/textures/tickbox_ticked.png")

export(NodePath) onready var titleLabel = get_node(titleLabel) as Label
export(NodePath) onready var statusLabel = get_node(statusLabel) as Label
export(NodePath) onready var trackerListContainer = get_node(trackerListContainer) as Container
export(NodePath) onready var tickbox = get_node(tickbox) as TextureRect

var title : String setget set_title
var status : String setget set_status
var completed : bool setget set_completed
var trackers : Array setget set_trackers

func _ready():
	clear_trackers()
	
func clear_trackers():
	for child in trackerListContainer.get_children():
		child.queue_free()

func set_title(value : String):
	titleLabel.text = value
	title = value

func set_status(value : String):
	statusLabel.text = value
	status = value

func set_completed(value : bool):
	completed = value
	if completed:
		tickbox.texture = tickbox_ticked_texture
	else:
		tickbox.texture = tickbox_normal_texture

func set_trackers(value : Array):
	clear_trackers()
	trackers = value
	for tracker in trackers:
		var tracker_container = TrackerContainer.instance()
		trackerListContainer.add_child(tracker_container)
		tracker_container.text = tracker
		




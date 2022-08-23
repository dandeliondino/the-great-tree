extends Control

const JOURNAL_PATH = "journal"

var debug_show_all_quests = false

var QuestContainer = preload("res://interface/journal/quest_container.tscn")

export(NodePath) onready var questListContainer = get_node(questListContainer) as Control
export(NodePath) onready var scrollContainer = get_node(scrollContainer) as ScrollContainer
export(NodePath) onready var emptyJournalLabel = get_node(emptyJournalLabel) as Label

func _ready():
	clear_quests()

func _unhandled_input(event: InputEvent):
	if !scrollContainer.scroll_vertical_enabled:
		return
	if event.is_action_pressed("ui_down"):
		scroll_down()
	if event.is_action_pressed("ui_up"):
		scroll_up()

func scroll_up():
	scrollContainer.scroll_vertical -= 128

func scroll_down():
	scrollContainer.scroll_vertical += 128
	
# TODO: signal after quests finished adding to focus on first one -- rather than on visiblity changed (focusing before they are all added)
# refresh quests on journal open not visiblity (getting twice)

func refresh_quests():
	clear_quests()
	var json_string = Game.Ink.get_quest_json()
	var json = JSON.parse(json_string)
	var quests = json.result["quests"]
	for quest in quests:
		if quest["started"] or debug_show_all_quests:
			add_quest(quest)
		
	if questListContainer.get_child_count() == 0:
		emptyJournalLabel.show()
	else:
		emptyJournalLabel.hide()

func add_quest(quest : Dictionary):
	var questContainer = QuestContainer.instance()
	questListContainer.add_child(questContainer)
	questContainer.title = quest["title"]
	questContainer.description = quest["description"]
	questContainer.status = get_status_string(quest)
	for step in quest["steps"]:
		if step["started"] or debug_show_all_quests:
			var status = get_status_string(step)
			var trackers = []
			if "trackers" in step.keys():
				trackers = step.trackers
			questContainer.add_step(step.title, status, step.completed, trackers)


func get_status_string(data_dict : Dictionary):
	if data_dict["completed"]:
		return "COMPLETED"
	elif data_dict["started"]:
		return "STARTED"
	else:
		return "NOT STARTED"



func clear_quests():
	for child in questListContainer.get_children():
		child.queue_free()


func _on_JournalPanel_visibility_changed():
	if is_visible_in_tree():
		refresh_quests()
	else:
		clear_quests()



extends VBoxContainer

var NotificationLabel = preload("res://interface/hud/notification_label.tscn")

export(int) var max_notifications = 1

func _ready():
	Events.connect("notification_requested", self, "_on_notification_requested")
	Events.connect("journal_updated", self, "_on_journal_updated")
	clear_notifications()


func clear_notifications():
	for child in get_children():
		child.queue_free()

func add_notification(var text : String):
	if get_child_count() >= max_notifications:
		get_child(0).hide()
		get_child(0).queue_free()
	var notification_label = NotificationLabel.instance()
	notification_label.text = text
	add_child(notification_label)
	

func _on_notification_requested(var text : String):
	add_notification(text)

func _on_journal_updated():
	add_notification("Journal updated")

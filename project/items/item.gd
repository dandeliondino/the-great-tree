class_name Item
extends Resource

export(String) var id
export(String) var display_name = ""
export(String) var display_name_plural = ""
export(String) var description = ""
export(Texture) var icon_texture = null
export(bool) var persistent_in_inventory = false
export(bool) var always_show_count = false


var quantity : int = 1


func notify_added():
	if quantity > 1:
		Events.emit_signal("notification_requested", "%s (%s) added" % [display_name, str(quantity)])
	else:
		Events.emit_signal("notification_requested", "%s added" % display_name)


func notify_dropped():
	if quantity > 1:
		Events.emit_signal("notification_requested", "%s (%s) removed" % [display_name, str(quantity)])
	else:
		Events.emit_signal("notification_requested", "%s removed" % display_name)

func notify_quantity_changed(change):
	if change < 0:
		Events.emit_signal("notification_requested", "%s (%s) removed" % [display_name, str(change)])
	elif change > 0:
		Events.emit_signal("notification_requested", "%s (%s) added" % [display_name, str(change)])

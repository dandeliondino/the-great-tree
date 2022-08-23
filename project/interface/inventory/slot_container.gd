extends GridContainer


func _ready():
	connect("visibility_changed", self, "_on_visibility_changed")

func update_focus():
	get_child(0).grab_focus()

func _on_visibility_changed():
	if is_visible_in_tree():
		update_focus()

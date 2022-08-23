extends InterfaceLayer

export(NodePath) onready var inventoryPanel = get_node(inventoryPanel) as Control
export(NodePath) onready var journalPanel = get_node(journalPanel) as Control

var panels := []

func _ready():
	layer_game_state = Game.states.PANEL
	
	panels = [inventoryPanel, journalPanel]
	
	Events.connect("inventory_panel_requested", self, "_on_inventory_panel_requested")
	Events.connect("journal_panel_requested", self, "_on_journal_panel_requested")




func _process_unhandled_input(event: InputEvent):
	if event.is_action_pressed("inventory"):
		if inventoryPanel.visible:
			hide_all_panels()
		else:
			Events.emit_signal("inventory_panel_requested")
	if event.is_action_pressed("journal"):
		if journalPanel.visible:
			hide_all_panels()
		else:
			Events.emit_signal("journal_panel_requested")
		
	elif event.is_action_pressed("ui_cancel"):
		hide_all_panels()


func show_panel(panel : Control):
	Events.emit_signal("game_state_requested", Game.states.PANEL)
	Events.emit_signal("UI_panel_opened")
	print("panel: %s" % panel)
	for p in panels:
		print("p: %s" % p)
		if p == panel:
			p.show()
		else:
			p.hide()
	

func hide_all_panels():
	Events.emit_signal("UI_panel_closed")
	Events.emit_signal("game_state_exit_requested")


func _on_inventory_panel_requested():
	show_panel(inventoryPanel)	

func _on_journal_panel_requested():
	show_panel(journalPanel)

extends Control

export(NodePath) onready var mainMenu = get_node(mainMenu) as Control
export(NodePath) onready var gameOverMenu = get_node(gameOverMenu) as Control
export(NodePath) onready var aboutMenu = get_node(aboutMenu) as Control



func _ready():
	Events.connect("new_game_requested", self, "_on_new_game_requested")
	Events.connect("about_menu_requested", self, "_on_about_menu_requested")
	Events.connect("main_menu_requested", self, "_on_main_menu_requested")
	Events.connect("game_over_requested", self, "_on_game_over_menu_requested")

func hide_all_menus():
	mainMenu.hide()
	aboutMenu.hide()
	gameOverMenu.hide()

func show_menu_ui(node : Control):
	if Game.state == Game.states.DIALOGUE:
		Events.emit_signal("dialogue_ended")
		
	get_tree().paused = true

	hide_all_menus()
	node.show()
	show()

func hide_menu_ui():
	get_tree().paused = false
	hide()
	
func _on_new_game_requested():
	hide_menu_ui()

func _on_main_menu_requested():
	show_menu_ui(mainMenu)

func _on_about_menu_requested():
	show_menu_ui(aboutMenu)
	
func _on_game_over_menu_requested(_win):
	show_menu_ui(gameOverMenu)


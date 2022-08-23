extends Node

var previous_game_state


var levels : Dictionary = {}
var new_game_level := "TowerDayOne"
var next_level := ""

export(NodePath) onready var world = get_node(world) as Node2D
export(NodePath) onready var levelTransitionAnimPlayer = get_node(levelTransitionAnimPlayer) as AnimationPlayer

func _ready():
	# TODO: enable later? annoying while debugging...
#	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	get_parent().connect("ready", self, "_on_parent_ready")
	
	clear_loaded_level()
	setup_level_instances()
	
	Events.connect("new_game_requested", self, "_on_new_game_requested")
	Events.connect("restart_game_requested", self, "_on_restart_game_requested")
	Events.connect("game_state_requested", self, "_on_game_state_requested")
	Events.connect("game_state_exit_requested", self, "_on_game_state_exit_requested")
	Events.connect("game_state_changed", self, "_on_game_state_changed")
	Events.connect("quit_requested", self, "_on_quit_requested")
	Events.connect("current_interactable_change_requested", self, "_on_current_interactable_change_requested")
	Events.connect("change_level_requested", self, "_on_change_level_requested")
	
	call_deferred("show_main_menu")

	
	Events.emit_signal("game_manager_ready")


func setup_level_instances():
	levels = {
		"TowerDayOne": load("res://levelmaps/towerdayone.tscn").instance(),
		"ForestDayOne": load("res://levelmaps/forestdayone.tscn").instance(),
		"GreatTreeDayOne": load("res://levelmaps/greattreedayone.tscn").instance(),
		"TowerDayTwo": load("res://levelmaps/towerdaytwo.tscn").instance(),
		"ForestDayTwo": load("res://levelmaps/forestdaytwo.tscn").instance(),
		"GreatTreeDayTwo": load("res://levelmaps/greattreedaytwo.tscn").instance(),
	}


func _on_current_interactable_change_requested(node : Node2D):
	var previous_interactable = Game.current_interactable
	
	if node == previous_interactable:
		return
	
	Game.current_interactable = node
	Events.emit_signal("current_interactable_changed", previous_interactable, node)


func show_main_menu():
	if OS.has_feature("web"):
		get_tree().call_group("hide_on_web", "hide")
	Events.emit_signal("main_menu_requested")


func new_game():
	Events.emit_signal("change_level_requested", new_game_level)
	Game.game_started = true
	

func restart_game():
	get_tree().paused = false
	reset_levels()
	Game.Ink.reset_story()
	Game.Inventory.reset_inventory()
	Events.emit_signal("main_menu_requested")
	


# LEVEL LOADING FUNCTIONS
func load_level(level_name : String):
	Events.emit_signal("level_changing", level_name)
	yield(Events, "faded_to_black")
	
#	print("anim player playing: %s" % levelTransitionAnimPlayer.is_playing())
#
	var current_level = null
	if Game.current_level:
		current_level = levels[Game.current_level]
		if current_level != world.get_child(0):
			print("ERROR: Current level is different from loaded level")
			return
		unload_level(current_level, level_name)
	else:
		load_new_level(level_name)


func unload_level(current_level, new_level_name):
	current_level.connect("tree_exited", self, "_on_level_unloaded", [new_level_name])
	Events.emit_signal("level_unloading", Game.current_level)
	world.remove_child(current_level)

func load_new_level(level_name : String):
	Events.emit_signal("level_loading", level_name)
	var new_level = levels[level_name]
	if new_level.first_load_complete:
		levels[level_name].connect("tree_entered", self, "_on_level_loaded")
	else:
		levels[level_name].connect("ready", self, "_on_level_loaded")
	world.call_deferred("add_child", levels[level_name])
	Game.current_level = level_name

func level_setup():
	Game.Ink.refresh_entity_states()
	disconnect_level_signals()
	Events.emit_signal("game_state_requested", Game.states.WORLD)
#	yield(get_tree().create_timer(0.5), "timeout")
	

func disconnect_level_signals():
	for key in levels.keys():
		var level : Node = levels[key]
		if level.is_connected("ready", self, "_on_level_loaded"):
			level.disconnect("ready", self, "_on_level_loaded")
		if level.is_connected("tree_entered", self, "_on_level_loaded"):
			level.disconnect("tree_entered", self, "_on_level_loaded")
		if level.is_connected("tree_exited", self, "_on_level_unloaded"):
			level.disconnect("tree_exited", self, "_on_level_unloaded")

func reset_levels():
	clear_loaded_level()
	for key in levels.keys():
		levels[key].queue_free()
	setup_level_instances()
	

func clear_loaded_level():
	for child in world.get_children():
		child.queue_free()
	Game.current_level = ""


func _on_level_unloaded(new_level : String):
	Events.emit_signal("level_unloaded", Game.current_level)
	load_new_level(new_level)

func _on_level_loaded():
	Events.emit_signal("level_loaded", Game.current_level)
	level_setup()



func change_game_state(to_state):
	var from_state = Game.state
	if from_state == to_state:
		return
	
	previous_game_state = from_state
	Events.emit_signal("game_state_changed", from_state, to_state)


func exit_game_state():
	change_game_state(previous_game_state)


func _world_game_state():
	get_tree().paused = false

func _dialogue_game_state():
	get_tree().paused = true

func _panel_game_state():
	get_tree().paused = true

func _menu_game_state():
	get_tree().paused = true


func _on_LoseGameArea_body_entered(body):
	Events.emit_signal("game_over_requested", false)

func _on_WinGameArea_body_entered(body):
	Events.emit_signal("game_over_requested", true)


func _on_new_game_requested():
	new_game()
	
func _on_restart_game_requested():
	restart_game()

func _on_quit_requested():
	get_tree().quit()


func _on_game_state_requested(state):
	change_game_state(state)

func _on_game_state_exit_requested():
	exit_game_state()	

func _on_game_state_changed(from_state, to_state):
	if from_state == to_state:
		return
	Game.state = to_state
	
	match to_state:
		Game.states.WORLD:
			_world_game_state()
		Game.states.DIALOGUE:
			_dialogue_game_state()
		Game.states.PANEL:
			_panel_game_state()
		Game.states.MENU:
			_menu_game_state()

func _on_change_level_requested(level_name):
	load_level(level_name)



func _on_parent_ready():
	Events.emit_signal("main_scene_ready")

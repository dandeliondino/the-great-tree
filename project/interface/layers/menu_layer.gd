extends InterfaceLayer

export(NodePath) onready var mainMenu = get_node(mainMenu) as Control
export(NodePath) onready var gameOverMenu = get_node(gameOverMenu) as Control
export(NodePath) onready var aboutMenu = get_node(aboutMenu) as Control
export(NodePath) onready var pauseMenu = get_node(pauseMenu) as Control

export(NodePath) onready var menuMusicPlayer = get_node(menuMusicPlayer) as AudioStreamPlayer

onready var tween = $Tween
var normal_db
var transition_duration = 3.00
var transition_type = 1

var menus : Array

func _ready():
	
	layer_game_state = Game.states.MENU
	menus = [mainMenu, gameOverMenu, aboutMenu, pauseMenu]
	normal_db = menuMusicPlayer.volume_db
	
	_connect_signals()
	

func _process_unhandled_input(event : InputEvent):
	if event.is_action_pressed("ui_cancel"):
		if pauseMenu.visible:
			Events.emit_signal("game_state_exit_requested")
		elif aboutMenu.visible:
			Events.emit_signal("main_menu_requested")
		elif gameOverMenu.visible:
			Events.emit_signal("main_menu_requested")


func _connect_signals():
	Events.connect("pause_menu_requested", self, "_on_pause_menu_requested")
	Events.connect("about_menu_requested", self, "_on_about_menu_requested")
	Events.connect("main_menu_requested", self, "_on_main_menu_requested")
	Events.connect("game_over_win_requested", self, "_on_game_over_menu_requested")
	Events.connect("game_over_lose_requested", self, "_on_game_over_menu_requested")
	
func show_menu(control : Control):
	Events.emit_signal("game_state_requested", Game.states.MENU)
	for menu in menus:
		if menu == control:
			menu.show()
		else:
			menu.hide()

func hide_all_menus():
	for menu in menus:
		menu.hide()

func play_music():
	if !menuMusicPlayer.playing:
		menuMusicPlayer.play()
	yield(get_tree().create_timer(0.5), "timeout")
	tween.remove_all()
	menuMusicPlayer.volume_db = normal_db
	menuMusicPlayer.stream_paused = false

func stop_music():
	fade_out()

func fade_out():
	tween.interpolate_property(menuMusicPlayer, "volume_db", menuMusicPlayer.volume_db, -80, transition_duration, transition_type, Tween.EASE_IN, 0)
	tween.start()
	yield(tween, "tween_all_completed")
	menuMusicPlayer.stream_paused = true


func _game_state_entered():
	play_music()

func _game_state_exited():
	stop_music()

func _on_main_menu_requested():
	show_menu(mainMenu)

func _on_about_menu_requested():
	show_menu(aboutMenu)

func _on_game_over_menu_requested():
	show_menu(gameOverMenu)

func _on_pause_menu_requested():
	show_menu(pauseMenu)

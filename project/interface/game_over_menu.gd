extends Control

onready var audioPlayer = $AudioStreamPlayer
onready var winLabel = $WinLabel

var win_music = preload("res://interface/audio/pickup3.ogg")
var lose_music = preload("res://interface/audio/lose2.ogg")

func _ready():
	Events.connect("game_over_requested", self, "_on_game_over_menu_requested")


func _set_up_menu(win : bool):
	if win:
		audioPlayer.stream = win_music
		winLabel.text = "You won"
	else:
		audioPlayer.stream = lose_music
		winLabel.text = "You lost"
	audioPlayer.play()

func _on_game_over_menu_requested(win : bool):
	_set_up_menu(win)

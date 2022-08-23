extends AudioStreamPlayer


var normal_db
var transition_duration = 1.00
var transition_type = 1

onready var tween = $Tween

func _ready():
	Events.connect("game_state_changed", self, "_on_game_state_changed")
	normal_db = volume_db

func fade_out():
	tween.interpolate_property(self, "volume_db", volume_db, -80, transition_duration, transition_type, Tween.EASE_IN, 0)
	tween.start()
	yield(tween, "tween_all_completed")
	stream_paused = true
	

func _on_game_state_changed(from_state, to_state):
	# only start background music in world
	if to_state == Game.states.WORLD:
		volume_db = normal_db
		if !playing:
			playing = true
		if stream_paused:
			stream_paused = false
#		elif stream_paused:
#			print("calling fade in")
#			fade_in()
	
	# pause background music for any state other than world or dialogue
	elif to_state != Game.states.DIALOGUE:
		if playing and !stream_paused:
			fade_out()

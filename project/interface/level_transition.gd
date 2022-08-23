extends CanvasLayer

export(NodePath) onready var animPlayer = get_node(animPlayer) as AnimationPlayer

func _ready():
	visible = true
	animPlayer.play("RESET")
	Events.connect("level_changing", self, "_on_level_changing")
	Events.connect("level_loaded", self, "_on_level_loaded")


func _on_level_changing(_args=null):
	animPlayer.play("fade_to_black")
	yield(animPlayer, "animation_finished")
	Events.emit_signal("faded_to_black")
	
func _on_level_loaded(_args=null):
	if animPlayer.is_playing():
		animPlayer.queue("fade_to_game")
	else:
		animPlayer.play("fade_to_game")
	yield(animPlayer, "animation_finished")
	Events.emit_signal("faded_to_game")

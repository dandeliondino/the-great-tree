extends ReferenceRect


func _ready():
	Game.player_camera.set_limits_from_rect(self)

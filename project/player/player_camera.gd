extends Camera2D


func _ready():
	Game.player_camera = self

func set_limits_from_rect(rect : ReferenceRect):
	limit_top = int(rect.rect_position.x)
	limit_left = int(rect.rect_position.y)
	limit_bottom = int(rect.rect_position.y) + int(rect.rect_size.y)
	limit_right = int(rect.rect_position.x) + int(rect.rect_size.x)
	

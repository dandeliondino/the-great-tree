extends ScrollContainer

func _input(event):
	if !scroll_vertical_enabled:
		return
	
	if event.is_action_pressed("ui_up"):
		scroll_vertical -= 16
		update()
			
	if event.is_action_pressed("ui_down"):
		scroll_vertical += 16
		update()
		
		

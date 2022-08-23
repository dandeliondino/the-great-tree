extends Label




func _on_Timer_timeout():
	$AnimationPlayer.play("FadeOut")

func _on_AnimationPlayer_animation_finished(_anim_name):
	queue_free()

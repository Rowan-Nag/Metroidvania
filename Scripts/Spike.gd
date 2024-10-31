extends Sprite2D

func _on_area_2d_body_entered(body):
	if (body == Global.player): 
		body.take_damage(1, Vector2.ZERO)
		Global.Game.fade_animation_player.play("fade_out")
		await Global.Game.fade_animation_player.animation_finished
		Global.Game.reset_player_to_checkpoint()
		Global.activeCamera.reset_smoothing() # forces the camera back to the player. Otherwise, it can be seen 'swiping' back.
		Global.Game.fade_animation_player.play("fade_in")
	if (body is Enemy):
		body.take_damage(100)

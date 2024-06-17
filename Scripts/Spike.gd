extends Sprite2D

func _on_area_2d_body_entered(body):
	if (body is Player): 
		body.take_damage(1, Vector2.ZERO)
		Global.Game.fade_animation_player.play("fade_out")
		await get_tree().create_timer(0.1).timeout
		Global.Game.fade_animation_player.play("fade_in")
		Global.Game.reset_player_to_checkpoint()

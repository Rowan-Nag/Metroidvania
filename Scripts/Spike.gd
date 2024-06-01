extends Sprite2D

func _on_area_2d_body_entered(body):
	if (body is Player): 
		Global.Game.reset_player_to_checkpoint()

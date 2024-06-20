extends Area2D



func _on_body_exited(body):
	if (body is Player):
		#Game.last_safe_position = body.position
		Global.Game.last_safe_position = position + Vector2(0, -16) # 8 pixels above the tile
		#print(body.position)

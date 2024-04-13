extends Node2D

@export var nextScene : PackedScene




func _on_area_2d_body_entered(body):
	if body is Player:
		Game.load_new_scene(nextScene)

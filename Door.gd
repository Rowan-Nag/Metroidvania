extends Area2D

@export_file var target_scene_path : String
@onready var exit_marker : Node2D = $Marker2D

func _on_body_entered(body):
	print('entered door' + name)
	Global.Game.load_new_scene(target_scene_path, name)

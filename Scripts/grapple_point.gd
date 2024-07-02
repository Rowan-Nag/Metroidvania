class_name GrapplePoint
extends Area2D

var is_enemy : bool = false
var is_movable : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_parent() is Enemy:
		is_enemy = true
		is_movable = true




func _on_area_entered(area):
	print('yeah')
	$Sprite2D.visible = true


func _on_area_exited(area):
	$Sprite2D.visible = false

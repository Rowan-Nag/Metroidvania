class_name GrapplePoint
extends Area2D

var is_enemy : bool = false
var is_parent_movable : bool = false
var parent : Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_parent() is Enemy:
		is_enemy = true
		is_parent_movable = true
		parent = get_parent()



func _on_area_entered(area):
	
	$Sprite2D.visible = true


func _on_area_exited(area):
	$Sprite2D.visible = false

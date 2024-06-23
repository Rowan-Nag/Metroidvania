class_name CameraBounds
extends Area2D

@onready var collisionShape : CollisionShape2D = $CollisionShape2D

@export var bound_by_left : bool = true
@export var bound_by_top : bool = true
@export var bound_by_right : bool = true
@export var bound_by_bottom : bool = true

func _on_body_entered(body):
	if body is Player:

		var camera : Camera2D = Global.activeCamera
		var rect : Rect2 = collisionShape.shape.get_rect()
		# rect.position: Vector2 = top left point, usually..
		# rect.end: Vector2 = bottom right point, usually...
		var top_left : Vector2 = to_global(rect.position)
		var bot_right : Vector2 = to_global(rect.end)
		
		if(bound_by_left):
			camera.set_limit(SIDE_LEFT, top_left.x)
		else:
			camera.set_limit(SIDE_LEFT, -1e7)
		
		if(bound_by_top):
			camera.set_limit(SIDE_TOP, top_left.y)
		else:
			camera.set_limit(SIDE_TOP, -1e7)
			
		if(bound_by_right):
			camera.set_limit(SIDE_RIGHT, bot_right.x)
		else:
			camera.set_limit(SIDE_RIGHT, 1e7)
		
		if(bound_by_bottom):
			camera.set_limit(SIDE_BOTTOM, bot_right.y)
		else:
			camera.set_limit(SIDE_BOTTOM, 1e7)

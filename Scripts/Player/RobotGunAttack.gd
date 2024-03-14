extends AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	# Waits until it's finished
	await animation_finished
	# Deletes Itself
	queue_free()

func _on_area_2d_body_entered(body):
	if(body is Enemy):
		var knockBackDir= sign(body.global_position.x-global_position.x)*500
		body.take_damage(10, knockBackDir)

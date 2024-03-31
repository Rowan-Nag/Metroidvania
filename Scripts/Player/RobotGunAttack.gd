extends AnimatedSprite2D

var damage = 10
var knockbackMultiplier = 1
# Called when the node enters the scene tree for the first time.
func _ready():
	# Waits until it's finished
	await animation_finished
	# Deletes Itself
	queue_free()

func _on_area_2d_body_entered(body):
	if(body is Enemy):
		var knockBackDir= sign(body.global_position.x-global_position.x)*500 * knockbackMultiplier
		body.take_damage(damage, knockBackDir)

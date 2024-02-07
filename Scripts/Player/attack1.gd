extends AnimatedSprite2D

@onready var hitParticles = preload("res://Particles/attack_particles.tscn")
@onready var attackRay = $RayCast2D
# Called when the node enters the scene tree for the first time.
func _ready():
	awaitCompletion() # Awaits to remove itself (putting it in a function like this starts it as a coroutine)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func awaitCompletion():
	# Waits until it's finished
	await animation_finished
	# Deletes Itself
	queue_free()


func _on_area_2d_body_entered(body):
	var hitEnemy = false
	if(body is Enemy):
		var knockBackDir= sign(body.global_position.x-global_position.x)*500
		body.take_damage(10, knockBackDir)
		hitEnemy = true
#	attackRay.set_target_position(to_local(body.global_position))
	attackRay.force_raycast_update()
	if(attackRay.is_colliding()):

		var hit = hitParticles.instantiate()
		add_child(hit)
		hit.position = to_local(attackRay.get_collision_point())
#		print(to_local(hit.position))
		hit.direction = -attackRay.target_position
		if(hitEnemy):
			hit.color = Color.RED
			hit.scale_amount_min = 5

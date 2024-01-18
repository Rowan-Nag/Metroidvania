extends CPUParticles2D


# Called when the node enters the scene tree for the first time.
func _ready():
	emitting = true
	
	killMyself()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func killMyself():
	# Waits until it's particles have dissapeared 
	await get_tree().create_timer(lifetime).timeout
	# Deletes Itself
	queue_free()

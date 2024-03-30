extends Node2D
var parentCamera : Camera2D
var shake_speed : float = 20
var shake_strength : float = 0
var shake_decay_rate : float = 1
var noise_i : float = 0
var noise = FastNoiseLite.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	if(get_parent() is ControllableCamera):
		parentCamera = get_parent()
	else:
		push_warning("WARNING: Trying to add camera_shake to a non-ControllableCamera. u should add the controllablecamrea script to that camera.")
		queue_free()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.frequency = 2


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	shake_strength = lerpf(shake_strength, 0, shake_decay_rate * delta)
	parentCamera.offset += get_noise_offset(delta)
	#print(shake_strength)
	#Global.set_debug_text("Shake strength: " + str(shake_strength))
	
	if(shake_strength < 1):
		queue_free()
		

func get_noise_offset(delta : float):
	noise_i += delta * shake_speed
	return Vector2(
		noise.get_noise_2d(0, noise_i) * shake_strength,
		noise.get_noise_2d(10,noise_i) * shake_strength
	)

extends Node2D
var parent : Node2D
var shake_speed : float = 20
var shake_strength : float = 0
var shake_decay_rate : float = 1
var noise_i : float = 0

var use_position_instead_of_offset = false

var noise = FastNoiseLite.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	if (get_parent()):
		parent = get_parent()
	else:
		queue_free()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.frequency = 2


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	shake_strength = lerpf(shake_strength, 0, shake_decay_rate * delta)
	if use_position_instead_of_offset:
		parent.position = get_noise_offset(delta)
	else:
		parent.offset = get_noise_offset(delta)
	#print(shake_strength)
	#Global.set_debug_text("Shake strength: " + str(shake_strength))
	#print(parent.offset, get_noise_offset(delta))
	if(shake_strength < 1):
		queue_free()
		

func get_noise_offset(delta : float):
	noise_i += delta * shake_speed
	return Vector2(
		noise.get_noise_2d(0, noise_i) * shake_strength,
		noise.get_noise_2d(10,noise_i) * shake_strength
	)

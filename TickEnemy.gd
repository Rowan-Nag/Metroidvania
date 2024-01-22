extends Enemy

@onready var jumpTimer : Timer= $jumpTimer
var direction = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	velocity.x = 0
	
	
	
	velocity.y += 1500*delta
	velocity.x = direction*150
	if(is_on_floor()):
		direction = 0
	if(is_on_floor() and jumpTimer.is_stopped()):
		print("jump!")
		velocity.y = -500
		jumpTimer.start(randf_range(0.5, 3))
		direction = (randi_range(0, 1)*2-1)
	handle_knockback(delta)
	move_and_slide()

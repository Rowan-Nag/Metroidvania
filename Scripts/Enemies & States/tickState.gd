extends State

@onready var jumpTimer : Timer= $jumpTimer
var direction = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	parent.velocity.x = 0
	
	
	
	parent.velocity.y += 1500*delta
	parent.velocity.x = direction*150
	if(parent.is_on_floor()):
		direction = 0
	if(parent.is_on_floor() and jumpTimer.is_stopped()):
		#print("jump!")
		parent.velocity.y = -500
		jumpTimer.start(randf_range(0.5, 3))
		direction = (randi_range(0, 1)*2-1)
	parent.handle_knockback(delta)
	parent.move_and_slide()

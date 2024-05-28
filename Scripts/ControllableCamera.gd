extends Camera2D
class_name ControllableCamera

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.activeCamera = self
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	offset = Vector2.ZERO
	# Every frame, reset the offset.
	# Later in the same frame call, the offset will be modified by children.
	# See camera_shake.gd

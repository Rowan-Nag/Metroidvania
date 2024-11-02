extends GPUParticles2D

func _ready():
	visible = true

func _physics_process(delta):
	position = Global.activeCamera.global_position + Vector2(0, -200)

extends GPUParticles2D

@onready var lightning_anims : AnimationPlayer = $lightning_animationplayer
@onready var lightning_timer : Timer = $lightning_timer

@export var lightning_on : bool = true

func _ready():
	emitting = true
	visible = true
	lightning_timer.paused = not lightning_on

func _physics_process(delta):
	position = Global.activeCamera.global_position + Vector2(0, -200)

func lightning_flash():
	lightning_anims.play("lightning_flash")
	Global.flicker_all_lights.emit()

func _on_lightning_timer_timeout():
	lightning_flash()
	lightning_timer.start(randi_range(20, 40))
	

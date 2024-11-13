extends GPUParticles2D

@onready var lightning_anims : AnimationPlayer = $lightning_animationplayer
@onready var lightning_timer : Timer = $lightning_timer
@onready var thunder_player : AudioStreamPlayer = $thunder_player

@export var lightning_on : bool = true

@export var thunder_close : AudioStream
@export var thunder_far : AudioStream


func _ready():
	emitting = true
	visible = true
	lightning_timer.paused = not lightning_on

func _physics_process(delta):
	position = Global.activeCamera.global_position + Vector2(0, -200)
	if(Input.is_action_just_pressed("Shield")):
		lightning_timer.timeout.emit()
		
func lightning_flash():
	lightning_anims.play("lightning_flash")
	Global.flicker_all_lights.emit()

func _on_lightning_timer_timeout():
	lightning_flash()
	lightning_timer.start(randi_range(20, 40))
	if randi_range(0, 3) == 0:
		thunder_player.stream = thunder_close
		await get_tree().create_timer(0.1)
		thunder_player.play()
	else:
		thunder_player.stream = thunder_far
		await get_tree().create_timer(1.5)
		thunder_player.play()

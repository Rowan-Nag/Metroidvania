extends Node

@onready var lightning : AnimatedSprite2D = $lightningSprite
@onready var lightningTimer : Timer = $lightningTimer
@onready var ceilingChecker : RayCast2D = $ceilingChecker

var lightningParticles = preload("res://Particles/lightning_particles.tscn")
@export var lightningInterval : float = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	Global.set_debug_text("lightning Time: " + str(lightningTimer.time_left))
	if(lightningTimer.is_stopped()):
		
		prep_lightning_strike(0.2, 10) # 4 warnings spaced 1s apart
		lightningTimer.start(10000)
		
		
func prep_lightning_strike(interval : float, warnings : int):
	var sparks = warnings
	while(sparks >= 1):
		var lp = lightningParticles.instantiate()
		lp.position = Global.player.position
		lp.emitting = true
		add_child(lp)
		await get_tree().create_timer(interval).timeout
		#print("warning")
		sparks -=1
	lightning_strike(Global.player.position)
	lightningTimer.start(lightningInterval)
	
func get_player_cover():
	ceilingChecker.position = Global.player.position
	ceilingChecker.position.y -= 300 # move it above player 
	ceilingChecker.force_raycast_update()
	return ceilingChecker.get_collision_point()

func lightning_strike(pos):
	lightning.position = get_player_cover()
	lightning.visible = true
	lightning.play("default")
	await lightning.animation_finished
	lightning.visible = false


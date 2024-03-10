extends Node

@onready var lightning : AnimatedSprite2D = $lightningSprite
@onready var lightningTimer : Timer = $lightningTimer
@onready var ceilingChecker : RayCast2D = $ceilingChecker
@onready var lightningCollider : Area2D = $lightningSprite/Area2D

@onready var slowSparks : CPUParticles2D = $slowLightningParticles
@onready var mediumSparks : CPUParticles2D = $medLightningParticles
@onready var fastSparks : CPUParticles2D = $fastLightningParticles

## Time between lightning strikes
@export var lightningInterval : float = 20

## Time between lock-on and lightning strike
@export var lockOnDelay : float = 0.5

var lockedOn = false


# Will wait until player isn't under cover
# Then will start counting down
# Then will begin to 'charge' up.
# Locks position x seconds before firing
# Creates lightning_strike and hits player (or whatever position)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	ceilingChecker.position = Global.player.position # move it to the player
	ceilingChecker.position.y -= 300 # move it above player 


	

	
	Global.set_debug_text(str(lightningTimer.time_left))

	if (ceilingChecker.is_colliding()): # If the player is under cover, then restart the countdown.
		lightningTimer.start(lightningInterval)
		
		
	if (lightningTimer.time_left < lockOnDelay):
		
		slowSparks.emitting = false; # Stop all sparks and start a strike.
		mediumSparks.emitting = false;
		fastSparks.emitting = false;
		
		if (!lockedOn): # If we're not already locked-on and firing, we begin a lightning strike.
			lightning_strike(Global.player.position, lockOnDelay)
			lockedOn = true
		
	elif (lightningTimer.time_left < lightningInterval * 1/4): # at 1/4 time left
		
		fastSparks.position = Global.player.position
		fastSparks.emitting = true; # Start fast sparks
		slowSparks.emitting = false;
		mediumSparks.emitting = false;
	
	elif (lightningTimer.time_left < lightningInterval * 2/4): # at 2/4 time left
		
		mediumSparks.position = Global.player.position
		mediumSparks.emitting = true; # Start medium sparks
		slowSparks.emitting = false;
		fastSparks.emitting = false;
	
	elif (lightningTimer.time_left < lightningInterval * 3/4): # at 3/4 time left
		slowSparks.position = Global.player.position
		slowSparks.emitting = true; # Start slow sparks
		mediumSparks.emitting = false;
		fastSparks.emitting = false;
	
	else: 
		slowSparks.emitting = false; # Stop all sparks
		mediumSparks.emitting = false;
		fastSparks.emitting = false;
	
	
#func charge_lightning_strike(interval : float, warnings : int):
	#var sparks = warnings
	#while(sparks >= 1):
		#var lp = lightningParticles.instantiate()
		#lp.position = Global.player.position
		#lp.emitting = true
		#add_child(lp)
		#await get_tree().create_timer(interval).timeout
		##print("warning")
		#sparks -=1
	#lightning_strike(Global.player.position)
	#lightningTimer.start(lightningInterval)
	#
#func get_player_cover():
	#
	#ceilingChecker.force_raycast_update()
	#return ceilingChecker.get_collision_point()

func lightning_strike(position, delay):
	await get_tree().create_timer(delay).timeout # This basically acts as a lock-on delay
	
	lightningTimer.start(lightningInterval) # Restart lightning timer
	lightningCollider.monitoring = false # Enable hitbox
	
	lightning.position = position # Move lightning to player, make it visible, and play it's animation.
	lightning.visible = true
	lightning.play("default")
	
	await lightning.animation_finished # When it's done, we hide it again and reset states & hide lightning.
	
	lightningCollider.monitoring = true
	lightning.visible = false
	lockedOn = false



func _on_collider_body_entered(body): # Signal - connected by Area2D Node
	if(body.has_meta("take_damage")):
		body.take_damage(10, body.position-lightning.position)

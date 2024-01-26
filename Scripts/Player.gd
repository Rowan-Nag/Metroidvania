extends CharacterBody2D
class_name Player

var maxHealth : int = 6
var health : int = 6


@export var gravity : int = 1600
const terminal_velocity : int = 1000
var jumping : bool = false
var attacking : bool = false
#var knockbackDir : Vector2 = Vector2.ZERO

var direction = 1

@export var SPEED = 400.0
@export var JUMP_VELOCITY = -640
#@onready var jumpDuration = $jumpTimer
# Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var stunTimer : Timer = $stunTimer 
@onready var immunityTimer : Timer = $immunityTimer
@onready var RayRight : RayCast2D = $RayRight
@onready var RayLeft : RayCast2D = $RayLeft

@onready var jumpParticles = preload("res://Particles/jump_particles.tscn")
@onready var attack1 = preload("res://attack1.tscn")

func _physics_process(delta):
	
	# Get Input Direction
	var inputDir : float = Input.get_axis("Left", "Right")
	
	# Add the gravity.
	
	if not is_on_floor():
		velocity.y += gravity * delta
		clamp(velocity.y, -terminal_velocity, 1e9)
		if Input.is_action_just_pressed("Jump") and not is_on_floor(): 
			# For Wall jumps
			if (RayRight.is_colliding() and inputDir > 0):
				velocity.y = JUMP_VELOCITY*0.8
				velocity.x = JUMP_VELOCITY*0.6
				stunTimer.start(0.15)
			elif (RayLeft.is_colliding() and inputDir < 0):
				velocity.y = JUMP_VELOCITY*0.8
				velocity.x = -JUMP_VELOCITY*0.6
				stunTimer.start(0.15)
		
	# Handle Jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
#		jumpDuration.start(0.1)
		
		# Create particles. jump_particle.tscn contains self-termination.
		var jp = jumpParticles.instantiate()
		jp.direction = -velocity
		add_child(jp)
		
		jumping = true
	if Input.is_action_just_released("Jump") and stunTimer.is_stopped():
		jumping = false
		if(velocity.y < 0):
			velocity.y *= 0.7
	if Input.is_action_just_pressed("Attack") and stunTimer.is_stopped():
		attack()
		
	
		
		
	# Get the input direction and handle the movement/deceleration.
	if not stunTimer.is_stopped():
		velocity.x = move_toward(velocity.x, 0, delta * SPEED/1) # delta * SPEED/x : takes x seconds to reach nmax speed from 0  
		#If you're stunned (like from being hit,) your breaking is much slower).
	elif inputDir:
		#Acceleration
		direction = inputDir
		velocity.x = move_toward(velocity.x, inputDir * SPEED, delta * SPEED / 0.05) # delta * SPEED/x : takes x seconds to reach nmax speed from 0  

	else:
		#Breaking w/o input
		velocity.x = move_toward(velocity.x, 0, delta * SPEED/0.1) # delta * SPEED/x : takes x seconds to reach nmax speed from 0  
	
	
	# Use Player.knockback(knockback) to knock back the player. This lerp (move_towards) function can simulate an impulse (P=F*dt)  which decays (due to braking & resistance) on the player
#	knockbackDir = knockbackDir.move_toward(Vector2.ZERO, delta * SPEED) # delta * x     higher x -> more knockback resistance
#	if(knockbackDir != Vector2.ZERO):
#		print(knockbackDir)
	move_and_slide()
	
	
		
	# ANIMATIONS
	if(attacking):
		animated_sprite.play("attacking")
	
	elif(direction): # or other states with an animation priority
		if(direction < 0):
			animated_sprite.play("default") #Left
			animated_sprite.scale.x = -abs(animated_sprite.scale.x)
		if(direction > 0):
			animated_sprite.scale.x = abs(animated_sprite.scale.x)
			animated_sprite.play("default") #Right
	else:
		animated_sprite.play("default") #Idle
	
	if(not stunTimer.is_stopped()):
		modulate = Color.RED
	else:
		modulate = Color.WHITE
func attack():
	var attack = attack1.instantiate()
	add_child(attack)
	
	if(direction < 0):
		attack.scale.x = -attack.scale.x
		attack.position.x = -20
	animated_sprite.play("attacking")
	attacking = true
	
	await get_tree().create_timer(0.3).timeout
	
	attacking = false
	
func take_damage(damage, knockbackVec : Vector2 = Vector2.ZERO):
	if(immunityTimer.is_stopped()):
		health -= damage
		immunityTimer.start(0.4)
		stunTimer.start(0.3)
		knockback(knockbackVec)

	
func knockback(knockback : Vector2):
#	print("knockback:", knockback)
	velocity = knockback*400
#	knockbackDir = knockback*100

#	knockbackDir += knockback

func stun(stun : float):
	stunTimer.start(stun)

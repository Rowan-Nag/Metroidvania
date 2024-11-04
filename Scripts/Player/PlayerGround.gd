extends State

var fall_state: State
var jump_state: State
var dash_state: State
var attack_state : State
var shield_state : State

@export var gravityMultiplier: float = 1
@export var dragMultiplier: float = 1
@export var accelerationMultiplier: float = 1
@export var moveSpeedMultiplier: float = 1
@export var coyoteTime : float = 0.1

@export var footstep_sound : AudioStream

@onready var ground_particles = preload("res://Particles/player_ground_particles.tscn")

@onready var coyoteTimer : Timer = $coyoteTimer

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * gravityMultiplier

var inputDir: float

func enter() -> void:
	fall_state = parent.fall_state
	jump_state = parent.jump_state
	dash_state = parent.dash_state
	attack_state = parent.attack_state
	shield_state = parent.shield_state
	
	super()

func exit():
	parent.stop_passive()

func process_input(event: InputEvent) -> State:
	if Input.is_action_just_pressed('Dash'):
		return parent.backdodge_state
	if Input.is_action_just_pressed("Attack") and parent.attackCooldown.is_stopped():
		return parent.get_selected_state()
	if Input.is_action_just_pressed("Shield"):
		return shield_state
	if Input.is_action_just_pressed("Rocket"):
		return parent.shoot_state
	#if Input.is_action_just_pressed("Grapple"):
		#return parent.grapple_state
	return null

func process_physics(delta: float) -> State:
	# Physics
	var drag = parent.drag * dragMultiplier
	var acceleration = parent.acceleration*accelerationMultiplier
	var maxSpeed = parent.moveSpeed * moveSpeedMultiplier
	
	inputDir = Input.get_axis("Left", "Right")
	
	if(inputDir/parent.velocity.x < 0):
		#If the player is pushing the opposite direction (turning around), double the acceleration.
		acceleration *= 2
	
	if(inputDir):
		if parent.velocity.length() < 5.00:
			emit_ground_particles()
			
		parent.velocity.x = move_toward(parent.velocity.x, inputDir*maxSpeed, acceleration*delta)
	else:
		parent.velocity.x = move_toward(parent.velocity.x, 0, drag*delta)
	
	if parent.is_jump_buffered() and not coyoteTimer.is_stopped():
		return jump_state
	
	parent.move_and_slide()
	
	# Animations
	if(inputDir == 0):
		play_animation("idle")
		parent.stop_passive()
	else:
		play_animation("walk")
		parent.play_passive(footstep_sound, 2.2)
		parent.animations.scale.x = sign(inputDir) * abs(parent.animations.scale.x)
		
	
	# State switches
	if(parent.is_on_floor()):
		coyoteTimer.start(coyoteTime)
		
	if !parent.is_on_floor() and (coyoteTimer.is_stopped() or inputDir==0):
		return fall_state
	
	
	
	Global.set_debug_text("Remaining coyote time: " + str(int(coyoteTimer.time_left*1000))+"ms")
	return null

func emit_ground_particles():
	var particles : CPUParticles2D = ground_particles.instantiate()
	parent.animations.add_child(particles)

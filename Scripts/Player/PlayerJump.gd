extends State

var fall_state: State
var dash_state: State
var ground_state: State
var attack_state : State
var shoot_state : State

@export var gravityMultiplier: float = 1
@export var dragMultiplier: float = 1
@export var accelerationMultiplier: float = 1
@export var moveSpeedMultiplier: float = 1


@export var jump_velocity : int

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * gravityMultiplier

var inputDir: float

func enter() -> void:
	super()
	ground_state = parent.ground_state
	fall_state = parent.fall_state
	dash_state = parent.dash_state
	attack_state = parent.attack_state
	play_animation("jump")
	parent.velocity.y = -jump_velocity
	
func process_input(event: InputEvent) -> State:
	#if Input.is_action_just_pressed('Dash'):
		#return dash_state
	
	if not Input.is_action_pressed("Jump"):
		parent.velocity.y *= 0.6
		return fall_state
	if Input.is_action_just_pressed("Dash"):
		return dash_state
	if Input.is_action_just_pressed("Attack") and parent.attackCooldown.is_stopped():
		return parent.get_selected_state()
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
	
	#if(parent.velocity.y > -200): #
		#acceleration *= 1.2
	
	inputDir = Input.get_axis("Left", "Right")
	
	if(inputDir):
		parent.velocity.x = move_toward(parent.velocity.x, inputDir*maxSpeed, acceleration*delta)
	else:
		parent.velocity.x = move_toward(parent.velocity.x, 0, drag*delta)
	
	#Gravity (vertical movement)
	parent.velocity.y += gravity*gravityMultiplier*delta
	
	
	parent.move_and_slide()
	
	# Animations
	#if(inputDir == 0):
		#play_animation("idle")
	#else:
		#play_animation("walk")
		#parent.animations.scale.x = sign(inputDir)*abs(parent.animations.scale.x)
	
	# State switches
	if parent.velocity.y >= 0:
		return fall_state
	return null

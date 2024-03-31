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

func process_input(event: InputEvent) -> State:
	if Input.is_action_just_pressed('Dash'):
		return dash_state
	if Input.is_action_just_pressed("Attack"):
		return attack_state
	if Input.is_action_just_pressed("Shield"):
		return shield_state
	if Input.is_action_just_pressed("Rocket"):
		return parent.shoot_state
	
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
		parent.velocity.x = move_toward(parent.velocity.x, inputDir*maxSpeed, acceleration*delta)
	else:
		parent.velocity.x = move_toward(parent.velocity.x, 0, drag*delta)
	
	if parent.jump_buffered() and Input.is_action_pressed("Jump") and not coyoteTimer.is_stopped():
		return jump_state
	
	parent.move_and_slide()
	# Animations
	if(inputDir == 0):
		play_animation("idle")
	else:
		play_animation("walk")
		parent.animations.scale.x = sign(inputDir)*abs(parent.animations.scale.x)
	
	# State switches
	if(parent.is_on_floor()):
		coyoteTimer.start(coyoteTime)
		
	if !parent.is_on_floor() and (coyoteTimer.is_stopped() or inputDir==0):
		return fall_state
		
	Global.set_debug_text("Remaining coyote time: " + str(int(coyoteTimer.time_left*1000))+"ms")
	return null

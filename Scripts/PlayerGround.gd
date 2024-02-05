extends State

@export var fall_state: State
@export var jump_state: State
@export var dash_state: State

@export var gravityMultiplier: float = 1
@export var dragMultiplier: int = 1
@export var accelerationMultiplier: int = 1
@export var moveSpeedMultiplier: int

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * gravityMultiplier

var inputDir: float

func enter() -> void:
	super()

func process_input(event: InputEvent) -> State:
	if Input.is_action_just_pressed('Dash'):
		return dash_state
	if Input.is_action_just_pressed('Jump') and parent.is_on_floor():
		return jump_state
	
	
	
	
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
	
	parent.move_and_slide()
	# Animations
	if(inputDir == 0):
		play_animation("idle")
	else:
		play_animation("walk")
		parent.animations.scale.x = sign(inputDir)*abs(parent.animations.scale.x)
	
	# State switches
	if !parent.is_on_floor():
		return fall_state
	return null

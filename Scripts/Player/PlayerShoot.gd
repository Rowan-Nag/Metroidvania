extends State

@export var ground_state : State

@export var gravityMultiplier: float = 1
@export var floorDragMultiplier: float = 1
@export var airDragMultiplier: float = 1
#@export var accelerationMultiplier: float = 1
#@export var moveSpeedMultiplier: float

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * gravityMultiplier

@onready var gunAttack = preload("res://RobotGunAttack.tscn")
@onready var controlAnimation = $AnimationPlayer

@export var finished = false # Animation should set to true when it's done.

func shoot():
	var attack = gunAttack.instantiate()
	attack.position = parent.position
	attack.position.x += 15*parent.animations.scale.x
	attack.scale.x = sign(parent.animations.scale.x)
	add_child(attack)

func exitState():
	finished = true

func enter() -> void:
	ground_state = parent.ground_state
	
	finished = false
	controlAnimation.seek(0) # Reset to beginning
	controlAnimation.play("PlayerShootAnimation") # Start animation
	
	play_animation("shoot")

func exit() -> void:
	controlAnimation.seek(0)
	controlAnimation.pause()

func process_input(event: InputEvent) -> State:
	return null

func process_physics(delta: float) -> State:
	#Physics
	var drag = parent.drag
	if(parent.is_on_floor()):
		drag  = parent.drag * floorDragMultiplier
	else:
		drag = parent.drag * airDragMultiplier
		
		
	parent.velocity.x = move_toward(parent.velocity.x, 0, drag*delta)
	
	#Gravity (vertical movement)
	parent.velocity.y += gravity*gravityMultiplier*delta
	parent.velocity.y = clamp(parent.velocity.y, -10000, parent.terminal_velocity)
	
	parent.move_and_slide()
	
	# State change for is finished
	if(finished):
		return ground_state
	return null
	


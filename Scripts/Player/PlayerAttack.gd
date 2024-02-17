extends State

@export var fall_state : State
@export var ground_state : State

@export var gravityMultiplier: float = 1
@export var floorDragMultiplier: float = 1
@export var airDragMultiplier: float = 1
#@export var accelerationMultiplier: float = 1
#@export var moveSpeedMultiplier: float

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * gravityMultiplier

@onready var attack1 = preload("res://attack1.tscn")
var direction: float = 1
var attackFinished = false

func enter() -> void:
	super()
	ground_state = parent.ground_state
	fall_state = parent.fall_state
	attackFinished = false
	direction = sign(parent.animations.scale.x)
	play_animation("attack")
	attack()
	
	await get_tree().create_timer(0.1).timeout 
	attackFinished = true

func process_input(event: InputEvent) -> State:
	# No inputs while attacking
	
	
	
	
	
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
	
	# State switches
	if(attackFinished):
		if(parent.is_on_floor()):
			return ground_state
		else:
			return fall_state
	
	return null
	
	
func attack():
	var attack = attack1.instantiate()
	parent.add_child(attack)
	
	if(direction < 0):
		attack.scale.x = -attack.scale.x
		attack.position.x = -20

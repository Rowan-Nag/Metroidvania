extends State

@export var fall_state : State
@export var ground_state : State

@export var maxAttacks : int = 3
@export_range(0.1, 4) var attack_rate : float = 1
## @export var frames_before_attack : int = 1
@export var frames_after_attack : int = 1

@export var gravityMultiplier: float = 1
@export var floorDragMultiplier: float = 1
@export var airDragMultiplier: float = 1
@export var accelerationMultiplier: float = 1
@export var moveSpeedMultiplier: float = 1

@export_category("Animation Properties. Don't edit.")
var attackNum = 1
var attackBuffered : bool = false
@export var canAttackAgain : bool = false
@export var attackFinished = false

@onready var attackPropertyAnimation : AnimationPlayer = $AttackAnimationPlayer

var inputDir: float
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * gravityMultiplier

@onready var attack1 = preload("res://Player Scenes/attack1.tscn")

var direction: float = 1

func enter() -> void:
	super()
	ground_state = parent.ground_state
	fall_state = parent.fall_state
	#attackFinished = false
	#direction = sign(parent.animations.scale.x)
	attackNum = 1 # resetting to defaults
	attackFinished = false;
	canAttackAgain = false;
	attackBuffered = false;
	
	parent.animations.speed_scale = attack_rate
	attackPropertyAnimation.seek(0)
	attackPropertyAnimation.play("attack1")

	#play_animation("attack") 
	#attack()
	#await get_tree().create_timer((frames_after_attack) / (60.0)).timeout  
	#attackFinished = true

func exit() -> void:
	parent.animations.speed_scale = 1 # resetting it to default
	attackNum = 1
	attackFinished = false;
	canAttackAgain = false;
	attackBuffered = false;

func process_input(event: InputEvent) -> State:
	# No inputs while attacking
	if (Input.is_action_just_pressed("Attack")):
		attackBuffered = true
	
	
	
	return null

func process_physics(delta: float) -> State:
	#Physics
	var drag = parent.drag
	var acceleration = parent.acceleration*accelerationMultiplier
	var maxSpeed = parent.moveSpeed * moveSpeedMultiplier
	inputDir = Input.get_axis("Left", "Right")
	
	if (inputDir):
		attackBuffered = false #This stops player from sliding while multi-attacking. Remove if wanted.
	
	if(inputDir and parent.is_on_floor()):
		
		parent.velocity.x = move_toward(parent.velocity.x, inputDir*maxSpeed, acceleration*delta)
	else:
		if(parent.is_on_floor()):
			drag = parent.drag * floorDragMultiplier
		else:
			drag = parent.drag * airDragMultiplier
		
		
	parent.velocity.x = move_toward(parent.velocity.x, 0, drag*delta)
	
	#Gravity (vertical movement)
	parent.velocity.y += gravity*gravityMultiplier*delta
	parent.velocity.y = clamp(parent.velocity.y, -10000, parent.terminal_velocity)
	
	parent.move_and_slide()
	
	Global.set_debug_text("canAttackAgain: " + str(canAttackAgain))
	
	# State switches
	if (attackBuffered and canAttackAgain):
		#print("ANOTHER ATTACK")
		parent.attackCooldown.start()
		attackBuffered = false
		if(attackNum == 1):
			attackPropertyAnimation.play('attack2')
			
			attackNum = 2
		elif(attackNum == 2):
			attackPropertyAnimation.play('attack1')
			attackNum = 3
	
	if (attackFinished):
		attackNum = 1;
		attackFinished = false
		if(parent.is_on_floor()):
			return ground_state
		else:
			return fall_state
	
	return null
	

func push_player_forward(amount : int = 50):
	#sign(parent.animations.scale.x) * parent.velocity.x 
	#Negative if going backwards, pos if going forwards.
	#Magnitude represents velocity in that direction.
	
	# arrest player momentum if going in opposite direction
	if (sign(parent.animations.scale.x) * parent.velocity.x < -25):
		parent.velocity.x *= 0.5
	#push the player forward (as long as they're not movinng very quickly already)
	if (sign(parent.animations.scale.x) * parent.velocity.x < 30):
		parent.velocity.x += parent.animations.scale.x * amount
	# if the player is moving forward already, no need to give them extra vel.
	#parent.velocity.x += parent.animations.scale.x * amount
	
	
	

func attack(modulate : Color = Color.WHITE):
	Global.screen_shake()
	parent.attackCooldown.start()
	var attack : AnimatedSprite2D = attack1.instantiate()
	attack.speed_scale = attack_rate
	
	attack.selfKnockbackMultiplier = 0.5
	if(attackNum == 3):
		attack.speed_scale *= 0.3
		attack.knockbackMagnitude = 200
	parent.add_child(attack)
	
	attack.modulate = modulate
	
	if(sign(parent.animations.scale.x) < 0):
		attack.scale.x = -attack.scale.x

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
@onready var attack2 = preload("res://Player Scenes/attack2.tscn")
@onready var attack3 = preload("res://Player Scenes/attack3.tscn")

@onready var fire_particles = preload('res://fire_spurt_small.tscn')

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
	
	#if (inputDir):
		#attackBuffered = false #This stops player from sliding while multi-attacking. Remove if wanted.
	
	if(inputDir and attackNum == 1): 
		# attackNum == 1 Locks the player into attacking instead of moving
		# (forced into using the attack-momentum instead of movement-momentum) 
		
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
			attackPropertyAnimation.play('attack3')
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
	
	# Assume that if the player is holding the opposite direction, they do not want to be pushed forward.
	if (sign(inputDir) != -sign(parent.animations.scale.x)):
		#print("pushing player")
		# arrest player momentum if going in opposite direction
		if (sign(parent.animations.scale.x) * parent.velocity.x < -25):
			#print("Arrest velocity")
			parent.velocity.x *= 0.5
		#push the player forward (as long as they're not movinng very quickly already)
		if (sign(parent.animations.scale.x) * parent.velocity.x < 30):
			#print("Push forward")
			#print(parent.animations.scale.x * amount)
			parent.velocity.x += parent.animations.scale.x * amount
	# if the player is moving forward already, no need to give them extra vel.
	#parent.velocity.x += parent.animations.scale.x * amount
	
func get_ledge_snap_distance() -> float:
	parent.rayLedgeCheck1.force_raycast_update()
	if (parent.rayLedgeCheck1.is_colliding()):
		return 0
	parent.rayLedgeCheck2.force_raycast_update()
	if (parent.rayLedgeCheck2.is_colliding()):
		return 5
	parent.rayLedgeCheck3.force_raycast_update()
	if (parent.rayLedgeCheck3.is_colliding()):
		return 15
	parent.rayLedgeCheck4.force_raycast_update()
	if (parent.rayLedgeCheck4.is_colliding()):
		return 20
	return 25

func snap_parent_to_ledge():
	pass
	#parent.position.x -= get_ledge_snap_distance() * sign(parent.animations.scale.x)
	
func attack(modulate : Color = Color.WHITE):
	Global.screen_shake(3, 6, 3)
	#if(attackNum == 3):
		#Global.screen_shake()
	parent.attackCooldown.start()
	var attack : AnimatedSprite2D
	if attackNum == 1:
		attack = attack1.instantiate()
	if attackNum == 2:
		attack = attack2.instantiate()
	if attackNum == 3:
		attack = attack3.instantiate()
	attack.speed_scale = attack_rate
	
	attack.selfKnockbackMultiplier = 0.5
	if(attackNum == 3):
		attack.speed_scale *= 0.3
		attack.knockbackMagnitude = 200
	
		var particles = fire_particles.instantiate()
		particles.scale.x = parent.animations.scale.x
		parent.add_child(particles)
		attack.top_level = true
		attack.position = parent.position
	parent.add_child(attack)
	
	attack.modulate = modulate
	
	if(sign(parent.animations.scale.x) < 0):
		attack.scale.x = -attack.scale.x

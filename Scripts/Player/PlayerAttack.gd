extends State

var fall_state : State
var ground_state : State

@export var icon : Texture2D

@export_range(0, 4) var boost_multiplier : float = 1
@export var cooldown = 0.5
@export var maxAttacks : int = 3
@export_range(0.1, 4) var attack_rate : float = 1
## @export var frames_before_attack : int = 1
#@export var frames_after_attack : int = 1

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
var attackSprite : AnimatedSprite2D
@onready var fire_particles = preload('res://fire_spurt_small.tscn')

var direction: float = 1

func enter() -> void:
	super()
	attackSprite = null
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
	
	await get_tree().physics_frame
	attackBuffered = false

func exit() -> void:
	parent.animations.speed_scale = 1 # resetting it to default
	attackPropertyAnimation.stop(false)
	attackNum = 1
	attackFinished = false;
	canAttackAgain = false;
	attackBuffered = false;


func process_input(event: InputEvent) -> State:
	# No inputs while attacking
	if (Input.is_action_just_pressed("Attack")):
		attackBuffered = true
	if (Input.is_action_just_pressed("Jump")):
		parent.buffer_jump()
	if (Input.is_action_just_pressed("Dash") and not is_instance_valid(attackSprite)):
		return parent.backdodge_state
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
		reorient()
		#print("ANOTHER ATTACK")
		parent.attackCooldown.start(cooldown)
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
	
func reorient():
	if (sign(parent.animations.scale.x) == -sign(inputDir)):
		parent.animations.scale.x *= -1

func push_player_forward(amount : int = 50):
	#sign(parent.animations.scale.x) * parent.velocity.x 
	#Negative if going backwards, pos if going forwards.
	#Magnitude represents velocity in that direction.
	# Assume that if the player is holding the opposite direction, they do not want to be pushed forward.
	#print(inputDir)
	#print(parent.animations.scale.x)
	if (sign(inputDir) != -sign(parent.animations.scale.x) or inputDir == 0):
		#print("pushing player")
		# arrest player momentum if going in opposite direction
		if (sign(parent.animations.scale.x) * parent.velocity.x < -25):
			#print("Arrest velocity")
			parent.velocity.x *= 0.5
		#push the player forward (as long as they're not movinng very quickly already)
		if (sign(parent.animations.scale.x) * parent.velocity.x < 200):
			#print("Push forward")
			#print(parent.animations.scale.x * amount)
			parent.velocity.x += parent.animations.scale.x * amount * boost_multiplier
	# if the player is moving forward already, no need to give them extra vel.
	#parent.velocity.x += parent.animations.scale.x * amount


func snap_parent_to_ledge():
	pass
	#parent.position.x -= get_ledge_snap_distance() * sign(parent.animations.scale.x)
	
func attack(modulate : Color = Color.WHITE):
	Global.screen_shake(3, 6, 3)
	#if(attackNum == 3):
		#Global.screen_shake()
	parent.attackCooldown.start(cooldown)
	
	if attackNum == 1:
		attackSprite = attack1.instantiate()
	if attackNum == 2:
		attackSprite = attack2.instantiate()
	if attackNum == 3:
		attackSprite = attack3.instantiate()
	
	attackSprite.on_enemy_hit.connect(_on_enemy_hit)
	
	attackSprite.speed_scale = attack_rate
	attackSprite.selfKnockbackMultiplier = 0.5
	if(attackNum == 3):
		attackSprite.speed_scale *= 0.3
		attackSprite.knockbackMagnitude = 200
		Global.flicker_all_lights.emit()
		var particles = fire_particles.instantiate()
		particles.scale.x = parent.animations.scale.x
		parent.add_child(particles)
		attackSprite.top_level = true
		attackSprite.position = parent.position
	parent.add_child(attackSprite)
	
	attackSprite.modulate = modulate
	
	if(sign(parent.animations.scale.x) < 0):
		attackSprite.scale.x = -attackSprite.scale.x
		
	
func _on_enemy_hit():
	parent.velocity.x = 0

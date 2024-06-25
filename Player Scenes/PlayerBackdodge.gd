extends State

@export var gravityMultiplier: float = 1
@export var groundDragMultiplier: float = 1
@export var airDragMultiplier : float = 1
@export var accelerationMultiplier: float = 1
@export var moveSpeedMultiplier: float = 1

@export var dodge_velocity : Vector2 = Vector2.RIGHT
@export var immunity_time : float = 0.5

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * gravityMultiplier

var is_completely_finished : bool = false
var is_recovering : bool = false
var is_successful_dodge : bool = false
@export var can_parry : bool = false
var can_dodge : bool = false
var dodged_enemy : Enemy

var afterImages_scene = preload('res://Player Scenes/playerAfterImages.tscn')
var afterImages : Node2D

@onready var dummyPlayer : Player = $dummyPlayerHitbox
@onready var anims : AnimationPlayer = $backdodgeAnimationPlayer
func enter() -> void:
	parent.grant_immunity(immunity_time)
	anims.play("backdodge")
	disable_dummy_hitbox()
	dummyPlayer.position = parent.position
	is_completely_finished = false
	is_recovering = false
	is_successful_dodge = false
	can_parry = false
	can_dodge = false

	play_animation("backdodge-jump") # fall
	parent.velocity = -dodge_velocity
	parent.velocity.x *= sign(parent.animations.scale.x)
	
	super()
	
	beginAfterimages(0.05, 0.5)
	
	await parent.animations.animation_finished
	if not is_recovering:
		play_animation('backdodge-fall')

func exit() -> void:
	disable_dummy_hitbox()

func beginAfterimages(interval, time):
	afterImages = afterImages_scene.instantiate()
	afterImages.interval = interval
	afterImages.parent_animations = parent.animations
	afterImages.image_scale = parent.scale
	#print(scn.scale)
	
	add_child(afterImages)
	

func process_input(event: InputEvent) -> State:
	
	if (can_parry and Input.is_action_just_pressed("Attack")):
		Global.text_alert('PARRY')
		parent.grant_immunity(0.2)
		parent.velocity.x += 400 * sign(parent.animations.scale.x)
		return parent.attack_state
	
	return null

func process_physics(delta: float) -> State:
	#Physics
	Global.set_debug_text("can_dodge: " + str(can_dodge))
	var groundDrag = parent.drag * groundDragMultiplier
	var airDrag = parent.drag * airDragMultiplier
	var acceleration = parent.acceleration*accelerationMultiplier
	var maxSpeed = parent.moveSpeed * moveSpeedMultiplier
	

	
	#Gravity (vertical movement)
	parent.velocity.y += gravity*gravityMultiplier*delta
	parent.velocity.y = clamp(parent.velocity.y, -10000, parent.terminal_velocity)
	
	if parent.is_on_floor():
		parent.velocity.x = move_toward(parent.velocity.x, 0, groundDrag * delta)
	else:
		parent.velocity.x = move_toward(parent.velocity.x, 0, airDrag * delta)
	
	parent.move_and_slide()
	
	# Animations
	
	# State switches
	
	if is_completely_finished:
		return parent.ground_state
	
	if parent.is_on_floor() and not is_recovering:
		finish_dodge()
		#return ground_state
	return null

func finish_dodge():
	is_recovering = true
	play_animation('backdodge-recover')
	await parent.animations.animation_finished
	is_completely_finished = true
	
func disable_dummy_hitbox():
	can_dodge = false
	dummyPlayer.visible = false
	dummyPlayer.collision.disabled = true
	#pass
func enable_dummy_hitbox():
	dummyPlayer.visible = true
	dummyPlayer.collision.disabled = false
	can_dodge = true

func _on_dummy_player_hitbox_took_damage(amount, enemy):
	if (can_dodge):
		disable_dummy_hitbox()
		Global.text_alert("Dodged!")
		can_parry = true
		can_dodge = false
		if enemy is Enemy:
			dodged_enemy = enemy
		parry(0.5)

func parry(time):
	Engine.time_scale = 0.3
	parent.modulate = Color(1.5, 1.5, 1.5)
	Global.Game.modulate_foreground(Color(0.8, 0.8, 0.8))
	Global.Game.modulate_background(Color(0.8, 0.8, 0.8))
	if is_instance_valid(dodged_enemy):
		dodged_enemy.modulate = Color(1.5, 1.5, 1.5)
	
	await get_tree().create_timer(time).timeout
	
	Engine.time_scale = 1
	parent.modulate = Color.WHITE
	Global.Game.modulate_foreground(Color.WHITE)
	Global.Game.modulate_background(Color.WHITE)
	if is_instance_valid(dodged_enemy):
		dodged_enemy.modulate = Color.WHITE
	

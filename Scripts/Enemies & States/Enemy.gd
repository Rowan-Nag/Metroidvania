extends CharacterBody2D
class_name Enemy
# Contains generic class variables & functions for every Enemy

signal has_been_killed(killingBlowDamage) 
#emits when killed. Can be used to track num. enemies defeated,
#or make enemy arenas with kill conditions, or make enemies that react when others are killed, etc


@export var maxHealth : float = 100 # Enemy max health
var health : float = maxHealth # Enemy current health
@export_category("Weight / Knockback")
@export var weight = 10
@export var knockbackMultiplier : float = 1

var time_scale : float = 1.0 # used for freezing / unfreezing enemies, or slowing them down.

var simpleKnockback : float = 0
var movementDirection : float = 0

var ongoing_time_scale_effects : Array = [1.0]

@onready var enemyContactDamage = $EnemyContactDamage
@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var collision : CollisionShape2D = $CollisionShape2D

@onready var state_machine = $state_machine

var animationNames

func _ready():
	animationNames = animated_sprite.sprite_frames.get_animation_names()
	state_machine.init(self)

func handle_knockback(delta):
	simpleKnockback = move_toward(simpleKnockback, 0, abs(simpleKnockback)*8*delta*time_scale) 
	#technically this is an exponentially decaying velocity (should be quadratic) but this is much easier than fiddling with numbers (500*delta is alternative)
	velocity.x += simpleKnockback
	velocity.y += simpleKnockback / 10

func _physics_process(delta):
	state_machine.process_physics(delta)

func _process(delta: float) -> void:
	state_machine.process_frame(delta)
	
func deactivate_collision(): #Deactivates contact damage (like if the enemy is playing it's deaht animation before dissapearing)
	if(has_node("EnemyContactDamage")):
		$EnemyContactDamage.isActive = false
 
func activate_collision(): #Activates contact damage
	if(has_node("EnemyContactDamage")):
		$EnemyContactDamage.isActive = true

func take_damage(damage : float, knockbackDir: float = 0):
#	print(health)

	health -= damage
	knockback(knockbackDir)
	if(health <= 0):
		die()
		has_been_killed.emit(damage)
		
		
func knockback(knockbackDir : float):
	simpleKnockback = knockbackDir * knockbackMultiplier / weight
#	print("knockback:", simpleKnockback)
func die():
	#When the enemy is killed, try to play it's "death" animation
	
	deactivate_collision()
	
	if("death" in animationNames): #If it has a death animation, play it, wait for it to complete, then remove itself
		animated_sprite.play("death")

		await animated_sprite.animation_finished
		queue_free()
		
	else: #If it doesn't have a death animation, wait 0.2 secs, then remove itself.
		await get_tree().create_timer(0.2).timeout
		queue_free()

func play_animation(animationName):

	if(animationName in animationNames):
		animated_sprite.play(animationName)
	
func getPlayerDistance() -> float:
	return getPlayerRelativePosition().length()

func getPlayerRelativePosition() -> Vector2:
	return to_local(Global.player.global_position)

func move_and_slide_timewise() -> bool:
	velocity *= time_scale
	var did_collide = move_and_slide()
	velocity /= time_scale
	return did_collide
	
func move_and_collide_timewise(delta) -> KinematicCollision2D:
	return move_and_collide(velocity * delta * time_scale)
	
func change_time_scale(new_time_scale : float, duration : float, delayed_knockback : float = 0):
	if(new_time_scale == 0):
		new_time_scale = 0.0000001
	
	ongoing_time_scale_effects.append(new_time_scale)
	time_scale = ongoing_time_scale_effects.min()
	animated_sprite.speed_scale = time_scale
	
	
	await get_tree().create_timer(duration).timeout
	
	if (delayed_knockback != 0): 
		knockback(delayed_knockback)
	
	ongoing_time_scale_effects.erase(new_time_scale)
	time_scale = ongoing_time_scale_effects.min() # if all time scale effects are gone, there will still be a 1.0 in the array.
	animated_sprite.speed_scale = time_scale

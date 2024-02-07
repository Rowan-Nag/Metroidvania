extends CharacterBody2D
class_name Enemy
# Contains generic class variables & functions for every Enemy

signal has_been_killed(killingBlowDamage) 
#emits when killed. Can be used to track num. enemies defeated,
#or make enemy arenas with kill conditions, or make enemies that react when others are killed, etc


@export var maxHealth : float = 100 # Enemy max health
var health : float = maxHealth # Enemy current health

var simpleKnockback : float = 0
var movementDirection : float = 0

@onready var enemyContactDamage = $EnemyContactDamage
@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var collision : CollisionShape2D = $CollisionShape2D

@onready var state_machine = $state_machine

func _ready():
	state_machine.init(self)

func handle_knockback(delta):
	simpleKnockback = move_toward(simpleKnockback, 0, abs(simpleKnockback)*8*delta) 
	#technically this is an exponentially decaying velocity (should be quadratic) but this is much easier than fiddling with numbers (500*delta is alternative)
	velocity.x += simpleKnockback

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
		
		
func knockback(knockbackDir):
	simpleKnockback = knockbackDir
#	print("knockback:", simpleKnockback)
func die():
	#When the enemy is killed, try to play it's "death" animation
	var animationNames = animated_sprite.sprite_frames.get_animation_names()
	deactivate_collision()
	
	if("death" in animationNames): #If it has a death animation, play it, wait for it to complete, then remove itself
		animated_sprite.play("death")

		await animated_sprite.animation_finished
		queue_free()
		
	else: #If it doesn't have a death animation, wait 0.2 secs, then remove itself.
		await get_tree().create_timer(0.2).timeout
		queue_free()
	
	

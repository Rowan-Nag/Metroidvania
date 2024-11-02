extends AnimatedSprite2D

@onready var hitParticles = preload("res://Particles/attack_particles.tscn")
@onready var attackRay = $RayCast2D
# Called when the node enters the scene tree for the first time.
@export var knockbackMagnitude : int = 100
@export var selfKnockbackMultiplier : float = 1.0
@export var enemyFreezeTime : float = 0.1

signal on_enemy_hit

func _ready():
	awaitCompletion() # Awaits to remove itself (putting it in a function like this starts it as a coroutine)

func awaitCompletion():
	# Waits until it's finished
	await animation_finished
	# Deletes Itself
	queue_free()


func _on_area_2d_body_entered(body):
	var hitEnemy = false
	if(body is Enemy):
		body.take_damage(1, "player_primary_attack_1")
		hitEnemy = true
		on_enemy_hit.emit()
	elif body.has_method("take_damage"):
		body.take_damage(1, "player_primary_attack_1")
#	attackRay.set_target_position(to_local(body.global_position))
	#attackRay.force_raycast_update()
	#if(attackRay.is_colliding()):
#
		#var hit = hitParticles.instantiate()
		#add_child(hit)
		#hit.position = to_local(attackRay.get_collision_point())
##		print(to_local(hit.position))
		#hit.direction = -attackRay.target_position
		#if(hitEnemy):
			#hit.color = Color.RED
			#hit.scale_amount_min = 5

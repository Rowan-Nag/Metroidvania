extends Node2D

@onready var enemy : Enemy = get_parent()
@onready var parent : Enemy = get_parent() 

@onready var wallDetector : RayCast2D = $wall_detector
@onready var floorDetector : RayCast2D = $floor_detector
@onready var wait_timer : Timer = $wait_timer
@onready var knockback_handler : EnemyKnockbackHandler = $EnemyKnockbackHandler

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var movement_direction : float = 1
var is_waiting : bool = false
@export var walkSpeed : float = 50

func _ready():
	wallDetector = parent.find_child("wall_detector")
	floorDetector = parent.find_child("floor_detector")
	
	enemy.controller = self
	enemy.took_damage.connect(_on_enemy_hit)
	
func wait(time : float = 0.7):
	wait_timer.start(time)

func process_frame(delta): pass
func process_physics(delta: float):
	is_waiting = not wait_timer.is_stopped()
	
	parent.velocity.y += gravity*delta # apply gravity
	
	if (is_waiting):
		parent.velocity.x = 0 # stop if it's waiting
		enemy.play_animation("idle")
		
	else:
		enemy.play_animation("walk")
		parent.velocity.x = walkSpeed * movement_direction
		
		if(not floorDetector.is_colliding() or wallDetector.is_colliding()):
			# if there's either: no floor, a wall in front, then we turn around
			wait_and_turn()
			
		
	knockback_handler.apply_knockback(delta)
	parent.move_and_slide_timewise()
	
func wait_and_turn():
	wait(1 + randf_range(-0.5, 0.5))
	# wait between 0.5 and 1.5 seconds.
	movement_direction *= -1
	scale.x = movement_direction
	return

func _on_enemy_hit(type):
	wait()

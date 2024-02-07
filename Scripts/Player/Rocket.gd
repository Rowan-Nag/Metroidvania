extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	var collision = move_and_collide(velocity * delta)
	if(collision):
		if(collision.get_collider() is Enemy):
			collision.get_collider().take_damage(5, 3)
		queue_free()
		


extends State

var helirotor : Enemy = null

@export var ideal_range : int = 300
@export var player_detection_range : int = 500
 
#@export var direction : Vector2 = Vector2.UP
@export var speed : int = 10
@export var accel : float = 3.14

var nav : NavigationAgent2D

func enter() -> void:
	helirotor = parent
	nav = helirotor.get_node('NavigationAgent2D')
	
	#can't call async funcs in ready
	call_deferred("nav_setup")


#func nav_setup():
	## Wait for the first physics frame so the NavigationServer can sync.
	#await get_tree().physics_frame
		## Now that the navigation map is no longer empty, set the movement target.
	#nav.target_position = Vector2.ZERO

func nav_update():
	if (parent.position.x < Global.player.position.x):
		pass
	

func process_physics(delta: float) -> State:
	
	#nav.target_position = helirotor.get_global_mouse_position()
	nav.target_position = Global.player.position + Vector2(50, -50)
	if helirotor.getPlayerDistance() < player_detection_range and not nav.is_navigation_finished():
		var new_velocity = parent.position.direction_to(nav.get_next_path_position()) * speed 
		parent.velocity = lerp(parent.velocity, new_velocity, accel * delta)
		
		print(parent.velocity)
	if (nav.is_navigation_finished()):
		parent.velocity = lerp(parent.velocity, Vector2.ZERO, accel * 2 * delta)
	helirotor.handle_knockback(delta)
	var did_collide = helirotor.move_and_slide_timewise()

	if (did_collide):
		if (helirotor.is_on_wall()):
			helirotor.velocity.y *= -1
		if (helirotor.is_on_ceiling()):
			helirotor.velocity.x *= -1
		
	return null

extends State

var helirotor : Enemy = null

@export var ideal_range : int = 300
@export var player_detection_range : int = 500
 
#@export var direction : Vector2 = Vector2.UP
@export var speed : int = 10
@export var accel : float = 3.14

@export var stationary : bool = false

var initial_position : Vector2
var nav : NavigationAgent2D

func enter() -> void:
	helirotor = parent
	nav = helirotor.get_node('NavigationAgent2D')
	play_animation('flying')
	initial_position = helirotor.global_position

func nav_update():
	if (parent.global_position.x < Global.player.global_position.x):
		nav.target_position = Global.player.global_position + Vector2(-ideal_range, -ideal_range)
		if (!nav.is_target_reachable()):
			nav.target_position = Global.player.global_position + Vector2(ideal_range, -ideal_range)
	else:
		nav.target_position = Global.player.global_position + Vector2(ideal_range, -ideal_range)
		if (!nav.is_target_reachable()):
			nav.target_position = Global.player.global_position + Vector2(-ideal_range, -ideal_range)
			
func _on_navigation_update_timer_timeout():
	if not stationary:
		nav_update()
	else:
		nav.target_position = initial_position
		nav.target_desired_distance = 5

func process_physics(delta: float) -> State:
	
	#nav.target_position = helirotor.get_global_mouse_position()

	if helirotor.getPlayerDistance() < player_detection_range and not nav.is_navigation_finished():
		var new_velocity : Vector2 = parent.global_position.direction_to(nav.get_next_path_position()) * speed 
		parent.velocity = lerp(parent.velocity, new_velocity, accel * delta)
		if (new_velocity.dot(parent.velocity)):
				parent.velocity = lerp(parent.velocity, new_velocity, accel * delta)
				# If it's actively braking (target & current velocity vectors
				# pointing differect directions), it can accelerate double.
				# I'm accomplishing this by lerping again.
		#print(parent.velocity)
	if (nav.is_navigation_finished()):
		if (stationary):
			parent.velocity = lerp(parent.velocity, initial_position - helirotor.global_position, accel * delta * 2)
		else:
			parent.velocity = lerp(parent.velocity, Vector2.ZERO, accel * delta / 2)
		
	helirotor.handle_knockback(delta)
	var did_collide = helirotor.move_and_slide_timewise()

	if (did_collide):
		if (helirotor.is_on_wall()):
			helirotor.velocity.y *= -1.1
		if (helirotor.is_on_ceiling() or helirotor.is_on_floor()):
			helirotor.velocity.x *= -1.1
		
	return null




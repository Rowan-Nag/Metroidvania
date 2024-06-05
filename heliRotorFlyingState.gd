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
	play_animation('flying')

func nav_update():
	if (parent.position.x < Global.player.position.x):
		nav.target_position = Global.player.position + Vector2(-ideal_range, -ideal_range)
		if (!nav.is_target_reachable()):
			nav.target_position = Global.player.position + Vector2(ideal_range, -ideal_range)
	else:
		nav.target_position = Global.player.position + Vector2(ideal_range, -ideal_range)
		if (!nav.is_target_reachable()):
			nav.target_position = Global.player.position + Vector2(-ideal_range, -ideal_range)
			
func _on_navigation_update_timer_timeout():
	nav_update()

func process_physics(delta: float) -> State:
	
	#nav.target_position = helirotor.get_global_mouse_position()

	if helirotor.getPlayerDistance() < player_detection_range and not nav.is_navigation_finished():
		var new_velocity : Vector2 = parent.position.direction_to(nav.get_next_path_position()) * speed 
		parent.velocity = lerp(parent.velocity, new_velocity, accel * delta)
		if (new_velocity.dot(parent.velocity)):
				parent.velocity = lerp(parent.velocity, new_velocity, accel * delta)
				# If it's actively braking (target & current velocity vectors
				# pointing differect directions), it can accelerate double.
				# I'm accomplishing this by lerping again.
		#print(parent.velocity)
	if (nav.is_navigation_finished()):
		parent.velocity = lerp(parent.velocity, Vector2.ZERO, accel * 0.5 * delta)
		
	helirotor.handle_knockback(delta)
	var did_collide = helirotor.move_and_slide_timewise()

	if (did_collide):
		if (helirotor.is_on_wall()):
			helirotor.velocity.y *= -1
		if (helirotor.is_on_ceiling()):
			helirotor.velocity.x *= -1
		
	return null




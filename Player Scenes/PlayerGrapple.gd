extends State

var player : Player

@onready var grapple_hook_scn = preload('res://Level Scenes/grapple_hook.tscn')
var grapple_hook

var fling_strength : float = 50

var attached_point : Node2D

func enter() -> void:
	player = parent
	var points := find_best_grapple_points()
	if(points.size() > 0):
		attached_point = points[0]
		create_grapple_hook(attached_point)
		
	
func exit() -> void:
	pass

func process_input(event: InputEvent) -> State:
	if (Input.is_action_just_released("Grapple")):
		player.velocity = (find_best_grapple_points()[0].position - player.position + Vector2(0, -2)).normalized()*400
		return player.ground_state
	return null

func process_frame(delta: float) -> State:
	return null

func process_physics(delta: float) -> State:
	return null

func create_grapple_hook(target : Node2D):
	grapple_hook = grapple_hook_scn.instantiate()
	grapple_hook.target = target
	player.add_child(grapple_hook)

func find_best_grapple_points() -> Array[Area2D]:
	var grapplepoints : Array[Area2D] = player.grapplePointDetector.get_overlapping_areas()
	grapplepoints.sort_custom(node2d_closer_to_player)
	grapplepoints.filter(node2d_visible_to_player)
	
	return grapplepoints

# to be used in grapplepoints.sort_custom
func node2d_closer_to_player(a : Node2D, b : Node2D):
	return parent.distance_to(a) < parent.distance_to(b)

func node2d_visible_to_player(a : Node2D):
	player.grapplePointRay.target_position = player.to_local(a.position)
	player.grapplePointRay.force_raycast_update()
	return not player.grapplePointRay.is_colliding()
		
	

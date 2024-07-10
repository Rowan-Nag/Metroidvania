extends State

var player : Player

@onready var anims : AnimationPlayer = $grappleAnimationPlayer

@onready var grapple_hook_scn = preload('res://Level Scenes/grapple_hook.tscn')
var grapple_hook

var attached_point : Node2D

@export var gravityMultiplier: float = 1
@export var dragMultiplier: float = 1
@export var accelerationMultiplier: float = 1
@export var moveSpeedMultiplier: float = 1
@export var pullForce : float = 400
@export var weightDifferenceThreshold : float = 5

var inputDir
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * gravityMultiplier

var is_pulling : bool = false
@export var is_finished : bool = false # when finished, return to ground state
@export var pullForceMultiplier : float = 0.0

func enter() -> void:
	is_finished = false
	is_pulling = false
	pullForceMultiplier = 0

	player = parent
	var points := find_best_grapple_points()
	if(points.size() > 0):

		attached_point = points[0]
		create_grapple_hook(attached_point)
	else:
		is_finished = true
		
func exit() -> void:
	if (is_instance_valid(grapple_hook)):
		grapple_hook.queue_free()

func process_input(event: InputEvent) -> State:
	if (Input.is_action_just_released("Grapple")):
		is_pulling = true
	return null

func process_frame(delta: float) -> State:

	return null

func process_physics(delta: float) -> State:
	var drag = parent.drag * dragMultiplier
	var acceleration = parent.acceleration*accelerationMultiplier
	var maxSpeed = parent.moveSpeed * moveSpeedMultiplier
	
	inputDir = Input.get_axis("Left", "Right")
	
	if is_pulling:
		var distance = player.global_position.distance_to(attached_point.global_position)
		var distanceScalar = min(1, distance/100 + 0.5)
		pull_hook(pullForceMultiplier * distanceScalar)
	
	if(inputDir):
		
		parent.velocity.x = move_toward(parent.velocity.x, inputDir*maxSpeed, acceleration*delta)
	else:
		parent.velocity.x = move_toward(parent.velocity.x, 0, drag*delta)
	
	#Gravity (vertical movement)
	parent.velocity.y += gravity*gravityMultiplier*delta
	parent.velocity.y = clamp(parent.velocity.y, -10000, parent.terminal_velocity)
	
	parent.move_and_slide()
	
	if (is_finished):
		return player.ground_state
	return null

func pull_hook(multiplier):
	anims.play('springy_grapple_pull')
	if attached_point.is_parent_movable:
		# if attached to an enemuy or movable block, ect
		if "weight" in attached_point.parent:
			var direction : Vector2 = player.global_position.direction_to(attached_point.global_position) # direction from player to 'enemy'
			
			if player.weight > attached_point.parent.weight + weightDifferenceThreshold:
				# player is heavy enough that only the 'enemy' is pulled
				attached_point.parent.velocity = -direction * pullForce * player.weight / attached_point.parent.weight * multiplier
				
			elif  player.weight < attached_point.parent.weight - weightDifferenceThreshold:
				# player is too light to pull 'enemy' at all
				player.velocity = direction * pullForce / player.weight * multiplier
				
			else:
				var playerPull = attached_point.parent.weight / player.weight
				
				var playerVelocity = pullForce * playerPull
				var attachedVelocity = pullForce / playerPull
				
				
				
				player.velocity = direction * playerVelocity * multiplier
				attached_point.parent.velocity = -direction * attachedVelocity * multiplier
			
		else:
			pass
	else:
		# if attached to a statinoary point e.g. a wall
		player.velocity = (attached_point.position - player.position + Vector2(0, -2)).normalized() * pullForce *  multiplier

func create_grapple_hook(target : Node2D):
	grapple_hook = grapple_hook_scn.instantiate()
	grapple_hook.target = target
	player.add_child(grapple_hook)

func find_best_grapple_points() -> Array[Area2D]:
	var grapplepoints : Array[Area2D] = player.grapplePointDetector.get_overlapping_areas()
	if (grapplepoints.size() > 0):
		grapplepoints.sort_custom(node2d_closer_to_player)
		grapplepoints.filter(node2d_visible_to_player)
	
	return grapplepoints

# to be used in grapplepoints.sort_custom
func node2d_closer_to_player(a : Node2D, b : Node2D):
	return parent.position.distance_to(a.global_position) < parent.position.distance_to(b.global_position)

func node2d_visible_to_player(a : Node2D):
	player.grapplePointRay.target_position = player.to_local(a.global_position)
	player.grapplePointRay.force_raycast_update()
	return not player.grapplePointRay.is_colliding()
		
	

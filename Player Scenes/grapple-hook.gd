extends Node2D

var target : Node2D

var rope_velocity = 800
var rope_drag = 5

@onready var anchor : StaticBody2D
@onready var middle : RigidBody2D = $middle
@onready var claw : StaticBody2D = $claw

@onready var rope : Line2D = $Line2D

var is_attached_yet : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func _process(delta):
	if (not is_attached_yet and is_instance_valid(target)):
		rope_velocity = lerpf(rope_velocity, 300, rope_drag*delta)
		claw.position = claw.position.move_toward(to_local(target.position), rope_velocity*delta)
		if (claw.position == target.position):
			is_attached_yet = true
	draw_rope()
	
func make_rope_segment(next_segment: PhysicsBody2D) -> RigidBody2D:
	var segment := DampedSpringJoint2D.new()
	segment.node_b = next_segment.get_path()
	var new_segment :=RigidBody2D.new()
	add_child(new_segment)
	segment.node_a = new_segment.get_path()
	
	add_child(segment)
	
	return new_segment

func draw_rope():
	#var middle_point = claw.position/2 + Vector2(0, rope_sag)
	if (Input.is_action_just_pressed("Attack")):
		#target = get_local_mouse_position()
		rope_velocity = 800
		is_attached_yet = false
	var middle_point = $middle.position
	for i in rope.get_point_count():
		rope.points[i] = _quadratic_bezier(Vector2.ZERO, middle_point, claw.position, float(i)/(rope.get_point_count()-1)) 
	#rope.points[0] = $anchor.position
	#rope.points[1] = $middle.position
	#rope.points[2] = $claw.position
	
func _quadratic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, t: float):
	var q0 = p0.lerp(p1, t)
	var q1 = p1.lerp(p2, t)
	var r = q0.lerp(q1, t)
	return r



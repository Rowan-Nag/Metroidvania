extends Node2D

var target : Node2D

var rope_velocity = 1000

@onready var claw : Sprite2D = $claw

@onready var rope : Line2D = $Line2D

@onready var wallCheckRay : RayCast2D = $wallCheckRay

var is_attached_yet : bool = false
var is_broken : bool = false
@onready var anims : AnimationPlayer = $AnimationPlayer

@export_category("Rope drawing variables")
@export var x_stretch : float = 4
@export var v_stretch : float = 5
@export var phase_shift : float = 0
@export var sag_amount : float = 10
# Called when the node enters the scene tree for the first time.
func _ready():
	anims.play('grapple_start')
	pass
	
func _process(delta):
	
	if (not is_attached_yet and is_instance_valid(target)):
		#rope_velocity = lerpf(rope_velocity, 300, rope_drag*delta)
		claw.position = claw.position.move_toward(to_local(target.global_position), rope_velocity*delta)
		if (claw.position == to_local(target.global_position)):
			#await get_tree().create_timer(0.2).timeout
			#middle.gravity_scale = 0
			anims.play('grapple_attached')
			is_attached_yet = true
	if is_attached_yet:
		claw.position = to_local(target.global_position)


func _physics_process(delta):
	wallCheckRay.target_position = to_local(target.global_position)
	if (wallCheckRay.is_colliding()):
		is_broken = true
	draw_rope()

func draw_rope():
	
	var midpoint = (claw.position + position)/2 + Vector2(0, sag_amount)
	var length : float = (claw.position - position).length()
	var numPoints : int = rope.points.size()
	var ortho_unit_vector : Vector2 = (claw.position - position).orthogonal().normalized()
	
	rope.points[0] = Vector2.ZERO
	rope.points[numPoints - 1] = claw.position
	for i in range(1, numPoints-1):
		var t = float(i) / (numPoints-1)
		var disp = length * (float(i) / (numPoints-1))
		
		#rope.points[i] = claw.position * float(i) / (numPoints-1) # without sag
		rope.points[i] = _quadratic_bezier(Vector2.ZERO, midpoint, claw.position, t) # with sag
		rope.points[i] += ortho_unit_vector * v_stretch * sin((disp + phase_shift)/x_stretch)
		
		#rope.points[i].x = disp
		#rope.points[i].y = sin(disp/x_stretch)*v_stretch
	#rope.points[0] = $anchor.position
	#rope.points[1] = $middle.position
	#rope.points[2] = $claw.position
	
func _quadratic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, t: float):
	var q0 = p0.lerp(p1, t)
	var q1 = p1.lerp(p2, t)
	var r = q0.lerp(q1, t)
	return r



extends Node
class_name EnemyKnockbackHandler

@onready var enemy : Enemy 
enum types {TRASH_COLLECTOR, FLYING_THING, SHITHOUSE}
@export var enemy_type : types

var simpleKnockback : Vector2

func _ready():
	await get_parent().ready
	enemy = get_parent().enemy
	enemy.took_damage.connect(handle_knockback)

func handle_knockback(attack_type):
	var attack = Global.attackProfiles[attack_type]
	var direction : float = -sign(Global.player.global_position - enemy.global_position).x
	match enemy_type:
		types.TRASH_COLLECTOR: 
			if attack.knockback_tier > 0 :
				enemy.velocity.y += -100 * attack.knockback_tier
				simpleKnockback = Vector2(50 * direction, 0)

func apply_knockback(delta):
	match enemy_type:
		types.TRASH_COLLECTOR: 
			simpleKnockback = simpleKnockback.move_toward(Vector2.ZERO, 100*delta*enemy.time_scale) 
			enemy.velocity += simpleKnockback
	

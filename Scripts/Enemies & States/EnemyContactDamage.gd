extends Area2D
class_name EnemyContactDamage 

var isActive : bool = true # If collision is turned on, basically
@export var contactDamage : float = 1 # damage to (to the player) do on-contact
@export var contactKnockbackMultiplier : float = 1 # knockback applied to player on-contact

# Called when the node enters the scene tree for the first time.

func _on_body_entered(body):

	if(body is Player and isActive):
		
		var knockbackDir = Vector2()
		knockbackDir.x = sign(body.global_position.x-global_position.x)*1 
		knockbackDir.y = -1.5
		
		knockbackDir *= 100 * get_parent().weight * contactKnockbackMultiplier
		
		var enemy = get_parent()
		if(enemy is Enemy):
			body.take_damage(contactDamage, knockbackDir, enemy)
		else:
			body.take_damage(contactDamage, knockbackDir)
		#this is: Player.take_damage(damage, knockback)

class_name HudController
extends Container

@onready var healthBar : AnimatedSprite2D = $HealthBarContainer/healthBar_anchor/healthBar

@onready var healthPip1 : AnimatedSprite2D = $HealthBarContainer/healthBar_anchor/healthBar/hp1
@onready var healthPip2 : AnimatedSprite2D = $HealthBarContainer/healthBar_anchor/healthBar/hp2
@onready var healthPip3 : AnimatedSprite2D = $HealthBarContainer/healthBar_anchor/healthBar/hp3
@onready var healthPip4 : AnimatedSprite2D = $HealthBarContainer/healthBar_anchor/healthBar/hp4

var node2d_shake = preload("res://Level Scenes/Helper Scenes/node_2d_shake.tscn")

func _ready():
	Global.hudController = self
	visible = true
	$HealthBarContainer.visible = true
	healthBar.visible = true
	healthBar.play('normal')

func updateHealthBar():
	var health = Global.player.health
	if (health <= 3):
		removePip(healthPip4)
	if (health <= 2):
		removePip(healthPip3)
	if (health <= 1):
		removePip(healthPip2)
		healthBar.play("dying")
	else:
		healthBar.play('normal')
			
func removePip(pip : AnimatedSprite2D):
	if (not pip.frame==3):
		pip.play('default')

	return;

func shake(strength : float = 10):
	var shaker = node2d_shake.instantiate()
	shaker.shake_decay_rate = 6
	shaker.shake_speed = 3
	shaker.shake_strength = strength
	shaker.use_position_instead_of_offset = true
	healthBar.add_child(shaker)

func _process(delta):
	if Input.is_action_just_pressed("Dash"):
		Global.player.health -= 1
		updateHealthBar()

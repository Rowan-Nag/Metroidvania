extends Player

@onready var collision : CollisionShape2D = $CollisionShape2D

func _ready():
	pass

func _unhandled_input(event: InputEvent) -> void:
	pass

func _physics_process(delta: float) -> void:
	pass
	
func _process(delta: float) -> void:
	pass

func take_damage(damage : int, knockback, enemy : Enemy = null) -> void:
	took_damage.emit(damage, enemy)
	

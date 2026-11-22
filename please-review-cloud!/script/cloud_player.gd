extends Area2D

@export var fall_speed: float = 300.0

func _process(delta: float) -> void:
	position.y += fall_speed * delta
	
	if position.y > 1200:
		queue_free()

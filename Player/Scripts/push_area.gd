extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect( _on_body_entered )
	body_exited.connect( _on_body_exited )


func _on_body_entered( b : Node2D ) -> void:
	if b is PushableStatue:
		b.push_direction = PlayerManager.player.direction
	pass

func _on_body_exited( b : Node2D ) -> void:
	if b is PushableStatue:
		b.push_direction = Vector2.ZERO
	pass

extends Node


func _unhandled_key_input(event: InputEvent) -> void:
	var tutorialguy : InputEventKey = event
	if event.is_pressed():
		var key: int = tutorialguy.keycode
		match key:
			KEY_R:
				get_tree().reload_current_scene()
			KEY_Q:
				get_tree().quit()
		
		

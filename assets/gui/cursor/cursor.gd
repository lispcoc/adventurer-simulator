extends AnimatedSprite2D

func _ready() -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(self, "position", position - Vector2(0, 8), 1)
	tween.tween_property(self, "position", position, 1)
	tween.set_loops()
	tween.play()

class_name CharacterWalk extends Node2D

var _dir : Directions.Points

func _ready() -> void:
	$Base.frame_changed.connect(_on_frame_change)

func _on_frame_change():
	for c in get_children(): if c is Sprite2D and c != $Base:
		c.frame = $Base.frame

func set_dir(move_dir : Vector2) -> void:
	if move_dir.abs():
		var dir := Directions.angle_to_direction(move_dir.angle())
		if _dir != dir:
			_dir = dir
			match dir:
				Directions.Points.N:
					$AnimationPlayer.play("walk_n")
				Directions.Points.W:
					$AnimationPlayer.play("walk_w")
				Directions.Points.E:
					$AnimationPlayer.play("walk_e")
				Directions.Points.S:
					$AnimationPlayer.play("walk_s")

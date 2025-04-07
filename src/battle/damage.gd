class_name Damage extends Node

var val : int = 0
var type : Attribute.Type = Attribute.Type.None

func _init(v : int, t : Attribute.Type) -> void:
	val = v
	type = t
	pass

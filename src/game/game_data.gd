class_name GameData extends Node

var test_var = 0
var people : Array[Character] = []
var time : GameTime = GameTime.new()

func add_people (ch : Character) -> void:
	people.append(ch)

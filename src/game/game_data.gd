class_name GameData extends Node

var test_var = 0
var people : Array[Actor] = []
var time : GameTime = GameTime.new()

func add_people (ch : Actor) -> void:
	people.append(ch)

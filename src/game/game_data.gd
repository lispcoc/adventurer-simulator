class_name GameData extends Node

var test_var = 0
var party_front : Array[Actor] = []
var party_back : Array[Actor] = []
var people : Array[Actor] = []
var time : GameTime = GameTime.new()

#
# System
#
var battle_message_speed : int = 1

func add_party (ch : Actor, front : bool = true) -> void:
	if front: party_front.append(ch)
	else: party_back.append(ch)

func add_people (ch : Actor) -> void:
	people.append(ch)

class_name Item extends Node

var tname : String = ""
var stackable : bool = true

var melee := MeleeData.new()

var wgt : int = 0

class MeleeData:
	var base_times = 2
	var base_amount = 2
	var base_sides = 4
	var base_attack = 0
	func roll_damage():
		return DiceRoller.roll_dices(base_amount, base_sides) + base_attack

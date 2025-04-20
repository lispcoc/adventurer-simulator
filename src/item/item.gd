class_name Item extends Node

var id = "null"

var data : ItemData:
	get: return StaticData.items[id]
	set(_v): pass

var wgt : int:
	get: return data.wgt
	set(_v): pass

func display_name():
	return data.tname

func melee_roll_damage():
	var amount = data.melee_base_amount
	var sides = data.melee_base_sides
	var attack = data.melee_base_attack
	return DiceRoller.roll_dices(amount, sides) + attack

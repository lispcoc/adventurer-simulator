class_name Character extends Node

var status : Status = Status.new()
var eqip : Equip = Equip.new()
var inventory : Array[Item] = []

class Status:
	var level : int = 1
	var hp : int = 10
	var mp : int = 10
	var str : int = 10
	var dex : int = 10
	var agi : int = 10
	var mag : int = 10
	var res : int = 10

class Equip:
	var head : Item
	var body : Item
	var foot : Item
	var ring : Item
	var backpack : Item

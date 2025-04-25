class_name Equip extends Node

var weapon_uid : String
var torso_uid : String
var headwear_uid : String
var footwear_uid : String
var amulet_uid : String
var ring_uid : String
var backpack_uid : String

func set_item(item : Item) -> void:
	match item.data.type:
		ItemData.Type.Weapon:
			weapon_uid = item.uid
		ItemData.Type.Torso:
			torso_uid = item.uid
		ItemData.Type.Headwear:
			headwear_uid = item.uid
		ItemData.Type.Footwear:
			footwear_uid = item.uid
		ItemData.Type.Amulet:
			amulet_uid = item.uid
		ItemData.Type.Ring:
			ring_uid = item.uid

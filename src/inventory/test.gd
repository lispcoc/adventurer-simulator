extends Node2D

var iv : Inventory
var grid : CtrlInventory

func _ready() -> void:
	iv = $Inventory
	grid = $CanvasLayer/CtrlInventory
	grid.item_activated.connect(func(i): grid.select(i, false))
	for a in Game.get_party():
		var it = InventoryItem.new()
		it.set_property("name", a.actor_name)
		it.set_property("actor", a)
		iv.add_item(it)
	grid.inventory_item_selected.connect(on_selected)

func on_selected(item: InventoryItem):
	print(item)

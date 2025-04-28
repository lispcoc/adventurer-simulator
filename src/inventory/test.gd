extends Control

var iv : Inventory
var grid : CtrlInventoryGrid

func _ready() -> void:
	iv = $Inventory
	grid = $CanvasLayer/CenterContainer/CtrlInventoryGrid
	for a in Game.get_party():
		var it = InventoryItem.new()
		it.set_property("name", a.actor_name)
		it.set_property("actor", a)
		iv.add_item(it)
	grid.inventory_item_selected.connect(on_selected)
	search_item.call_deferred()
	grid.child_entered_tree.connect(func (_n): print("aaaaaaaaa"))

func _on_item_entered(item : CtrlInventoryItemBase):
	item.focus_entered.connect(func (): print("focus_entered:" + item.name))

func search_item():
	for i in get_tree().get_nodes_in_group("ItemButton"):
		print(i)

func on_selected(_item: InventoryItem):
	print("select:" )

func _can_drop_data(_at_position: Vector2, _data: Variant) -> bool:
	return false


func _drop_data(_at_position: Vector2, _data: Variant) -> void:
	return

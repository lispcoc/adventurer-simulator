extends Node2D

var actor : Actor
var fake_actor : Actor
var actor_inventory : CtrlInventory
var itembox_inventory : CtrlInventory

func _ready() -> void:
	actor = Game.get_party()[0]
	actor_inventory = actor.spawn_inventory(%ActorlInventoryTemplate)
	%ActorlInventoryTemplate.get_parent().add_child(actor_inventory)
	actor_inventory.show()
	actor_inventory.inventory_item_activated.connect(_ltor)
	test()

func test():
	fake_actor = Actor.new()
	itembox_inventory = fake_actor.spawn_inventory(%ItemBoxTemplate)
	%ItemBoxTemplate.get_parent().add_child(itembox_inventory)
	itembox_inventory.show()
	itembox_inventory.inventory_item_activated.connect(_rtol)
	for key in StaticData.items.keys():
		itembox_inventory.inventory.add_item_automerge(StaticData.items[key].instantiate().to_inventory_item())
	for key in StaticData.items.keys():
		itembox_inventory.inventory.add_item_automerge(StaticData.items[key].instantiate().to_inventory_item())

func _ltor(item : InventoryItem):
	itembox_inventory.inventory.add_item_autosplitmerge(item)

func _rtol(item : InventoryItem):
	actor_inventory.inventory.add_item_autosplitmerge(item)

extends Control

signal exit()

var inventory : Inventory
var selected : InventoryItem
var ctrl_inventory : CtrlInventory

func _ready() -> void:
	for a in Game.get_party():
		var inv_actor = InventoryItem.new()
		inv_actor.set_property("name", a.actor_name)
		inv_actor.set_property("actor", a)
		%Actor.inventory.add_item(inv_actor)
		%Actor.inventory_item_selected.connect(func (item):
			if ctrl_inventory: ctrl_inventory.queue_free.call_deferred()
			var actor : Actor = item.get_property("actor")
			ctrl_inventory = actor.spawn_inventory(%CtrlInventory)
			ctrl_inventory.show()
			ctrl_inventory.inventory_item_selected.connect(on_selected)
			ctrl_inventory.inventory_item_activated.connect(on_activated)
			$CanvasLayer.add_child(ctrl_inventory)
		)
		%Actor.inventory_item_activated.connect(func (_item):
			if ctrl_inventory.inventory.get_item_count():
				ctrl_inventory.grab_focus()
				ctrl_inventory.select(0)
				ctrl_inventory.item_selected.emit(0)
		)
	%Actor.grab_focus()
	%Actor.select(0)
	%Actor.item_selected.emit(0)

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_pressed("ui_cancel"):
		if %Actor.has_focus():
			exit.emit()
			queue_free.call_deferred()
			get_viewport().set_input_as_handled()
		else:
			%Actor.grab_focus()
			get_viewport().set_input_as_handled()

func on_selected(inv_item : InventoryItem) -> void:
	var item : Item = Item.from_inventory_item(inv_item)
	%ItemDescription.text = item.short_description()
	selected = inv_item

func on_activated(_inv_item : InventoryItem) -> void:
	reflesh_inventory()

func reflesh_inventory() -> void:
	for inv_item in ctrl_inventory.inventory.get_items():
		var actor : Actor = inv_item.get_property("owner")
		var item : Item = inv_item.get_property("item")
		if actor.get_weapon() == item:
			inv_item.set_property("name", "(E)" + item.display_name())
		else:
			inv_item.set_property("name", item.display_name())

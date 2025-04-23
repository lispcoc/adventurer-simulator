extends Control

signal exit()

var inventory : Inventory
var actor : Actor
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
			ctrl_inventory = spawn_inventory(item.get_property("actor"), %CtrlInventory)
			$CanvasLayer.add_child(ctrl_inventory)
			ctrl_inventory.show()
			ctrl_inventory.inventory_item_selected.connect(on_selected)
		)
		%Actor.inventory_item_activated.connect(func (item):
			if ctrl_inventory.inventory.get_item_count():
				ctrl_inventory.grab_focus()
				ctrl_inventory.select(0)
				ctrl_inventory.item_selected.emit(0)
		)
	%Actor.grab_focus()
	%Actor.select(0)
	%Actor.item_selected.emit(0)

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_pressed("ui_cancel"):
		if %Actor.has_focus():
			exit.emit()
			queue_free.call_deferred()
			get_viewport().set_input_as_handled()
		else:
			%Actor.grab_focus()
			get_viewport().set_input_as_handled()

func on_selected(inv_item : InventoryItem) -> void:
	var item : Item = inv_item.get_property("item")
	%ItemDescription.text = item.short_description()
	selected = inv_item

func spawn_inventory(_actor : Actor, template : CtrlInventory) -> CtrlInventory:
	var ctrl_inventory : CtrlInventory = template.duplicate()
	var _inventory = Inventory.new()
	ctrl_inventory.inventory = _inventory
	for item in _actor.inventory:
		var inv_item = InventoryItem.new()
		inv_item.set_property("name", item.display_name())
		inv_item.set_property("item", item)
		_inventory.add_item(inv_item)
	_inventory.item_added.connect(
		func (inv_item : InventoryItem):
			var item : Item = inv_item.get_property("item")
			_actor.add_item(item)
	)
	_inventory.item_removed.connect(
		func (inv_item : InventoryItem):
			var item : Item = inv_item.get_property("item")
			_actor.remove_item(item)
	)
	return ctrl_inventory

func test_add_item() -> void:
	var tmp : Array[String] = StaticData.items.keys()
	tmp.shuffle()
	var item = StaticData.items[tmp[0]].instantiate()
	var inv_item = InventoryItem.new()
	inv_item.set_property("name", item.display_name())
	inv_item.set_property("item", item)
	inventory.add_item(inv_item)

func test_remove_item() -> void:
	inventory.remove_item(selected)

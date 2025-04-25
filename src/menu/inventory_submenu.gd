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
			ctrl_inventory = spawn_inventory(item.get_property("actor"), %CtrlInventory)
			$CanvasLayer.add_child(ctrl_inventory)
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
	
	$CanvasLayer/Add.pressed.connect(test_add_item)
	$CanvasLayer/Remove.pressed.connect(test_remove_item)

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

func on_activated(inv_item : InventoryItem) -> void:
	inv_item.get_property("owner").set_weapon(inv_item.get_property("item"))
	reflesh_inventory()

func reflesh_inventory() -> void:
	for inv_item in ctrl_inventory.inventory.get_items():
		var actor : Actor = inv_item.get_property("owner")
		var item : Item = inv_item.get_property("item")
		if actor.get_weapon() == item:
			inv_item.set_property("name", "(E)" + item.display_name())
		else:
			inv_item.set_property("name", item.display_name())

func spawn_inventory(_actor : Actor, template : CtrlInventory) -> CtrlInventory:
	var ctrl_inventory : CtrlInventory = template.duplicate()
	var _inventory = Inventory.new()
	ctrl_inventory.set_meta("owner", _actor)
	ctrl_inventory.inventory = _inventory
	for item in _actor.inventory:
		var inv_item = InventoryItem.new()
		inv_item.set_property("item", item)
		inv_item.set_property("owner", _actor)
		if _actor.get_weapon() == item:
			inv_item.set_property("name", "(E)" + item.display_name())
		else:
			inv_item.set_property("name", item.display_name())
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
	ctrl_inventory.show()
	ctrl_inventory.inventory_item_selected.connect(on_selected)
	ctrl_inventory.inventory_item_activated.connect(on_activated)
	return ctrl_inventory

func test_add_item() -> void:
	var tmp : Array[String] = StaticData.items.keys()
	tmp.shuffle()
	var item = StaticData.items[tmp[0]].instantiate()
	var inv_item = InventoryItem.new()
	inv_item.set_property("name", item.display_name())
	inv_item.set_property("item", item)
	ctrl_inventory.inventory.add_item(inv_item)

func test_remove_item() -> void:
	ctrl_inventory.inventory.remove_item(ctrl_inventory.get_selected_inventory_item())

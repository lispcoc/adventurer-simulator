class_name EquipSubMenu extends BaseSubmenuWithActor

var equip_list : TiledStringGrid
var item_desc : RichTextLabel
var ctrl_inventory : CtrlInventory

func _ready() -> void:
	equip_list = %EquipList
	item_desc = $CanvasLayer/ItemDescriptionPanel/ItemDescription
	item_desc.hide()
	super._ready()

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_pressed("ui_cancel"):
		if ctrl_inventory and ctrl_inventory.has_focus():
			exit_item_select()
		else:
			resume_actor_select.emit()
			item_desc.hide()

func on_selected(_node):
	equip_list.get_buttons()[0].grab_focus()
	item_desc.show()
	await resume_actor_select

func on_focus_button(actor : Actor):
	reflesh_equip_list(actor)

func on_focus_item(item : Item):
	item_desc.text = item.description()

func on_pressed_category(idx : int, actor : Actor, category : ItemData.Type):
	if ctrl_inventory: ctrl_inventory.queue_free()
	var filter := func (item : Item): return item.data.type == category
	ctrl_inventory = actor.spawn_inventory(%CtrlInventory, filter)
	ctrl_inventory.inventory_item_activated.connect(
		func (inv_item : InventoryItem):
			var item : Item = inv_item.get_property("item")
			if item: actor.set_equip(item)
			reflesh_equip_list(actor)
			exit_item_select()
	)
	ctrl_inventory.inventory_item_selected.connect(
		func (inv_item : InventoryItem):
			var item : Item = inv_item.get_property("item")
			if item: on_focus_item(item)
	)
	$CanvasLayer.add_child(ctrl_inventory)
	equip_list.set_meta("last_select", idx)
	ctrl_inventory.show()
	ctrl_inventory.grab_focus()
	if ctrl_inventory.inventory.get_item_count(): ctrl_inventory.select(0)

func reflesh_equip_list(actor : Actor):
	equip_list.erase()
	equip_list.add_array([
		" 武器 ", " %s " % [actor.get_weapon().display_name()],
		" 胴 ", " %s " % [actor.get_torso().display_name()],
		" 頭 ", " %s " % [actor.get_headwear().display_name()],
		" 足 ", " %s " % [actor.get_footwear().display_name()],
	])
	var btn := equip_list.get_buttons()
	btn[0].focus_entered.connect(on_focus_item.bind(actor.get_weapon()))
	btn[1].focus_entered.connect(on_focus_item.bind(actor.get_torso()))
	btn[2].focus_entered.connect(on_focus_item.bind(actor.get_headwear()))
	btn[3].focus_entered.connect(on_focus_item.bind(actor.get_footwear()))
	btn[0].pressed.connect(on_pressed_category.bind(0, actor, ItemData.Type.Weapon))
	btn[1].pressed.connect(on_pressed_category.bind(1, actor, ItemData.Type.Torso))
	btn[2].pressed.connect(on_pressed_category.bind(2, actor, ItemData.Type.Headwear))
	btn[3].pressed.connect(on_pressed_category.bind(3, actor, ItemData.Type.Footwear))

func exit_item_select():
	ctrl_inventory.queue_free.call_deferred()
	equip_list.get_buttons()[equip_list.get_meta("last_select", 0)].grab_focus()

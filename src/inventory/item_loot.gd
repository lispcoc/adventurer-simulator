class_name ItemLoot extends Node2D

signal exit()

const SCENE : PackedScene = preload("res://src/inventory/item_loot.tscn")

var actor : Actor
var fake_actor : Actor
var actor_inventory : CtrlInventory
var itembox_inventory : CtrlInventory

static func instantiate() -> ItemLoot:
	return SCENE.instantiate()

func _ready() -> void:
	var hint := ControlHint.new()
	%Help.add_child(hint)
	hint.add_hint("direction_lr", "切り替え")
	hint.add_hint("ui_accept", "アイテムを入手/戻す")
	hint.add_hint("sub", "すべて入手")
	hint.add_hint("ui_cancel", "終了")
	hide()

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_pressed("ui_cancel"):
		end()
		get_viewport().set_input_as_handled()
	if Input.is_action_pressed("ui_left"):
		actor_inventory.grab_focus()
		get_viewport().set_input_as_handled()
	if Input.is_action_pressed("ui_right"):
		itembox_inventory.grab_focus()
		get_viewport().set_input_as_handled()
	if Input.is_action_pressed("sub"):
		get_all()
		get_viewport().set_input_as_handled()

func start(_actor : Actor, items : Array[Item]) -> void:
	actor = _actor
	actor_inventory = actor.spawn_inventory(%ActorlInventoryTemplate)
	%ActorlInventoryTemplate.get_parent().add_child(actor_inventory)
	actor_inventory.show()
	actor_inventory.inventory_item_activated.connect(_ltor)

	fake_actor = Actor.new()
	itembox_inventory = fake_actor.spawn_inventory(%ItemBoxTemplate)
	%ItemBoxTemplate.get_parent().add_child(itembox_inventory)
	itembox_inventory.show()
	itembox_inventory.inventory_item_activated.connect(_rtol)
	for item in items:
		item.to_inventory_item()
		itembox_inventory.inventory.add_item_automerge(item.to_inventory_item())

	itembox_inventory.grab_focus()
	if itembox_inventory.inventory.get_item_count(): itembox_inventory.select(0)

func end() -> void:
		exit.emit()
		queue_free.call_deferred()

func get_all() -> void:
	for item in itembox_inventory.inventory.get_items():
		_rtol.call_deferred(item)

func _ltor(item : InventoryItem):
	itembox_inventory.inventory.add_item_autosplitmerge(item)

func _rtol(item : InventoryItem):
	actor_inventory.inventory.add_item_autosplitmerge(item)

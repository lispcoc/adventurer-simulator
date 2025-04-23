extends CtrlInventoryItemBase

func _ready() -> void:
	get_tree().call_group("InventoryMenu", "_on_item_entered", self)
	$ItemControlButton.focus_entered.connect(func (): focus_entered.emit())

func _get_drag_data(_at_position: Vector2) -> Variant:
	return null
	print(item)
	return item

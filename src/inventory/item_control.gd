extends CtrlInventoryItemBase

func _ready() -> void:
	$ItemControlButton.pressed.connect(func(): self.grab_click_focus())

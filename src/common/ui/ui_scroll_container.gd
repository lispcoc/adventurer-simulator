extends ScrollContainer

func _ready() -> void:
	self.resized.connect(_change_panel_size)
	_change_panel_size()

func _change_panel_size() -> void:
	var cont = get_parent() as Control
	if self.size.y == 0:
		cont.custom_minimum_size.x = 0
		cont.custom_minimum_size.y = 0
	else:
		cont.custom_minimum_size.x = self.size.x + self.position.x * 2
		cont.custom_minimum_size.y = self.size.y + self.position.y * 2

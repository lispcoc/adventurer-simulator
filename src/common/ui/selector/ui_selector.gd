class_name UISelector extends VBoxContainer

@export var max_index: int = 16
@export var custom_max_size : float = 128

func _ready() -> void:
	self.resized.connect(_reset_custom_max)
	for i in range(1, max_index):
		var inst = DialogicNode_ChoiceButton.new()
		inst.choice_index = i
		inst.alignment = HORIZONTAL_ALIGNMENT_LEFT
		add_child(inst)

func _reset_custom_max() -> void:
	return
	if self.size.y < custom_max_size:
		get_parent().size.y = self.size.y
	else:
		get_parent().size.y = custom_max_size
	pass

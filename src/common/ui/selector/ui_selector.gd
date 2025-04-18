class_name UISelector extends VBoxContainer

@export var max_index: int = 16
@export var custom_max_size : float = 128

func _ready() -> void:
	for i in range(1, max_index):
		var inst = DialogicNode_ChoiceButton.new()
		inst.choice_index = i
		inst.alignment = HORIZONTAL_ALIGNMENT_LEFT
		add_child(inst)


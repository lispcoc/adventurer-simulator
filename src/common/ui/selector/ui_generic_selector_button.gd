class_name UIGenericSelectorButton extends Button

signal selected(variable : Dictionary)
signal nested_entered
signal nested_canceled

@export var nested_selector : UIGenericSelector
@export var variable : Dictionary

func _ready() -> void:
	pressed.connect(on_pressed)

func on_pressed():
	if nested_selector:
		nested_entered.emit()
		var retvar = await nested_selector.start_select()
		if retvar["canceled"]:
			nested_canceled.emit()
		else:
			retvar.merge(variable, false)
			selected.emit(retvar)
	else:
		selected.emit(variable)

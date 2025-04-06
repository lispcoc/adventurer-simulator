class_name CharacterPanel extends Node

func _ready() -> void:
	set_hp(100, 120)
	add_condition(StatusCondision.Burn)

func set_hp(val : int, max_val : int):
	var label := find_child("HPVal") as Label
	if label:
		label.text = String.num_int64(val)
	var bar := find_child("HealthBar") as ProgressBar
	if bar:
		bar.value = val * 100 / max_val

func set_mp(val : int, max_val : int):
	var label := find_child("MPVal") as Label
	if label:
		label.text = String.num_int64(val)
	var bar := find_child("ManaBar") as ProgressBar
	if bar:
		bar.value = val * 100 / max_val

func add_condition(cond: int) -> void:
	var sc := find_child("StatusCondition") as UIStatusCondision
	if sc:
		sc.add_condition(cond)

func remove_condition(cond: int) -> void:
	var sc := find_child("StatusCondition") as UIStatusCondision
	if sc:
		sc.add_condition(cond)

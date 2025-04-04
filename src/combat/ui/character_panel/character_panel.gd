extends Node

func _ready() -> void:
	set_hp(50)
	add_condition(StatusCondision.Burn)

func set_hp(hp : int):
	var label := find_child("HPVal") as Label
	if label:
		label.text = String.num_int64(hp)
	var bar := find_child("HealthBar") as ProgressBar
	if bar:
		bar.value = hp

func set_mp(hp : int):
	var label := find_child("MPVal") as Label
	if label:
		label.text = String.num_int64(hp)
	var bar := find_child("ManaBar") as ProgressBar
	if bar:
		bar.value = hp

func add_condition(cond: int) -> void:
	var sc := find_child("StatusCondition") as UIStatusCondision
	if sc:
		sc.add_condition(cond)

func remove_condition(cond: int) -> void:
	var sc := find_child("StatusCondition") as UIStatusCondision
	if sc:
		sc.add_condition(cond)

class_name CharacterPanel extends Button

@export var name_label : Label
var lighter : ColorRect
var timer : Timer
var actor : Actor:
	set(v):
		actor = v
		update()

var selectable : bool = false:
	set(v):
		selectable = v
		if selectable:
			focus_mode = Control.FOCUS_ALL
			mouse_filter = Control.MOUSE_FILTER_STOP
		else:
			focus_mode = Control.FOCUS_NONE
			mouse_filter = Control.MOUSE_FILTER_IGNORE

func _ready() -> void:
	lighter = ColorRect.new()
	add_child(lighter)
	lighter.color = Color(1.0, 1.0, 1.0, 0.3)
	lighter.size = size
	lighter.hide()
	timer = Timer.new()
	add_child(timer)
	selectable = false

func update():
	set_character_name(actor.actor_name)
	set_hp(actor.hp, actor.hp_max)
	set_mp(actor.mp, actor.mp_max)

func highlight(on = true, blink = false):
	if timer.timeout.is_connected(toggle_highlight):
		timer.timeout.disconnect(toggle_highlight)
	if on:
		lighter.show()
		if blink:
			timer.timeout.connect(toggle_highlight)
			timer.start(0.2)
	else: lighter.hide()

func toggle_highlight():
	if lighter.is_visible_in_tree(): lighter.hide()
	else: lighter.show()

func set_character_name(_name : String):
	name_label.text = _name

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

class_name CharacterPanel extends Button

@export var name_label : Label
@export var status_container : Container
var lighter : ColorRect
var cursor : Node2D
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
	lighter.color = Color(1.0, 1.0, 1.0, 0.3)
	lighter.size = size
	lighter.hide()
	add_child(lighter)
	timer = Timer.new()
	add_child(timer)
	add_condition(StatusCondision.Burn)
	selectable = false
	focus_entered.connect(pop_cursor)
	focus_exited.connect(remove_cursor)

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

func get_center_top() -> Vector2:
	return Vector2(size.x / 2, 0)

func pop_number(num : int, color : Color = Color("white")):
	var fd := FloatingDamage.instantiate()
	fd.text = str(num)
	fd.color = color
	fd.position = get_center_top()
	add_child(fd)

func pop_cursor() -> void:
	cursor = Game.spawn_cursor()
	cursor.position = get_center_top()
	add_child(cursor)

func remove_cursor() -> void:
	for cursor in get_children(): if Game.is_cursor(cursor): remove_child(cursor)

func add_condition(cond: int) -> void:
	status_container.add_child(StatusCondision.to_one_string_label(cond))
	return
	var sc := find_child("StatusCondition") as UIStatusCondision
	if sc:
		sc.add_condition(cond)

func remove_condition(cond: int) -> void:
	return
	var sc := find_child("StatusCondition") as UIStatusCondision
	if sc:
		sc.add_condition(cond)

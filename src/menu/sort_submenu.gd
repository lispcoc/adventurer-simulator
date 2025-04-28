class_name SortSubMenu extends Container

signal sort_exit()

func _unhandled_input(_event: InputEvent) -> void:
	if not visible:
		return
	if Input.is_action_pressed("ui_cancel"):
		sort_exit.emit()
		hide()
		get_viewport().set_input_as_handled()

func start_sort():
	show()
	for c in get_children():
		c = c as Button
		if c: remove_child(c)
	var front := Game.get_party(true, false)
	var back := Game.get_party(false, true)
	var i := 0
	while i < Game.MAX_LINE_MEMBER:
		var btn1 := Button.new()
		btn1.toggle_mode = true
		btn1.toggled.connect(sort_button_pressed)
		if i < front.size():
			btn1.text = front[i].actor_name
			btn1.set_meta("member", front[i])
		else:
			btn1.text = "[空き]"
		var btn2 := Button.new()
		btn2.toggle_mode = true
		btn2.toggled.connect(sort_button_pressed)
		if i < back.size():
			btn2.text = back[i].actor_name
			btn2.set_meta("member", back[i])
		else:
			btn2.text = "[空き]"
		add_child(btn1)
		add_child(btn2)
		i = i + 1
	for c in get_children():
		c = c as Button
		if c:
			c.grab_focus()
			break

func sort_button_pressed(_toggled_on : bool):
	var btn1 : Button = null
	var btn2 : Button
	var num1 : int
	var num2 : int
	var i : int
	for c in get_children():
		c = c as Button
		if c and c.button_pressed:
			if btn1:
				btn2 = c
				num2 = i
				break
			else:
				btn1 = c
				num1 = i
		i = i + 1
	if btn1 and btn2:
		move_child(btn1, num2)
		move_child(btn2, num1)
		for c in get_children():
			c = c as Button
			if c: c.button_pressed = false
		i = 0
		var front : Array[Actor]
		var back : Array[Actor]
		for c in get_children():
			if c.has_meta("member"):
				var a = c.get_meta("member", null) as Actor
				if a and (i % 2 == 0): front.append(a)
				if a and (i % 2 == 1): back.append(a)
			i = i + 1
		if front.is_empty():
			while not back.is_empty(): front.append(back.pop_front())
		for m in Game.get_party(): Game.remove_party(m)
		for m in front: Game.add_party(m)
		for m in back: Game.add_party(m, true)
		start_sort.call_deferred()

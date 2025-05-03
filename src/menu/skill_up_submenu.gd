extends BaseSubmenuWithActor

var list : GridContainer
var button_template : Button
var label_template : Label

var phy_exp_label : Label
var tec_exp_label : Label
var mnd_exp_label : Label

var actor : Actor

var focus_button : Button

func _ready() -> void:
	super._ready()
	list = %SkillList
	button_template = %ButtonTemplate
	label_template = %LabelTemplate
	phy_exp_label = %PhyExp
	tec_exp_label = %TecExp
	mnd_exp_label = %MndExp
	_init_list(Game.get_party()[0])

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_pressed("ui_cancel"):
		resume_actor_select.emit()
		get_viewport().set_input_as_handled()

func _init_list(_actor : Actor) -> void:
	if not list: return
	for c in list.get_children(): list.remove_child(c)
	actor = _actor
	var first : bool = true
	for skill : Skill in StaticData.skills.values():
		var button : Button = button_template.duplicate()
		button.text = "%s (%d → %d)" % [
			skill.display_name,
			actor.get_skill_level(skill),
			actor.get_skill_level(skill) + 1
		]
		var phy_label : Label = label_template.duplicate()
		phy_label.text = str(skill.next_phy(1))
		var tec_label : Label = label_template.duplicate()
		tec_label.text = str(skill.next_tec(1))
		var mnd_label : Label = label_template.duplicate()
		mnd_label.text = str(skill.next_mnd(1))
		button.show()
		button.set_meta("skill", skill)
		button.set_meta("phy_label", phy_label)
		button.set_meta("tec_label", tec_label)
		button.set_meta("mnd_label", mnd_label)
		phy_label.show()
		tec_label.show()
		mnd_label.show()
		list.add_child(button)
		list.add_child(phy_label)
		list.add_child(tec_label)
		list.add_child(mnd_label)
		button.pressed.connect(_button_pressed.bind(skill))
		if first:
			focus_button = button
			first = false
	_update()

func _update() ->void:
	phy_exp_label.text = "%d" %  actor.get_phy_exp()
	tec_exp_label.text = "%d" %  actor.get_tec_exp()
	mnd_exp_label.text = "%d" %  actor.get_mnd_exp()
	for button in list.get_children(): if button is Button:
		if not button.has_meta("skill"): continue
		var skill : Skill = button.get_meta("skill")
		button.disabled = not actor.has_exp_to_skill(skill)
		button.text = "%s (%d → %d)" % [
			skill.display_name,
			actor.get_skill_level(skill),
			actor.get_skill_level(skill) + 1
		]
		var next := actor.get_skill_level(skill) + 1
		var phy_label : Label = button.get_meta("phy_label")
		var tec_label : Label = button.get_meta("tec_label")
		var mnd_label : Label = button.get_meta("mnd_label")
		phy_label.text = str(skill.next_phy(next))
		tec_label.text = str(skill.next_tec(next))
		mnd_label.text = str(skill.next_mnd(next))
	print(str(actor.skills))

func _button_pressed(skill : Skill) -> void:
	var ret := await Game.popup_yn("経験点を消費して%sを上昇させます。よろしいですか？" % skill.display_name)
	if ret: actor.consume_exp_to_skill(skill)
	actor.mod_skill_level(skill, 1)
	_update()

func on_focus_button(_actor : Actor):
	super.on_focus_button(_actor)
	_init_list(actor)

func on_selected(_actor : Actor):
	super.on_selected(_actor)
	_init_list(actor)
	focus_button.grab_focus()
	await resume_actor_select

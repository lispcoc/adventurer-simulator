class_name SkillSubMenu extends BaseSubmenuWithActor

var skill_list : CtrlInventory
var user : Actor
var used_skill : Skill

func _ready() -> void:
	skill_list = %SkillList
	skill_list.inventory_item_activated.connect(_on_skill_selected)
	CharacterPanelUi.canceled.connect(_on_target_select_canceled)
	CharacterPanelUi.pressed.connect(_on_target_selected)
	%MessagePanel.hide()
	super._ready()

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_pressed("ui_cancel"):
		if skill_list.has_focus():
			resume_actor_select.emit()
			get_viewport().set_input_as_handled()

func on_focus_button(actor : Actor):
	var _inventory = Inventory.new()
	skill_list.inventory = _inventory
	for skill in actor.get_skills():
		var inv_skill = InventoryItem.new()
		inv_skill.set_property("name", skill.display_name())
		inv_skill.set_property("skill", skill)
		_inventory.add_item(inv_skill)
	super.on_focus_button(actor)

func on_selected(actor : Actor):
	super.on_selected(actor)
	user = actor
	skill_list.grab_focus()
	skill_list.select(0)
	await resume_actor_select

func _on_skill_selected(inv_skill : InventoryItem):
	CharacterPanelUi.end_select()
	var skill : Skill = inv_skill.get_property("skill")
	if not skill.data.outside_of_battle:
		%MessagePanel.show()
		%Message.text = "%sは戦闘中にしか使用できません。" % skill.display_name()
		return
	used_skill = skill
	if skill.data.target == Game.Target.PartyOne:
		%MessagePanel.show()
		%Message.text = "%sを誰に使用しますか？" % skill.display_name()
		CharacterPanelUi.start_select()
	elif skill.data.target == Game.Target.PartyLine or skill.data.target == Game.Target.PartyAll:
		%MessagePanel.show()
		%Message.text = "%sを誰に使用しますか？" % skill.display_name()
		CharacterPanelUi.start_select(true)
		

func _on_target_select_canceled() -> void:
	%Message.text = ""
	%MessagePanel.hide()
	skill_list.grab_focus()

func _on_target_selected(targets : Array[Actor]) -> void:
	for target in targets:
		var chk := used_skill.can_use(user, target)
		if chk.success:
			var ret := used_skill.use(user, target)
		else: %Message.text = chk.fail_message

class_name AbilitySubMenu extends BaseSubmenuWithActor

var ability_list : CtrlInventory
var user : Actor
var used_ability : Ability

func _ready() -> void:
	ability_list = %SkillList
	ability_list.inventory_item_activated.connect(_on_ability_selected)
	CharacterPanelUi.canceled.connect(_on_target_select_canceled)
	CharacterPanelUi.pressed.connect(_on_target_selected)
	%MessagePanel.hide()
	super._ready()

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_pressed("ui_cancel"):
		if ability_list.has_focus():
			resume_actor_select.emit()
			get_viewport().set_input_as_handled()

func on_focus_button(actor : Actor):
	var _inventory = Inventory.new()
	ability_list.inventory = _inventory
	for ability in actor.get_abilities():
		var inv_ability = InventoryItem.new()
		inv_ability.set_property("name", ability.display_name())
		inv_ability.set_property("ability", ability)
		_inventory.add_item(inv_ability)
	super.on_focus_button(actor)

func on_selected(actor : Actor):
	super.on_selected(actor)
	user = actor
	ability_list.grab_focus()
	ability_list.select(0)
	await resume_actor_select

func _on_ability_selected(inv_ability : InventoryItem):
	CharacterPanelUi.end_select()
	var ability : Ability = inv_ability.get_property("ability")
	if not ability.data.outside_of_battle:
		%MessagePanel.show()
		%Message.text = "%sは戦闘中にしか使用できません。" % ability.display_name()
		return
	used_ability = ability
	if ability.data.target_type == Game.Target.PartyOne:
		%MessagePanel.show()
		%Message.text = "%sを誰に使用しますか？" % ability.display_name()
		CharacterPanelUi.start_select()
	elif ability.data.target_type in [Game.Target.PartyLine, Game.Target.PartyAll]:
		%MessagePanel.show()
		%Message.text = "%sを誰に使用しますか？" % ability.display_name()
		CharacterPanelUi.start_select(true)
		

func _on_target_select_canceled() -> void:
	%Message.text = ""
	%MessagePanel.hide()
	ability_list.grab_focus()

func _on_target_selected(targets : Array[Actor]) -> void:
	for target in targets:
		var chk := used_ability.can_use(user, target)
		if chk.success:
			var _ret := used_ability.use(user, target)
		else: %Message.text = chk.fail_message

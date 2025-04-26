class_name BattleActorEnemy extends BattleActor

var default_sprite : Texture2D = preload("res://assets/monsters/Battlers/World01_001_GreenGoo.png")

var sprite : Sprite2D
var label : RichTextLabel
var label_panel : PanelContainer

func _init() -> void:
	button = TextureButton.new()
	super._init()

func _ready():
	super._ready()
	button.focus_entered.connect(on_focus_entered)
	button.focus_exited.connect(on_focus_exited)
	var t_button : TextureButton = button
	t_button.texture_normal = default_sprite
	#t_button.custom_minimum_size = t_button.texture_normal.get_size()
	t_button.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)

	label_panel = PanelContainer.new()
	label_panel.custom_minimum_size = Vector2(200, 32)
	label_panel.position.y = t_button.texture_normal.get_size().y
	label_panel.position.x = -100 + t_button.texture_normal.get_size().x / 2
	label = RichTextLabel.new()
	label_panel.add_child(label)
	label_panel.hide()
	t_button.add_child(label_panel)

func on_focus_entered():
	label_panel.show()
	label.text = display_name()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	pop_cursor()

func on_focus_exited():
	label_panel.hide()
	remove_cursor()

func on_dead():
	await vanish()
	hide()

func is_enemy() -> bool:
	return true

func get_center_top() -> Vector2:
	return Vector2(0, 0)

func get_act(by_front : bool, enemy_front : Array[BattleActor], enemy_back : Array[BattleActor]) -> Act:
	var ret = Act.new()
	var skills = actor.get_skills()
	skills.shuffle()
	ret.skill = skills[0]
	var range = ret.skill.data.range
	if by_front: range = range + 1
	match ret.skill.data.target:
		Game.Target.EnemyAll:
			ret.targets = enemy_front + enemy_back
		Game.Target.EnemyLine:
			if range >= 3 and not enemy_back.is_empty():
				ret.targets = [enemy_front, enemy_back][randi() % 2]
			elif range >= 2:
				ret.targets = enemy_front
		Game.Target.EnemyOne:
			var possible : Array[BattleActor]
			if range >= 3 and not enemy_back.is_empty():
				possible = enemy_front + enemy_back
			elif range >= 2:
				possible = enemy_front
			if not possible.is_empty():
				ret.targets.append(possible[randi() % possible.size()])
	return ret

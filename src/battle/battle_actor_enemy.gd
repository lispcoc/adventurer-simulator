class_name BattleActorEnemy extends BattleActor

var default_sprite : Texture2D = preload("res://assets/monsters/Battlers/World01_001_GreenGoo.png")

var sprite_id : String
var label : RichTextLabel
var label_panel : PanelContainer

func _init() -> void:
	button = TextureButton.new()
	super._init()

func _ready() -> void:
	super._ready()
	button.focus_entered.connect(on_focus_entered)
	button.focus_exited.connect(on_focus_exited)
	var t_button : TextureButton = button
	if not sprite_id.is_empty() and SpriteManager.load_battle_actor(sprite_id):
		t_button.texture_normal = SpriteManager.load_battle_actor(sprite_id)
	else:
		t_button.texture_normal = default_sprite
	t_button.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	custom_minimum_size = t_button.texture_normal.get_size() + Vector2(32, 32)
	label_panel = PanelContainer.new()
	label_panel.custom_minimum_size = Vector2(200, 32)
	label_panel.position.y = t_button.texture_normal.get_size().y
	label_panel.position.x = -100 + t_button.texture_normal.get_size().x / 2
	label_panel.z_index = 1
	label = RichTextLabel.new()
	label_panel.add_child(label)
	label_panel.hide()
	t_button.add_child(label_panel)

func load_from_monster_data(data : MonsterData) -> void:
	actor = Actor.new()
	actor.class_id = data.class_id
	actor.initialize_actor()
	actor.actor_name = data.display_name
	sprite_id = data.sprite_id
	for sid in data.abilities:
		actor.abilities.append(StaticData.ability_from_id(sid).instantiate())

func on_focus_entered() -> void:
	label_panel.show()
	label.text = display_name()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	pop_cursor()

func on_focus_exited() -> void:
	label_panel.hide()
	remove_cursor()

func on_dead() -> void:
	await vanish()
	hide()

func is_enemy() -> bool: return true

func get_act(by_front : bool, enemy_front : Array[BattleActor], enemy_back : Array[BattleActor]) -> Act:
	var ret = Act.new()
	var abilities = actor.get_abilities()
	abilities.shuffle()
	ret.ability = abilities[0]
	var target_range = ret.ability.data.target_range
	if by_front: target_range += 1
	match ret.ability.data.target_type:
		Game.Target.EnemyAll:
			ret.targets = enemy_front + enemy_back
		Game.Target.EnemyLine:
			if target_range >= 3 and not enemy_back.is_empty():
				ret.targets = [enemy_front, enemy_back][randi() % 2]
			elif target_range >= 2:
				ret.targets = enemy_front
		Game.Target.EnemyOne:
			var possible : Array[BattleActor]
			if target_range >= 3 and not enemy_back.is_empty():
				possible = enemy_front + enemy_back
			elif target_range >= 2:
				possible = enemy_front
			if not possible.is_empty():
				ret.targets.append(possible[randi() % possible.size()])
	return ret

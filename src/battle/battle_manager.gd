class_name BattleManager extends Node

signal exit_battle

@export var party_container : UIBattleActorContainer
@export var enemy_container : UIBattleActorContainer
@export var message : RichTextLabel

var party_front : Array[BattleActor]
var party_back : Array[BattleActor]
var enemies_front : Array[BattleActor]
var enemies_back : Array[BattleActor]

var current_actor : BattleActor

func _ready() -> void:
	party_container.selected.connect(on_target_selected)
	party_container.canceled.connect(on_target_select_canceled)
	enemy_container.selected.connect(on_target_selected)
	enemy_container.canceled.connect(on_target_select_canceled)
	test()

func _process(_delta: float) -> void:
	pass

func test():
	party_front.append(BattleActorPlayer.new())
	party_front.append(BattleActorPlayer.new())
	party_front.append(BattleActorPlayer.new())
	party_back.append(BattleActorPlayer.new())
	enemies_front.append(BattleActorEnemy.new())
	enemies_front.append(BattleActorEnemy.new())
	enemies_front.append(BattleActorEnemy.new())
	start() 

func on_target_selected(actors : Array[BattleActor]):
	print("on_enemy_selected")
	print(actors)
	for a in actors:
		await a.blink()
		a.hp -= current_actor.roll_melee_damage()
	message.text = actors[0].name
	exit_main_phase.emit()

func on_target_select_canceled():
	print("on_enemy_select_cancel")

func start() -> void:
	for e in party_front: party_container.add_actor_front(e)
	for e in party_back: party_container.add_actor_back(e)
	for e in enemies_front: enemy_container.add_actor_front(e)
	for e in enemies_back: enemy_container.add_actor_back(e)
	await main_loop()
	await Transition.cover(0.5)
	queue_free()
	exit_battle.emit()

func get_party() -> Array[BattleActor]:
	return party_front + party_back

func get_enemies() -> Array[BattleActor]:
	return enemies_front + enemies_back


#
# turn manager
#
signal exit_main_phase

enum Phase {
	Setup,
	Initiative,
	Main,
	Cleanup,
}

enum BattleResult {
	Win,
	Lose,
	Run,
}

func main_loop() -> BattleResult:
	while !get_party().is_empty() && !get_enemies().is_empty():
		# Setup
		var initiative_list : Array[BattleActor] = get_party() + get_enemies()
		initiative_list.sort_custom(func(a, b): return a.speed() < b.speed())
		for c in initiative_list:
			c.available = true
		# Initiative
		for c in initiative_list:
			if !c.is_dead() && c.available:
				# Main
				current_actor = c
				if c.is_player():
					enemy_container.start_select_line()
				if c.is_enemy():
					party_container.start_select_line()
				await exit_main_phase
				c.available = false
			if is_dead_all(get_party()) || is_dead_all(get_enemies()):
				break
		# Cleanup
		if is_dead_all(get_party()):
			return BattleResult.Lose
		if is_dead_all(get_enemies()):
			return BattleResult.Win
	return BattleResult.Win

func is_dead_all(actors : Array[BattleActor]):
	for e in actors: if !e.is_dead(): return false
	return true

func get_phase() -> Phase:
	return Phase.Initiative

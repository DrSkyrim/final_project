extends CanvasLayer

@export var max_heat := 100
var current_heat := 0

var player_turn := true
var in_combat := false

var player_ref
var enemies := []        # all enemies currently in encounter
var target_enemy         # selected enemy

@onready var heat_bar: TextureProgressBar = $Panel/HeatContainer/HeatBar
@onready var turn_info: Label = $Panel/VBoxContainer/TurnInfo
@onready var enemy_list: VBoxContainer = $Panel/EnemyList
@export var enemy_base_hit := 0.15
@export var enemy_max_hit := 0.60


func _ready():
	visible = false
	update_heat_bar()

# ---------------------------------------------------------
# ENCOUNTER MANAGEMENT
# ---------------------------------------------------------
func add_enemy_to_encounter(enemy):
	if not in_combat:
		_start_combat(enemy)
	else:
		enemies.append(enemy)
		_refresh_enemy_list()

func _start_combat(first_enemy):
	in_combat = true
	player_turn = true
	current_heat = 0

	player_ref = get_tree().get_first_node_in_group("player")
	player_ref.lock_controls()

	visible = true

	enemies = [first_enemy]
	target_enemy = null

	_refresh_enemy_list()
	turn_info.text = "Combat started! Choose an action."

func end_combat():
	in_combat = false
	visible = false

	player_ref.unlock_controls()

	enemies.clear()
	target_enemy = null

# ---------------------------------------------------------
# PLAYER ATTACK HANDLERS
# ---------------------------------------------------------
func on_attack_button_pressed(heat_gain: int, base_hit: float, max_hit: float):
	if not player_turn:
		return
	if enemies.size() == 0:
		return
	if target_enemy == null:
		turn_info.text = "Pick a target!"
		return

	# Add heat
	current_heat = clamp(current_heat + heat_gain, 0, max_heat)
	update_heat_bar()

	# Calculate hit chance based on heat
	var chance: float = lerp(base_hit, max_hit, float(current_heat) / max_heat)


	if randf() <= chance:
		turn_info.text = "Hit! Enemy defeated!"
		target_enemy.die()
	else:
		turn_info.text = "Miss! Enemies prepare to attack..."

	player_turn = false
	await enemy_turn()

# Attack definitions
func _on_attack_1_pressed(): on_attack_button_pressed(10, 0.20, 0.90); player_ref.play_shoot_animation();
func _on_attack_2_pressed(): on_attack_button_pressed(20, 0.07, 0.75); player_ref.play_shoot_animation();

func _on_attack_3_pressed():
	current_heat = clamp(current_heat - 20, 0, max_heat)
	update_heat_bar()
	turn_info.text = "You dodge!"
	player_turn = false
	await enemy_turn()

func _on_attack_4_pressed():
	if randf() <= 0.05:
		current_heat = clamp(current_heat * 2, 0, max_heat)
		turn_info.text = "Critical lasso! Heat doubled!"
	else:
		current_heat = clamp(current_heat + 15, 0, max_heat)
		turn_info.text = "Lasso used!"
	update_heat_bar()
	player_turn = false
	await enemy_turn()

# ---------------------------------------------------------
# ENEMY TURN ORDER
# ---------------------------------------------------------
func enemy_turn():
	await get_tree().create_timer(1.0).timeout

	if enemies.size() == 0:
		turn_info.text = "All enemies defeated!"
		await get_tree().create_timer(1.0).timeout
		end_combat()
		return

	for enemy in enemies:
		if enemy.has_method("play_shoot_anim"):
			enemy.play_shoot_anim()

		await get_tree().create_timer(0.3).timeout   # small delay for animation
		var chance: float = lerp(enemy_base_hit, enemy_max_hit, float(current_heat) / max_heat)

		if randf() <= chance:
			turn_info.text = "Enemy hits you! You died!"
			player_ref.die()
			await get_tree().create_timer(1.0).timeout
			end_combat()
			return
		else:
			turn_info.text = "Enemy missed!"

		await get_tree().create_timer(0.6).timeout

	player_turn = true
	turn_info.text = "Your turn."


# ---------------------------------------------------------
# ENEMY DEATH HANDLING
# ---------------------------------------------------------
func notify_enemy_dead(enemy):
	enemies.erase(enemy)
	_refresh_enemy_list()

	if enemies.size() == 0:
		turn_info.text = "You defeated all enemies!"
		await get_tree().create_timer(1.0).timeout
		end_combat()

# ---------------------------------------------------------
# UI HELPERS
# ---------------------------------------------------------
func update_heat_bar():
	if heat_bar:
		heat_bar.value = current_heat

func _refresh_enemy_list():
	# Remove old buttons
	for child in enemy_list.get_children():
		child.queue_free()

	# Add each enemy as a button
	for enemy in enemies:
		var btn := Button.new()
		btn.text = enemy.name
		btn.pressed.connect(func():
			target_enemy = enemy
			turn_info.text = "Target selected: %s" % enemy.name
		)
		enemy_list.add_child(btn)

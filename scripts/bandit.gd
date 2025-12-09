extends CharacterBody2D

@export var speed := 80.0
@export var detection_radius := 200.0
@export var stop_distance := 60.0
@export var random_move_interval := 1.0

@onready var animated_sprite_bandit: AnimatedSprite2D = $AnimatedSprite2D

var player: Node2D
var random_direction := Vector2.ZERO
var time_until_new_direction := 0.0
var combat_started := false
var combat_controller

func _ready() -> void:
	# Ensure player exists
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	combat_controller = get_tree().get_first_node_in_group("combat_ui")
	add_to_group("enemy")

func start_combat():
	if combat_started:
		return

	combat_started = true
	combat_controller.add_enemy_to_encounter(self)

func die():
	# Disable collisions so the dead body doesn't block player
	collision_layer = 0
	collision_mask = 0

	combat_controller.notify_enemy_dead(self)

	# Remove enemy from world
	queue_free()


func _process(delta: float) -> void:
	if not player:
		return

	var distance_to_player = global_position.distance_to(player.global_position)

	if distance_to_player <= detection_radius:
		follow_player(delta, distance_to_player)
	else:
		random_movement(delta)
	if distance_to_player <= stop_distance and not combat_started:
		start_combat()


	update_animation()


func follow_player(delta: float, distance_to_player: float) -> void:
	if distance_to_player <= stop_distance:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var dir = (player.global_position - global_position).normalized()
	velocity = dir * speed
	move_and_slide()


func random_movement(delta: float) -> void:
	time_until_new_direction -= delta

	if time_until_new_direction <= 0.0:
		random_direction = Vector2(
			randf_range(-1, 1),
			randf_range(-1, 1)
		).normalized()

		time_until_new_direction = random_move_interval

	velocity = random_direction * speed * 0.4
	move_and_slide()


# ---------------------------------------------------------------
# ANIMATION + FLIP CONTROL
# ---------------------------------------------------------------
func update_animation() -> void:
	if velocity.length() > 1:
		# Play movement animation
		if animated_sprite_bandit.animation != "movement":
			animated_sprite_bandit.play("movement")

		# Flip horizontally based on movement direction
		if velocity.x != 0:
			animated_sprite_bandit.flip_h = velocity.x < 0

	else:
		# Play idle animation
		if animated_sprite_bandit.animation != "Idle":
			animated_sprite_bandit.play("Idle")
			
func play_shoot_anim():
	animated_sprite_bandit.play("shoot")
			

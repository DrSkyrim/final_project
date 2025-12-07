extends CharacterBody2D


var SPEED:float = 100
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D



func _physics_process(delta: float) -> void:

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction_y := Input.get_axis("move_up", "move_down")
	var direction_x := Input.get_axis("move_left", "move_right")
	if direction_y:
		animated_sprite_2d.play("run")
		if(Input.is_action_pressed("sprint")):
			SPEED = 150
		else:
			SPEED = 100
		velocity.y = direction_y * SPEED
	elif direction_x:
		if direction_x > 0:
			animated_sprite_2d.flip_h = false
		elif direction_x < 0:
			animated_sprite_2d.flip_h = true
		animated_sprite_2d.play("run")
		if(Input.is_action_pressed("sprint")):
			SPEED = 150
		else:
			SPEED = 100
		velocity.x = direction_x * SPEED
	else: 
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)
		animated_sprite_2d.play("Idle")

	move_and_slide()

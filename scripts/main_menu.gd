extends CanvasLayer

@onready var start_button: Button = $VBoxContainer/StartButton

func _ready():
	# Connect button signal
	start_button.pressed.connect(_on_start_pressed)

func _on_start_pressed():
	# Hide the main menu
	visible = false

	# Load your game scene
	var game_scene = load("res://scenes/Game.tscn").instantiate()
	get_tree().root.add_child(game_scene)

	# Optionally make menu free itself
	queue_free()

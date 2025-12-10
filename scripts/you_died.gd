extends CanvasLayer

@onready var restart_button: Button = $VBoxContainer/RestartButton


func _ready():
	# Connect button signal
	restart_button.pressed.connect(_on_restart_pressed)

func _on_restart_pressed():
	# Hide the main menu
	visible = false

	# Load your game scene
	var game_scene = load("res://Scenes/main_menu.tscn").instantiate()
	get_tree().root.add_child(game_scene)

	# Optionally make menu free itself
	queue_free()

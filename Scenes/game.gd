extends Node2D

@onready var main_character: CharacterBody2D = $Main_Character

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !main_character:
		queue_free()

extends Node2D

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("select_game"):
		exit_game()

func exit_game() -> void:
	get_tree().change_scene_to_file("res://main_menu/main_menu.tscn")

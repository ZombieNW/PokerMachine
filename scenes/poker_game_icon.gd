extends PanelContainer

@export var game_scene: PackedScene

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		get_tree().change_scene_to_packed(game_scene)

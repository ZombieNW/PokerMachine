extends PanelContainer

class_name GameIcon

@export var selected: bool = false
@export var game_scene: PackedScene
@export var game_icon: Texture

func select() -> void:
	selected = true
	$OutlinePanel.show()

func unselect() -> void:
	selected = false
	$OutlinePanel.hide()

func _ready() -> void:
	$TextureRect.texture = game_icon

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		run_game()

func run_game() -> void:
	get_tree().change_scene_to_packed(game_scene)

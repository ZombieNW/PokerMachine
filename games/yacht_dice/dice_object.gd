extends Control
class_name DiceObject

@export var value: int = 1
@export var held: bool = false

@onready var dice_textures: Dictionary[int, Texture] = {
	1: preload("uid://b7rgvjc6e1gi3"),
	2: preload("uid://bpqjqkcalfo0a"),
	3: preload("uid://fvqqgslls8np"),
	4: preload("uid://c4g3vgjoa2d5n"),
	5: preload("uid://coeh0vwe3jp2e"),
	6: preload("uid://cg2hbbto2adc2")
}

func roll() -> void:
	value = randi_range(1, 6)
	update_state()

func set_held(is_held: bool) -> bool:
	held = is_held
	$HeldLabel.visible = held
	return held

func toggle_held() -> void:
	held = set_held(!held)

func update_state() -> void:
	$TextureRect.texture = dice_textures[value]

extends Area2D
class_name CardObject

const CARD_TEXTURE_PATH: String = "res://common/assets/kenney_cards/card_%s.png"

@export var held: bool = false

# Enable or disable held label
func set_held(is_held: bool) -> bool:
	held = is_held
	$CardSprite/HoldLabel.visible = held
	return held

# Toggle held state
func toggle_held() -> void:
	held = set_held(!held)

# Set the card from card name
func set_card(card_name: String) -> void:
	$CardSprite.texture = get_card_texture(card_name)

# Get card texture file from card name string
func get_card_texture(card_name: String) -> Texture:
	return load(CARD_TEXTURE_PATH % card_name)

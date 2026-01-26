extends TileMapLayer
const DeckScript = preload("uid://bdo7l5yfgwr6q")
var DeckInstance

var cards = [
	null,null,null,null,null
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DeckInstance = DeckScript.new()
	new_cards()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		new_cards()

func new_cards(held_card_indexes: Array[int] = []):
	var cards_to_replace = range(cards.size())
	cards_to_replace.erase(held_card_indexes)
	
	for index in cards_to_replace:
		DeckInstance.return_card(cards[index])
		cards[index] = DeckInstance.get_card()
	refresh_cards()

func get_card_texture(card_name: String) -> Texture:
	return load("res://assets/kenney_playing-cards-pack/card_" + card_name + ".png")

func refresh_cards() -> void:
	%Card1.texture = get_card_texture(cards[0])
	%Card2.texture = get_card_texture(cards[1])
	%Card3.texture = get_card_texture(cards[2])
	%Card4.texture = get_card_texture(cards[3])
	%Card5.texture = get_card_texture(cards[4])

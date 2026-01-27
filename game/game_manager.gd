extends TileMapLayer

const DeckScript = preload("uid://bdo7l5yfgwr6q")

var DeckInstance

var cards: Array[String] = ["", "", "", "", ""]
var held: Array[int] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DeckInstance = DeckScript.new()
	new_cards()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		new_cards()
	elif event.is_action_pressed("hold_1"):
		if held.has(0): held.erase(0)
		else: held.append(0)
	elif event.is_action_pressed("hold_2"):
		if held.has(1): held.erase(1)
		else: held.append(1)
	elif event.is_action_pressed("hold_3"):
		if held.has(2): held.erase(2)
		else: held.append(2)
	elif event.is_action_pressed("hold_4"):
		if held.has(3): held.erase(3)
		else: held.append(3)
	elif event.is_action_pressed("hold_5"):
		if held.has(4): held.erase(4)
		else: held.append(4)
	refresh_hold_labels()

# Return cards in hand and get new cards (with option to hold back cards)
func new_cards():
	for i in range(cards.size()):
		# Skip held cards
		if i in held: continue
		
		# Return old card to deck
		if cards[i]: DeckInstance.return_card(cards[i])
		
		# Get new card
		cards[i] = DeckInstance.get_card()
	refresh_card_textures()
	print(PokerHandEvaluator.evaluate_hand(cards).name)

# Get card texture file from card name string
func get_card_texture(card_name: String) -> Texture:
	return load("res://assets/kenney_playing-cards-pack/card_" + card_name + ".png")

# Update card textures to reflect game cards
func refresh_card_textures() -> void:
	%Card1.texture = get_card_texture(cards[0])
	%Card2.texture = get_card_texture(cards[1])
	%Card3.texture = get_card_texture(cards[2])
	%Card4.texture = get_card_texture(cards[3])
	%Card5.texture = get_card_texture(cards[4])

func refresh_hold_labels() -> void:
	(%Card1.find_child("HoldLabel") as Label).visible = 0 in held
	(%Card2.find_child("HoldLabel") as Label).visible = 1 in held
	(%Card3.find_child("HoldLabel") as Label).visible = 2 in held
	(%Card4.find_child("HoldLabel") as Label).visible = 3 in held
	(%Card5.find_child("HoldLabel") as Label).visible = 4 in held
		 

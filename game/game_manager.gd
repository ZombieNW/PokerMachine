extends TileMapLayer

const DeckScript = preload("uid://bdo7l5yfgwr6q")
const PriceTableScript = preload("uid://depyceufqrs32")

const DEFAULT_CARD_COUNT: int = 5
const MAX_BET: int = 5
const STARTING_CREDITS: int = 5
const CARD_TEXTURE_PATH: String = "res://assets/kenney_playing-cards-pack/card_%s.png"

var DeckInstance = DeckScript.new()
var cards: Array[String] = ["", "", "", "", ""]
var held: Array[int] = []
var bet: int = 1
var credits: int = STARTING_CREDITS

@onready var card_sprites: Array[Sprite2D] = [%Card1, %Card2, %Card3, %Card4, %Card5]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	new_cards()

func _input(event: InputEvent) -> void:
	# Hold Card
	for i in range(cards.size()):
		if event.is_action_pressed("hold_%d" % (i + 1)):
			hold_card(i)
			update_state()
			return
	
	if event.is_action_pressed("ui_accept"):
		new_cards()
	elif event.is_action_pressed("bet"):
		bet = (bet % MAX_BET) + 1
		update_state()

# Return cards in hand and get new cards
func new_cards():
	for i in range(cards.size()):
		# Skip held cards
		if i in held: continue
		
		# Return old card to deck
		if cards[i] != "back": DeckInstance.return_card(cards[i])
		
		# Get new card (and throw error if none are left in deck)
		var new_card = DeckInstance.get_card()
		if !new_card:
			push_error("Deck is Empty :(")
			return
		cards[i] = new_card

func update_state() -> void:
	refresh_hold_labels()
	refresh_card_textures()
	%PriceTable.set_price_panel(bet - 1)
	%CreditLabel.text = "%d Credits" % credits
	%BetLabel.text = "Bet %d" % bet
	%TitleBetLabel.text = "Bet %d" % bet
	
	if not cards.has("back"):
		%HandLabel.text = PokerHandEvaluator.evaluate_hand(cards).name
	else:
		%HandLabel.text = ""

func hold_card(card_index: int) -> void:
	# TODO reject if not in initial deal game state
	if card_index in held:
		held.erase(card_index)
	else:
		held.append(card_index)
	held.sort()

# Get card texture file from card name string
func get_card_texture(card_name: String) -> Texture:
	return load(CARD_TEXTURE_PATH % card_name)

# Update card textures to reflect game cards
func refresh_card_textures() -> void:
	for i in cards.size():
		card_sprites[i].texture = get_card_texture(cards[i])

# Add hold label above card if in held array
func refresh_hold_labels() -> void:
	for i in cards.size():
		var hold_label = card_sprites[i].find_child("HoldLabel") as Label
		hold_label.visible = i in held		 

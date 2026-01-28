extends TileMapLayer

const DeckScript = preload("uid://bdo7l5yfgwr6q")
const PriceTableScript = preload("uid://depyceufqrs32")

enum GameState { BET, INITIAL_DEAL, DRAW, EVALUATE, CREDITS}

const DEFAULT_CARD_COUNT: int = 5
const MAX_BET: int = 5
const STARTING_CREDITS: int = 5
const CARD_TEXTURE_PATH: String = "res://assets/kenney_playing-cards-pack/card_%s.png"

var DeckInstance = DeckScript.new()
var cards: Array[String] = []
var held: Array[int] = []
var bet: int = 1
var credits: int = STARTING_CREDITS
var game_state: GameState = GameState.BET

@onready var card_sprites: Array[Sprite2D] = [%Card1, %Card2, %Card3, %Card4, %Card5]

func _ready() -> void:
	end_game()

func _input(event: InputEvent) -> void:
	# Hold Card
	for i in range(cards.size()):
		if event.is_action_pressed("hold_%d" % (i + 1)):
			hold_card(i)
			update_state()
			return
	
	if event.is_action_pressed("ui_accept"):
		handle_deal_draw()
	elif event.is_action_pressed("bet"):
		cycle_bet()
		update_state()
	elif event.is_action_pressed("add_credit"):
		add_credit()

# Start or reset a game
func start_game() -> void:
	if credits < bet:
		%HandLabel.text = "Insufficient Credits"
		return
	
	%HandLabel.text = ""
	credits -= bet
	new_cards()
	game_state = GameState.INITIAL_DEAL
	update_state()

# After evaluation
func end_game() -> void:
	if credits <= 0:
		out_of_credits()
		return
	
	%TitleContainer.hide()
	game_state = GameState.BET
	cards.resize(DEFAULT_CARD_COUNT)
	cards.fill("back")
	held.clear()
	DeckInstance.reset_deck()
	%HandLabel.text = "Place Your Bets"
	update_state()

# When deal/draw button pressed, essentially a "next"
func handle_deal_draw() -> void:
	match game_state:
		GameState.BET:
			start_game()
		GameState.INITIAL_DEAL:
			draw_cards()
		GameState.EVALUATE:
			end_game()

# The middle turn of the game
func draw_cards() -> void:
	new_cards()
	game_state = GameState.EVALUATE
	evaluate()
	update_state()

# add credit and escape no credit screen
func add_credit():
	credits += 1
	if game_state == GameState.CREDITS:
		end_game()
	update_state()

# Evaluate hand and payout
func evaluate() -> void:
	var hand_result = PokerHandEvaluator.evaluate_hand(cards)
	var payout = PokerHandEvaluator.get_payout(hand_result.rank, bet)
	%HandLabel.text = hand_result.name
	credits += payout

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

# Update UI/Labels
func update_state() -> void:
	refresh_hold_labels()
	refresh_card_textures()
	%PriceTable.set_price_panel(bet - 1)
	%CreditLabel.text = "%d Credits" % credits
	%BetLabel.text = "Bet %d" % bet

# Display game over screen when out of credits
func out_of_credits() -> void:
	game_state = GameState.CREDITS
	%TitleContainer.show()
	%TitleLabel.text = "Out of Credits"

# Helper function to cycle bet in first stage
func cycle_bet() -> void:
	if game_state == GameState.BET:
		bet = (bet % MAX_BET) + 1

# Helper function to hold a card by index
func hold_card(card_index: int) -> void:
	if game_state != GameState.INITIAL_DEAL: return

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

extends TileMapLayer

const DeckScript = preload("uid://bdo7l5yfgwr6q")
const PriceTableScript = preload("uid://depyceufqrs32")

enum GameState { BET, INITIAL_DEAL, DRAW, EVALUATE, CREDITS}

const DEFAULT_CARD_COUNT: int = 5
const MAX_BET: int = 5

const CARD_BACK: String = "back"
const INSUFFICIENT_CREDITS_MSG: String = "Insufficient Credits"
const PLACE_BETS_MSG: String = "Place Your Bets"
const OUT_OF_CREDITS_MSG: String = "Out of Credits"

var DeckInstance = DeckScript.new()
var cards: Array[String] = []
var held: Array[int] = []
var bet: int = 1
var game_state: GameState = GameState.CREDITS

@onready var card_objects: Array[CardObject] = [%Card1, %Card2, %Card3, %Card4, %Card5]

func _ready() -> void:
	# Hook card click to hold card
	for i in card_objects.size():
		card_objects[i].input_event.connect(func(_vp, event, _si):
			if event is InputEventMouseButton and event.pressed:
				hold_card(i)
		)
	update_state()
	end_game()

func _input(event: InputEvent) -> void:
	# Hold Card
	for i in range(cards.size()):
		if event.is_action_pressed("hold_%d" % (i + 1)):
			hold_card(i)
			return
	
	if event.is_action_pressed("ui_accept"):
		handle_deal_draw()
	elif event.is_action_pressed("bet"):
		cycle_bet()
	elif event.is_action_pressed("add_credit"):
		check_credit()
	elif event.is_action_pressed("select_game"):
		exit_game()

# Start or reset a game
func start_game() -> void:
	if Credit.get_credits() < bet:
		%HandLabel.text = INSUFFICIENT_CREDITS_MSG
		return
	
	%HandLabel.text = ""
	Credit.subtract(bet)
	game_state = GameState.INITIAL_DEAL
	new_cards()
	update_state()

# After evaluation
func end_game() -> void:
	if Credit.get_credits() <= 0:
		out_of_credits()
		return
	
	game_state = GameState.BET
	DeckInstance.reset_deck()
	reset_cards_and_ui()

func exit_game() -> void:
	if game_state == GameState.BET or game_state == GameState.EVALUATE or game_state == GameState.CREDITS:
		get_tree().change_scene_to_file("res://main_menu/main_menu.tscn")

# Reset cards and UI
func reset_cards_and_ui() -> void:
	cards.assign([CARD_BACK, CARD_BACK, CARD_BACK, CARD_BACK, CARD_BACK])
	held.clear()
	%TitleContainer.hide()
	%HandLabel.text = PLACE_BETS_MSG
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
	game_state = GameState.EVALUATE
	new_cards()
	evaluate()
	update_state()

# escape no credit screen
func check_credit():
	await get_tree().process_frame
	if game_state == GameState.CREDITS:
		end_game()
	update_state()

# Evaluate hand and payout
func evaluate() -> void:
	var hand_result = PokerHandEvaluator.evaluate_hand(cards)
	var payout = PokerHandEvaluator.get_payout(hand_result.rank, bet)
	%HandLabel.text = hand_result.name
	Credit.add(payout)

# Return cards in hand and get new cards
func new_cards():
	for i in range(cards.size()):
		# Skip held cards
		if i in held: continue
		
		# Return old card to deck
		if cards[i] != CARD_BACK: DeckInstance.return_card(cards[i])
		
		# Get new card (and throw error if none are left in deck)
		cards[i] = DeckInstance.get_card()
		if !cards[i]:
			push_error("Deck is Empty :(")
			return

# Update UI/Labels
func update_state() -> void:
	refresh_hold_labels()
	refresh_card_textures()
	%PriceTable.set_price_panel(bet - 1)
	%CreditLabel.text = "%d Credits" % Credit.get_credits()
	%BetLabel.text = "Bet %d" % bet

# Display game over screen when out of credits
func out_of_credits() -> void:
	game_state = GameState.CREDITS
	%TitleContainer.show()
	%TitleLabel.text = OUT_OF_CREDITS_MSG

# Helper function to cycle bet in first stage
func cycle_bet() -> void:
	if game_state == GameState.BET:
		bet = (bet % MAX_BET) + 1
	update_state()

# Helper function to hold a card by index
func hold_card(card_index: int) -> void:
	if game_state != GameState.INITIAL_DEAL: return

	if card_index in held:
		held.erase(card_index)
	else:
		held.append(card_index)
	held.sort()
	update_state()

# Update card textures to reflect game cards
func refresh_card_textures() -> void:
	for i in cards.size():
		card_objects[i].set_card(cards[i])

# Add hold label above card if in held array
func refresh_hold_labels() -> void:
	for i in cards.size():
		card_objects[i].set_held(i in held)

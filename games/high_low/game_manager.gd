extends Node2D

const DeckScript = preload("uid://bdo7l5yfgwr6q")
var DeckInstance = DeckScript.new()


const MAX_BET: int = 5
enum GUESSES {HIGHER, LOWER}

@onready var previous_card_object: CardObject = %PrevCard
@onready var current_card_object: CardObject = %CurrentCard
@onready var next_card_object: CardObject = %NextCard

var current_card: String = "back"
var previous_card: String = "back"
var bet: int = 1
var guess: GUESSES = GUESSES.HIGHER

func _ready() -> void:
	DeckInstance.reset_deck()
	start_game()
	update_state()

func start_game() -> void:
	previous_card = "back"
	current_card = DeckInstance.get_card()

func _input(event: InputEvent) -> void:
	for i in range(5):
		if event.is_action_pressed("hold_%d" % (i + 1)):
			toggle_guess()
			update_state()
			return
	
	if event.is_action_pressed("deal_draw"):
		advance_game_state()
	if event.is_action_pressed("bet"):
		bet = (bet % 5) + 1
		update_state()
	if event.is_action_pressed("add_credit"):
		await get_tree().process_frame
		update_state()
	if event.is_action_pressed("select_game"):
		get_tree().change_scene_to_file("res://main_menu/main_menu.tscn")

func advance_game_state() -> void:
	previous_card = current_card
	current_card = DeckInstance.get_card()
	
	var prev_card_value: int = _card_to_value(previous_card)
	var current_card_value: int = _card_to_value(current_card)
	
	if guess == GUESSES.HIGHER and prev_card_value < current_card_value:
		Credit.add(bet * 2)
	elif guess == GUESSES.LOWER and prev_card_value > current_card_value:
		Credit.add(bet * 2)
	else:
		pass
	
	await get_tree().process_frame
	update_state()

func toggle_guess() -> void:
	if guess == GUESSES.HIGHER:
		guess = GUESSES.LOWER
	else:
		guess = GUESSES.HIGHER

func update_state() -> void:
	previous_card_object.set_card(previous_card)
	current_card_object.set_card(current_card)
	
	%BetLabel.text = "Bet %d" % bet
	%CreditLabel.text = "%d Credits" % Credit.get_credits()
	%PayoutLabel.text = "Payout %d" % (bet * 2)
	
	if guess == GUESSES.HIGHER:
		%HighLabel.show()
		%LowLabel.hide()
	else:
		%HighLabel.hide()
		%LowLabel.show()

func _card_to_value(card: String) -> int:
	if card == "back": return 0
	var rank = card.split("_")[1]
	match rank:
		"A": return 14
		"K": return 13
		"Q": return 12
		"J": return 11
		"10": return 10
		"09": return 9
		"08": return 8
		"07": return 7
		"06": return 6
		"05": return 5
		"04": return 4
		"03": return 3
		"02": return 2
		_: return int(rank) # Fallback

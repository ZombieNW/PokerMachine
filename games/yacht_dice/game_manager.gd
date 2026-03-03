extends Node2D

# Game State
enum GameState { BET, INITIAL_DICE, FINAL_DICE, SCORE, FINAL_SCORE}
var game_state: GameState = GameState.BET
var roll: int = 1

# Betting
const POINT_PAYOUT_RATIO: int = 100
const MAX_BET: int = 5
var bet: int = 1

# Gameplay
@onready var dice_objects: Array[DiceObject] = [%Dice1, %Dice2, %Dice3, %Dice4, %Dice5]
var dice_values: Array[int] = [1, 1, 1, 1, 1]
var held: Array[int] = []

func _ready() -> void:
	%Paper.hide()
	update_state()

func _input(event: InputEvent) -> void:
	# Hold Buttons
	for i in range(dice_objects.size()):
		if event.is_action_pressed("hold_%d" % (i + 1)):
			hold_die(i)
			return
	
	# Action Buttons
	if event.is_action_pressed("select_game"):
		exit_game()
	elif event.is_action_pressed("bet"):
		cycle_bet()
	elif event.is_action_pressed("add_credit"):
		await get_tree().process_frame
		update_state()
	elif event.is_action_pressed("deal_draw"):
		change_game_state()

# Hold given dice
func hold_die(index: int) -> void:
	if game_state != GameState.INITIAL_DICE: return
	
	if index in held:
		held.erase(index)
	else:
		held.append(index)
	held.sort()
	update_state()

# Advance game
func change_game_state() -> void:
	match game_state:
		GameState.BET:
			start_game()
		GameState.INITIAL_DICE:
			middle_turn()
		GameState.FINAL_DICE:
			paper_score()
		GameState.SCORE:
			place_paper_score()
		GameState.FINAL_SCORE:
			close_paper()

# Accept bet and roll first dice
func start_game() -> void:
	if Credit.get_credits() < bet:
		%StateLabel.text = "Insufficient Credits"
		return
	
	%StateLabel.text = ""
	Credit.subtract(bet)
	game_state = GameState.INITIAL_DICE
	roll_dice()
	update_state()

# Middle Turn
func middle_turn() -> void:
	game_state = GameState.FINAL_DICE
	roll_dice()
	update_state()

func paper_score() -> void:
	%Paper.show()
	game_state = GameState.SCORE

func place_paper_score() -> void:
	# Don't score an already scored slot
	if %Paper.user_score[%Paper.selected] != -1:
		return
	
	%Paper.place_score(dice_values)
	
	if %Paper.is_full():
		handle_game_over()
	else:
		# next state
		game_state = GameState.FINAL_SCORE
		%StateLabel.text = "New Dice"

func handle_game_over() -> void:
	game_state = GameState.FINAL_SCORE
	var final_score = %Paper.get_total_score()
	%Paper.hide()
	
	# Payout formula: (Score / 100) * bet
	var payout = (final_score / 100) * bet
	Credit.add(payout)
	
	%StateLabel.text = "SCORE: %d | PAID: %d" % [final_score, payout]

func close_paper() -> void:
	if %Paper.is_full():
		get_tree().reload_current_scene() 
		return

	# reset for next turn
	%Paper.hide()
	held.clear()
	game_state = GameState.INITIAL_DICE
	roll += 1
	%StateLabel.text = "Round %d" % roll
	roll_dice()
	update_state()

func exit_game() -> void:
	if game_state == GameState.BET or game_state == GameState.FINAL_SCORE:
		get_tree().change_scene_to_file("res://main_menu/main_menu.tscn")

func cycle_bet() -> void:
	if game_state == GameState.BET:
		bet = (bet % MAX_BET) + 1
	update_state()

func update_state() -> void:
	%CreditLabel.text = "%d Credits" % Credit.get_credits()
	%BetLabel.text = "Bet %d" % bet
	%PayoutLabel.text = "%d Credits / %d Points" % [bet, POINT_PAYOUT_RATIO]
	
	for dice_idx in dice_objects.size():
		dice_objects[dice_idx].set_held(dice_idx in held)

# Rolls all dice
func roll_dice() -> void:
	for dice_idx in dice_objects.size():
		if dice_idx in held: continue
		dice_objects[dice_idx].roll()
		dice_values[dice_idx] = dice_objects[dice_idx].value
	update_state()

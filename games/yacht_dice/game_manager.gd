extends Node2D

# Game State
enum GameState { BET, INITIAL_DICE, SECOND_DICE, FINAL_DICE, SCORE, FINAL_SCORE}
var game_state: GameState = GameState.BET
var roll: int = 1

# Betting
const MAX_BET: int = 5
var bet: int = 1

# Payout: (score * bet) / POINT_PAYOUT_RATIO
const POINT_PAYOUT_RATIO: int = 100

# Dice
@onready var dice_objects: Array[DiceObject] = [%Dice1, %Dice2, %Dice3, %Dice4, %Dice5]
var dice_values: Array[int] = [1, 1, 1, 1, 1]
var held: Array[int] = []


## Game Cycle
func _ready() -> void:
	%Paper.hide()
	update_state()

func _input(event: InputEvent) -> void:
	# Hold Buttons (1-5 toggle dice during hold state)
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


## State Machine
# Advance game to next state
func change_game_state() -> void:
	match game_state:
		GameState.BET:
			on_bet_confirmed()
		GameState.INITIAL_DICE:
			on_initial_dice_confirmed()
		GameState.SECOND_DICE:
			on_second_dice_confirmed()
		GameState.FINAL_DICE:
			on_final_dice_confirmed()
		GameState.SCORE:
			on_score_placed()
		GameState.FINAL_SCORE:
			on_final_score_confirmed()

# Remove bet from credits and roll dice
func on_bet_confirmed() -> void:
	if Credit.get_credits() < bet:
		%StateLabel.text = "Insufficient Credits"
		# TODO SOUND ERROR HERE
		return

	Credit.subtract(bet)
	game_state = GameState.INITIAL_DICE
	
	roll_dice()
	%StateLabel.text = "Roll 1/3"
	update_state()

# Re-Roll not held dice (first reroll)
func on_initial_dice_confirmed() -> void:
	game_state = GameState.SECOND_DICE
	roll_dice()
	%StateLabel.text = "Roll 2/3"
	update_state()

# Re-Roll not held dice (second reroll)
func on_second_dice_confirmed() -> void:
	game_state = GameState.FINAL_DICE
	roll_dice()
	%StateLabel.text = "Roll 3/3"
	update_state()

func on_final_dice_confirmed() -> void:
	%Paper.show()
	game_state = GameState.SCORE
	# TODO SOUND PAPER HERE

func on_score_placed() -> void:
	# Don't score an already scored slot
	if %Paper.user_score[%Paper.selected] != -1:
		return
	
	%Paper.place_score(dice_values)
	# TODO SOUND PENCIL HERE
	
	if %Paper.is_full():
		handle_game_over()
	else:
		game_state = GameState.FINAL_SCORE
		%StateLabel.text = "New Dice"

func on_final_score_confirmed() -> void:
	if %Paper.is_full():
		# Restart the whole game
		get_tree().reload_current_scene() 
		return

	# Set up the next round
	%Paper.hide()
	held.clear()
	game_state = GameState.INITIAL_DICE
	roll += 1
	%StateLabel.text = "Round %d" % roll
	roll_dice()
	update_state()


## Game Over
func handle_game_over() -> void:
	game_state = GameState.FINAL_SCORE
	var final_score = %Paper.get_total_score()
	%Paper.hide()
	
	var payout := calculate_payout(final_score, bet)
	Credit.add(payout)
	
	%StateLabel.text = "SCORE: %d | PAID: %d" % [final_score, payout]

func calculate_payout(score: int, current_bet: int) -> int:
	return floor((score * current_bet) / float(POINT_PAYOUT_RATIO))

func exit_game() -> void:
	if game_state == GameState.BET or game_state == GameState.FINAL_SCORE:
		get_tree().change_scene_to_file("res://main_menu/main_menu.tscn")


## UI Update
func update_state() -> void:
	%CreditLabel.text = "%d Credits" % Credit.get_credits()
	%BetLabel.text = "Bet %d" % bet
	%PayoutLabel.text = "%d Credits / %d Points" % [bet, POINT_PAYOUT_RATIO]
	
	for dice_idx in dice_objects.size():
		dice_objects[dice_idx].set_held(dice_idx in held)


## Dice & Betting
# Rolls all dice
func roll_dice() -> void:
	# TODO SOUND DICE ROLL HERE
	for dice_idx in dice_objects.size():
		if dice_idx in held: continue
		dice_objects[dice_idx].roll()
		dice_values[dice_idx] = dice_objects[dice_idx].value
	update_state()

# Hold given dice
func hold_die(index: int) -> void:
	# Allow holding during both reroll phases
	if game_state != GameState.INITIAL_DICE and game_state != GameState.SECOND_DICE: return
	
	if index in held:
		held.erase(index)
	else:
		held.append(index)
	held.sort()
	update_state()

# Cycle bet between 1-5
func cycle_bet() -> void:
	if game_state == GameState.BET:
		bet = (bet % MAX_BET) + 1
	update_state()

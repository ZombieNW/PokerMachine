extends Node2D

enum GameState { BET, INITIAL_DICE, FINAL_DICE, SCORE, FINAL_SCORE}

var game_state: GameState = GameState.BET

const MAX_BET: int = 5
var bet: int = 1

@onready var dice_objects: Array[TextureRect] = [%Dice1, %Dice2, %Dice3, %Dice4, %Dice5]
var dice_values: Array[int] = [1, 1, 1, 1, 1]
@onready var hold_labels: Array[Label] = [%Hold1, %Hold2, %Hold3, %Hold4, %Hold5]
@onready var dice_textures: Dictionary[int, Texture] = {
	1: preload("uid://b7rgvjc6e1gi3"),
	2: preload("uid://bpqjqkcalfo0a"),
	3: preload("uid://fvqqgslls8np"),
	4: preload("uid://c4g3vgjoa2d5n"),
	5: preload("uid://cpfi6oqi872ap"),
	6: preload("uid://cg2hbbto2adc2")
}

func _ready() -> void:
	update_state()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("select_game"):
		exit_game()
	elif event.is_action_pressed("bet"):
		cycle_bet()
	elif event.is_action_pressed("add_credit"):
		await get_tree().process_frame
		update_state()
	elif event.is_action_pressed("deal_draw"):
		roll_dice()

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
	for dice_idx in dice_objects.size():
		dice_objects[dice_idx].texture = dice_textures.get(dice_values[dice_idx])

func roll_dice() -> void:
	for dice_idx in dice_objects.size():
		var rand: int = randi_range(1, 6)
		dice_values[dice_idx] = rand
	update_state()

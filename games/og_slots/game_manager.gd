extends Node2D

const SLOT_DELAY_MIN := 0.5
const SLOT_DELAY_RANGE := Vector2(1.0, 2.0)
const MAX_BET: int = 5

var slots: Array[Slot] = []
var results: Array[int] = []
var bet: int = 1

enum GameState { BET, SPINNING, CREDITS }
var game_state: GameState = GameState.BET

@export var cash_sound: AudioStream = preload("uid://bve6cuqxwk7e1")
@export var incorrect_sound: AudioStream = preload("uid://bjte2uqm4lnsb")
@export var jackpot_sound: AudioStream = preload("uid://dft7qa2ln3g0q")

func _ready() -> void:
	initialize_slots()
	update_state()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("deal_draw"):
		advance_game_state()
	elif event.is_action_pressed("bet"):
		cycle_bet()
	elif event.is_action_pressed("add_credit"):
		await get_tree().process_frame
		update_state()
	elif event.is_action_pressed("select_game"):
		exit_game()

func advance_game_state() -> void:
	if game_state == GameState.SPINNING:
		return
	
	if game_state == GameState.BET:
		if Credit.get_credits() < bet:
			%StatusLabel.text = "Insufficient Credits"
			return
	
		%StatusLabel.text = ""
		Credit.subtract(bet)
		update_state()
		spin_slots()

func exit_game() -> void:
	if game_state == GameState.BET or game_state == GameState.CREDITS:
		get_tree().change_scene_to_file("res://main_menu/main_menu.tscn")

func initialize_slots():
	var children = %SlotContainer.get_children()
	results.resize(children.size())
	results.fill(-1)
	
	for i in children.size():
		var slot := children[i] as Slot
		slots.append(slot)
		slot.result_ready.connect(_on_slot_result_ready.bind(i))

func cycle_bet() -> void:
	if game_state == GameState.BET:
		bet = (bet % MAX_BET) + 1
	update_state()

func spin_slots() -> void:
	if game_state == GameState.SPINNING:
		return
	
	game_state = GameState.SPINNING
	results.fill(-1)
	
	
	for i in slots.size():
		var delay := i * SLOT_DELAY_MIN + randf_range(SLOT_DELAY_RANGE.x, SLOT_DELAY_RANGE.y)
		slots[i].spin(delay)
	
	# TODO GUARENTEE ALL THREE ARE STOPPED, PROBABLY VIA A SIGNAL AND MAKING SURE ALL ARE DONE AND PROCESSING FRAMES UNTIL ITS DONE
	# Wait for last slot to stop
	await slots[slots.size() - 1].result_ready
	if results.has(-1): await slots[slots.size() - 2].result_ready
	if results.has(-1): await slots[slots.size() - 3].result_ready
	
	# Print Results
	payout()
	var symbol_names: PackedStringArray = []
	for result in results:
		symbol_names.append(SlotSymbol.get_symbol_name(result))
	print(symbol_names)
	
	game_state = GameState.BET

func update_state() -> void:
	%CreditsLabel.text = "%d Credits" % Credit.get_credits()
	%BetLabel.text = "Bet %d" % bet
	pass

func payout() -> void:
	var payout_amount := SlotSymbol.calculate_payout(results, bet)
	if payout_amount > 0:
		Credit.add(payout_amount)
		Sound.play_sound(cash_sound)
	if payout_amount > 100:
		Sound.play_sound(jackpot_sound)
	if payout_amount == 0:
		Sound.play_sound(incorrect_sound)
	
	update_state()

func _on_slot_result_ready(result: int, slot_index: int) -> void:
	if slot_index < 0 or slot_index >= results.size():
		push_error("Invalid slot index: %d" % slot_index)
		return
	
	results[slot_index] = result

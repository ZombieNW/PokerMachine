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
@export var blip_sound: AudioStream = preload("uid://ll0gsulda8bq")
@export var lever_sound: AudioStream = preload("uid://dymbevwky0s0f")

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
	Sound.play_sound(lever_sound)
	
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
	
	game_state = GameState.BET

func update_state() -> void:
	%CreditsLabel.text = "%d Credits" % Credit.get_credits()
	%BetLabel.text = "Bet %d" % bet
	
	# Price Table Formatting
	var prices_list = []
	var names_list = []
	for entry in SlotSymbol.PRICE_TABLE.values():
		prices_list.append(str(entry[0] * bet))
		names_list.append(entry[1])
	%PriceNames.text = "\n".join(names_list)
	%PricePrices.text = "\n".join(prices_list)

func payout() -> void:
	var payout_object := SlotSymbol.calculate_payout(results, bet)
	var payout_amount: int = payout_object[0]
	if payout_amount > 0:
		Sound.play_sound(cash_sound)
	if payout_amount > 100:
		Sound.play_sound(jackpot_sound)
	if payout_amount == 0:
		Sound.play_sound(incorrect_sound)
	
	for i in range(payout_amount):
		Credit.add(1)
		Sound.play_sound(blip_sound)
		update_state()
		flash_lines(payout_object)
		await get_tree().create_timer(0.1).timeout
	
	update_state()
	flash_lines(payout_object)

func flash_lines(payout_object: Array) -> void:
	if payout_object[0] == 0:
		return
	
	var payout_str:String = str(payout_object[0])
	var payout_name: String = payout_object[1]
	
	var priceNamesLines: Array = %PriceNames.text.split("\n")
	var pricePricesLines: Array = %PricePrices.text.split("\n")
	
	for i in range(priceNamesLines.size()):
		if priceNamesLines[i] == payout_name:
			priceNamesLines[i] = "[color=gold]" + payout_name + "[/color]"
	
	for i in range(pricePricesLines.size()):
		if pricePricesLines[i] == payout_str:
			pricePricesLines[i] = "[color=gold]" + payout_str + "[/color]"
	
	%PriceNames.text = "\n".join(priceNamesLines)
	%PricePrices.text = "\n".join(pricePricesLines)

func _on_slot_result_ready(result: int, slot_index: int) -> void:
	if slot_index < 0 or slot_index >= results.size():
		push_error("Invalid slot index: %d" % slot_index)
		return
	
	results[slot_index] = result

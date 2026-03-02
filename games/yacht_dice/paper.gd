extends TileMapLayer

const CATEGORY_COUNT: int = 12
var selected:int = 0

enum CATEGORIES {
	ONES,
	TWOS,
	THREES,
	FOURS,
	FIVES,
	SIXES,
	THREE_OF_A_KIND,
	FOUR_OF_A_KIND,
	FULL_HOUSE,
	SMALL_STRAIGHT,
	LARGE_STRAIGHT,
	YAHTZEE
}

const SCORE_NAMES: Dictionary[CATEGORIES, String] = {
	CATEGORIES.ONES: "Ones",
	CATEGORIES.TWOS: "Twos",
	CATEGORIES.THREES: "Threes",
	CATEGORIES.FOURS: "Fours",
	CATEGORIES.FIVES: "Fives",
	CATEGORIES.SIXES: "Sixes",
	CATEGORIES.THREE_OF_A_KIND: "3 of a Kind",
	CATEGORIES.FOUR_OF_A_KIND: "4 of a Kind",
	CATEGORIES.FULL_HOUSE: "Full House",
	CATEGORIES.SMALL_STRAIGHT: "Small Straight",
	CATEGORIES.LARGE_STRAIGHT: "Large Straight",
	CATEGORIES.YAHTZEE: "Yacht"
}

var user_score: Dictionary[CATEGORIES, int] = {
	CATEGORIES.ONES: -1,
	CATEGORIES.TWOS: -1,
	CATEGORIES.THREES: -1,
	CATEGORIES.FOURS: -1,
	CATEGORIES.FIVES: -1,
	CATEGORIES.SIXES: -1,
	CATEGORIES.THREE_OF_A_KIND: -1,
	CATEGORIES.FOUR_OF_A_KIND: -1,
	CATEGORIES.FULL_HOUSE: -1,
	CATEGORIES.SMALL_STRAIGHT: -1,
	CATEGORIES.LARGE_STRAIGHT: -1,
	CATEGORIES.YAHTZEE: -1
}

@onready var highlight_bar = $Highlight

func _ready() -> void:
	update_state()

func _input(event: InputEvent) -> void:
	# Hold Buttons to Select
	if visible == false: return
	for i in range(5):
		if event.is_action_pressed("hold_%d" % (i + 1)):
			select()
			return

func select() -> void:
	# find next available slot
	for i in range(CATEGORY_COUNT):
		selected = (selected + 1) % CATEGORY_COUNT
		if user_score[selected as CATEGORIES] == -1:
			break
	update_state()

func place_score(dice: Array[int]):
	var category = selected as CATEGORIES
	user_score[category] = calculate_score(category, dice)
	update_state()

func calculate_score(category: CATEGORIES, dice: Array[int]):
	var counts = get_dice_counts(dice)
	var dice_sum = 0
	for d in dice:
		dice_sum += d
	
	match category:
		# sum based categories
		CATEGORIES.ONES, CATEGORIES.TWOS, CATEGORIES.THREES, \
		CATEGORIES.FOURS, CATEGORIES.FIVES, CATEGORIES.SIXES:
			var target_value = category + 1 # Enum 0 = Ones, so +1
			return counts.get(target_value, 0) * target_value

		# pattern based categories
		CATEGORIES.THREE_OF_A_KIND:
			return dice_sum if counts.values().max() >= 3 else 0
			
		CATEGORIES.FOUR_OF_A_KIND:
			return dice_sum if counts.values().max() >= 4 else 0
			
		CATEGORIES.FULL_HOUSE:
			var has_3 = counts.values().has(3)
			var has_2 = counts.values().has(2)
			var has_5 = counts.values().has(5) # 5 of a kind also counts as full house
			return 25 if (has_3 and has_2) or has_5 else 0
			
		CATEGORIES.SMALL_STRAIGHT:
			return 30 if is_straight(dice, 4) else 0
			
		CATEGORIES.LARGE_STRAIGHT:
			return 40 if is_straight(dice, 5) else 0
			
		CATEGORIES.YAHTZEE:
			return 50 if counts.values().max() == 5 else 0
			
	return 0

func update_state() -> void:
	highlight_bar.position.y = 30 + (selected * 10)
	
	$ScoreLabel.text = "\n"
	var total_sum: int = 0
	var upper_sum: int = 0
	
	# iterate throgh categories
	for i in range(CATEGORY_COUNT):
		var category = i as CATEGORIES
		var score_value = user_score[category]
		
		if score_value == -1:
			# score not filled out yet
			$ScoreLabel.text += "[ ]\n"
		else:
			total_sum += score_value
			$ScoreLabel.text += "%d\n" % score_value
			
			# add upper category for bonus
			if i <= CATEGORIES.SIXES:
				upper_sum += score_value
	
	# 63 is the magic bonus number
	var bonus: int = 35 if upper_sum >= 63 else 0
	total_sum += bonus
	
	# indicate bonus
	if bonus > 0:
		$ScoreLabel.text += "\nBonus: %d" % bonus
	else:
		$ScoreLabel.text += "\n"
		
	$ScoreLabel.text += "Total: %d" % total_sum

func get_dice_counts(dice: Array[int]) -> Dictionary:
	var counts = {}
	for die in dice:
		counts[die] = counts.get(die, 0) + 1
	return counts
	
func is_straight(dice: Array[int], required_length: int) -> bool:
	# stringify is so we can compare it easier
	var unique_dice = []
	for d in dice:
		if not d in unique_dice:
			unique_dice.append(d)
	unique_dice.sort()
	
	var sequence_string = ""
	for d in unique_dice:
		sequence_string += str(d)
	
	# large straight patterns
	if required_length == 5:
		return sequence_string == "12345" or sequence_string == "23456"
	# small straight patterns
	else:
		return "1234" in sequence_string or "2345" in sequence_string or "3456" in sequence_string

# if every slot filled
func is_full() -> bool:
	for category in user_score:
		if user_score[category] == -1:
			return false
	return true

# score including bonus
func get_total_score() -> int:
	var total: int = 0
	var upper_sum: int = 0
	
	for i in range(CATEGORY_COUNT):
		var val = user_score[i as CATEGORIES]
		if val != -1:
			total += val
			# sum upper
			if i <= CATEGORIES.SIXES:
				upper_sum += val
	
	# add bonus, 63 magic number
	if upper_sum >= 63:
		total += 35
		
	return total

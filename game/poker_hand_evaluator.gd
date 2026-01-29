class_name PokerHandEvaluator

enum HandRank {
	HIGH_CARD,
	BAD_PAIR,
	PAIR,
	TWO_PAIR,
	THREE_OF_A_KIND,
	STRAIGHT,
	FLUSH,
	FULL_HOUSE,
	FOUR_OF_A_KIND,
	STRAIGHT_FLUSH,
	ROYAL_FLUSH
}

const PAYOUT_TABLE = {
	HandRank.ROYAL_FLUSH:     [250, 500, 750, 1000, 4000],
	HandRank.STRAIGHT_FLUSH:  [50, 100, 150, 200, 250],
	HandRank.FOUR_OF_A_KIND:  [25, 50, 75, 100, 125],
	HandRank.FULL_HOUSE:      [9, 18, 27, 36, 45],
	HandRank.FLUSH:           [6, 12, 18, 24, 30],
	HandRank.STRAIGHT:        [4, 8, 12, 16, 20],
	HandRank.THREE_OF_A_KIND: [3, 6, 9, 12, 15],
	HandRank.TWO_PAIR:        [2, 4, 6, 8, 10],
	HandRank.PAIR:            [1, 2, 3, 4, 5], # "Jacks or Better"
	HandRank.BAD_PAIR:        [0, 0, 0, 0, 0], # Normal Pair
	HandRank.HIGH_CARD:       [0, 0, 0, 0, 0]
}

static func get_payout(hand_result: HandRank, bet: int) -> int:
	# Ensure hand exists
	if not PAYOUT_TABLE.has(hand_result):
		return 0
	
	# Clamp to array index
	var column_index = clampi(bet - 1, 0, 4)
	
	return PAYOUT_TABLE[hand_result][column_index]

static func evaluate_hand(cards: Array[String]) -> Dictionary:
	var suits = []
	var ranks = []
	var rank_values = []
	var rank_counts = {}
	
	# Sort cards
	for card in cards:
		var parts = card.split("_")
		suits.append(parts[0])
		ranks.append(parts[1])
		
		var rank_value = _rank_to_value(parts[1])
		rank_values.append(rank_value)
		rank_counts[rank_value] = rank_counts.get(rank_value, 0) + 1
	rank_values.sort()
	
	# Check for flush
	var is_flush = _is_flush(suits)
	
	# Check for straight
	var is_straight = _is_straight(rank_values)
	
	# Get the hand rank
	var hand_rank = _determine_hand_rank(rank_counts, is_flush, is_straight, rank_values)
	
	return {
		"rank": hand_rank,
		"name": _get_hand_name(hand_rank)
	}

static func _determine_hand_rank(rank_counts: Dictionary, is_flush: bool, is_straight: bool, rank_values: Array) -> HandRank:
	var counts = rank_counts.values()
	counts.sort()
	counts.reverse()
	
	# Royal Flush & Straight Flush
	if is_flush and is_straight:
		if _is_royal_flush(rank_values):
			return HandRank.ROYAL_FLUSH
		return HandRank.STRAIGHT_FLUSH
	
	# 4 of a Kind
	if counts[0] == 4:
		return HandRank.FOUR_OF_A_KIND
	
	# Full House
	if counts[0] == 3 and counts[1] == 2:
		return HandRank.FULL_HOUSE
	
	# Flush
	if is_flush:
		return HandRank.FLUSH
	
	# Straight
	if is_straight:
		return HandRank.STRAIGHT
	
	# 3 of a Kind
	if counts[0] == 3:
		return HandRank.THREE_OF_A_KIND
	
	# 2 Pair
	if counts[0] == 2 and counts[1] == 2:
		return HandRank.TWO_PAIR
	
	# Pair
	if counts[0] == 2:
		if _get_value_from_count_and_values(counts[0], rank_values) < 11:
			return HandRank.BAD_PAIR # Normal Pair
		return HandRank.PAIR # "Jacks or Better"
	
	return HandRank.HIGH_CARD

static func _get_value_from_count_and_values(target_count, values) -> int:
	var counts = {}
	
	for value in values:
		if counts.has(value):
			counts[value] += 1
		else:
			counts[value] = 1
	
	for value in counts:
		if counts[value] == target_count:
			return value
	
	return -1

static func _get_hand_name(rank: HandRank) -> String:
	match rank:
		HandRank.ROYAL_FLUSH: return "Royal Flush"
		HandRank.STRAIGHT_FLUSH: return "Straight Flush"
		HandRank.FOUR_OF_A_KIND: return "Four of a Kind"
		HandRank.FULL_HOUSE: return "Full House"
		HandRank.FLUSH: return "Flush"
		HandRank.STRAIGHT: return "Straight"
		HandRank.THREE_OF_A_KIND: return "Three of a Kind"
		HandRank.TWO_PAIR: return "Two Pair"
		HandRank.PAIR: return "Jacks or Better"
		HandRank.BAD_PAIR: return "Pair"
		HandRank.HIGH_CARD: return "High Card"
		_: return "Unknown"

static func _is_flush(suits: Array) -> bool:
	var first_suit = suits[0]
	for suit in suits:
		if suit != first_suit:
			return false
	return true

static func _is_straight(rank_values: Array) -> bool:
	for i in range(4):
		if rank_values[i + 1] - rank_values[i] != 1:
			# Check for a straight with an Ace
			if rank_values == [2, 3, 4, 5, 14]:
				return true
			return false
	return true

static func _is_royal_flush(rank_values: Array) -> bool:
	return rank_values == [10, 11, 12, 13, 14]

static func _rank_to_value(rank: String) -> int:
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

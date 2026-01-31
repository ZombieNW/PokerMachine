extends Node

class_name SlotSymbol

enum Type {
	COCONUT,
	SEVEN,
	BELL,
	CHERRY,
	ORANGE,
	PEAR,
	MELON,
	BAR
}

const fruits = [Type.COCONUT, Type.CHERRY, Type.ORANGE, Type.PEAR, Type.MELON]

static func calculate_payout(results: Array, bet_amount: int) -> int:
	var payout = 0
	# Jackpot
	if results[0] == results[1] and results[1] == results[2] and results[0]== Type.SEVEN:
		payout = 100
	# 3-of-a-Kind
	elif results[0] == results[1] and results[1] == results[2]:
		payout = 20
	# Fruit Salad
	elif results.all(func(s): return s in fruits):
		payout = 5
	
	# Cherries
	payout += results.count(Type.CHERRY) * 1
	
	return payout * bet_amount

static func get_symbol_name(symbol_type: int) -> String:
	match symbol_type:
		Type.COCONUT: return "Coconut"
		Type.SEVEN: return "Seven"
		Type.BELL: return "Bell"
		Type.CHERRY: return "Cherry"
		Type.ORANGE: return "Orange"
		Type.PEAR: return "Pear"
		Type.MELON: return "Melon"
		Type.BAR: return "Bar"
		_: return "Unknown"

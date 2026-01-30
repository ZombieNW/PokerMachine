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

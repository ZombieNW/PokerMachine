extends Node

var deck = [
	"hearts_A",
	"hearts_02",
	"hearts_03",
	"hearts_04",
	"hearts_05",
	"hearts_06",
	"hearts_07",
	"hearts_08",
	"hearts_09",
	"hearts_10",
	"hearts_J",
	"hearts_Q",
	"hearts_K",
	"diamonds_A",
	"diamonds_02",
	"diamonds_03",
	"diamonds_04",
	"diamonds_05",
	"diamonds_06",
	"diamonds_07",
	"diamonds_08",
	"diamonds_09",
	"diamonds_10",
	"diamonds_J",
	"diamonds_Q",
	"diamonds_K",
	"clubs_A",
	"clubs_02",
	"clubs_03",
	"clubs_04",
	"clubs_05",
	"clubs_06",
	"clubs_07",
	"clubs_08",
	"clubs_09",
	"clubs_10",
	"clubs_J",
	"clubs_Q",
	"clubs_K",
	"spades_A",
	"spades_02",
	"spades_03",
	"spades_04",
	"spades_05",
	"spades_06",
	"spades_07",
	"spades_08",
	"spades_09",
	"spades_10",
	"spades_J",
	"spades_Q",
	"spades_K"
]

func get_card() -> String:
	var random_index = randi_range(0, deck.size() - 1)
	return deck.pop_at(random_index)

func return_card(card_name: String) -> void:
	deck.append(card_name)

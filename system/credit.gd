extends Node

var add_credit_sound: AudioStream = preload("uid://inoi7xbmbyxh")

var credits: int = 0

func get_credits() -> int:
	return credits

func set_to(number: int) -> void:
	credits = number

func add(number: int) -> void:
	credits += number

func coin_inserted() -> void:
	add(1)
	Sound.play_sound(add_credit_sound)

func subtract(number: int) -> void:
	credits -= number

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("add_credit"):
		coin_inserted()

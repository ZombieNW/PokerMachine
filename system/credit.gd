extends Node

var credits: int = 0

func get_credits() -> int:
	return credits

func set_to(number: int) -> void:
	credits = number

func add(number: int) -> void:
	credits += number

func subtract(number: int) -> void:
	credits -= number

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("add_credit"):
		add(1)

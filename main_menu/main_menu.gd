extends Node2D

var game_icons: Array[GameIcon] = []
var selected_icon = 0;


# Program Start
func _ready() -> void:
	for node in %GridContainer.get_children():
		game_icons.append(node as GameIcon)
	update_state()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("select_game"):
		selected_icon = ((selected_icon + 1) % game_icons.size()) 
		update_state()
	elif event.is_action_pressed("deal_draw"):
		game_icons[selected_icon].run_game()
	elif event.is_action_pressed("add_credit"):
		await get_tree().process_frame
		update_state()

func update_state() -> void:
	%CreditsLabel.text = "%d Credits - © Zach Runnels 2026" % Credit.get_credits()
	for game_icon in game_icons:
			if game_icon == game_icons[selected_icon]:
				game_icon.select()
			else:
				game_icon.unselect()

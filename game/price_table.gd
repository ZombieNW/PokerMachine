extends GridContainer

const RED_PANEL: StyleBox = preload("uid://cd7dbc2w6wypx")
const BLUE_PANEL: StyleBox = preload("uid://bl6tb0bieynlp")


@onready var panels: Array[Panel] = [
	$CreditPanel1,
	$CreditPanel2,
	$CreditPanel3,
	$CreditPanel4,
	$CreditPanel5
]

func set_price_panel(active_index: int) -> void:
	for i in panels.size():
		var target_panel = panels[i]
		
		if i == active_index:
			target_panel.add_theme_stylebox_override("panel", RED_PANEL)
		else:
			target_panel.add_theme_stylebox_override("panel", BLUE_PANEL)
	

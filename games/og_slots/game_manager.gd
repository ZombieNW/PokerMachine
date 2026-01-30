extends Node2D

var slots: Array[Slot] = []
var all_results: Array[int] = []
var is_spinning: bool = false

func _ready() -> void:
	all_results.resize(%SlotContainer.get_child_count())
	
	var children = %SlotContainer.get_children()
	for i in children.size():
		var slot = (children[i] as Slot)
		slots.append(slot)
		slot.result_ready.connect(_handle_slot_result.bind(i))

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("deal_draw") and not is_spinning:
		spin_slots()

func spin_slots() -> void:
	is_spinning = true
	
	for i in slots.size():
		var delay = i * 0.5 + randf_range(1.0, 2.0)
		slots[i].spin(delay)
	
	await slots[slots.size() - 1].result_ready
	
	var results_human_readable = []
	for val in all_results:
		results_human_readable.append(symbol_num_to_name(val))
	
	print("Final Results: ", results_human_readable)
	is_spinning = false

func _handle_slot_result(result: int, index:int) -> void:
	all_results[index] = result

func symbol_num_to_name(symbol_num: int) -> String:
	match symbol_num:
		0:
			return "Coconut"
		1:
			return "Seven"
		2:
			return "Bell"
		3:
			return "Cherry"
		4:
			return "Orange"
		5:
			return "Pear"
		6:
			return "Melon"
		7:
			return "Bar"
		_:
			return ""

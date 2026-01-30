extends Node2D

const SLOT_DELAY_MIN := 0.5
const SLOT_DELAY_RANGE := Vector2(1.0, 2.0)

var slots: Array[Slot] = []
var results: Array[int] = []
var is_spinning: bool = false

func _ready() -> void:
	initialize_slots()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("deal_draw") and not is_spinning:
		spin_slots()

func initialize_slots():
	var children = %SlotContainer.get_children()
	results.resize(children.size())
	results.fill(-1)
	
	for i in children.size():
		var slot := children[i] as Slot
		slots.append(slot)
		slot.result_ready.connect(_on_slot_result_ready.bind(i))

func spin_slots() -> void:
	if is_spinning:
		return
	
	is_spinning = true
	results.fill(-1)
	
	for i in slots.size():
		var delay := i * SLOT_DELAY_MIN + randf_range(SLOT_DELAY_RANGE.x, SLOT_DELAY_RANGE.y)
		slots[i].spin(delay)
	
	# TODO GUARENTEE ALL THREE ARE STOPPED, PROBABLY VIA A SIGNAL AND MAKING SURE ALL ARE DONE AND PROCESSING FRAMES UNTIL ITS DONE
	# Wait for last slot to stop
	await slots[slots.size() - 1].result_ready
	
	# Print Results
	var symbol_names: PackedStringArray = []
	for result in results:
		symbol_names.append(SlotSymbol.get_symbol_name(result))
	print(symbol_names)
	
	is_spinning = false

func _on_slot_result_ready(result: int, slot_index: int) -> void:
	if slot_index < 0 or slot_index >= results.size():
		push_error("Invalid slot index: %d" % slot_index)
		return
	
	results[slot_index] = result

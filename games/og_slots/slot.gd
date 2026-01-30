extends Node2D
class_name Slot

signal result_ready(result: int)

const TILE_SIZE := 24
const SYMBOL_COUNT := 8
const MAP_HEIGHT := TILE_SIZE * SYMBOL_COUNT
const MAX_SPEED := 1000
const FRICTION := 0.99

enum State { STOPPED, SPINNING, STOPPING, SNAPPING }
var slot_state: State = State.STOPPED

var current_speed: float = 0.0

@onready var map_1: TileMapLayer = $Fruits1
@onready var map_2: TileMapLayer = $Fruits2

func _ready() -> void:
	map_1.position.y = 0
	map_2.position.y = -MAP_HEIGHT

func _process(delta) -> void:
	if slot_state == State.SPINNING or slot_state == State.STOPPING:
		if slot_state == State.STOPPING:
			current_speed *= FRICTION
			if current_speed < 10:
				slot_state = State.SNAPPING
				stop_spin()
		
		if slot_state != State.SNAPPING:
			move_maps(current_speed * delta)

func spin(stop_time: float = 1.0) -> int:
	slot_state = State.SPINNING
	current_speed = MAX_SPEED
	
	await get_tree().create_timer(stop_time).timeout
	
	slot_state = State.STOPPING
	
	# Wait until slots stopped
	while slot_state != State.STOPPED:
		await get_tree().process_frame
	
	return get_winning_index()

func move_maps(amount) -> void:
	map_1.position.y = fmod(map_1.position.y + amount, MAP_HEIGHT)
	map_2.position.y = map_1.position.y - MAP_HEIGHT

func get_winning_index() -> int:
	var raw_idx = int(round(map_1.position.y / TILE_SIZE))
	var winning_index = (SYMBOL_COUNT - raw_idx) % SYMBOL_COUNT
	result_ready.emit(winning_index)
	return winning_index

func stop_spin() -> void:
	slot_state = State.SNAPPING
	
	var target_y = round(map_1.position.y / TILE_SIZE) * TILE_SIZE
	
	# TWEEN THE BITCH
	var current_tween = create_tween()
	current_tween.set_trans(Tween.TRANS_BACK)
	current_tween.set_ease(Tween.EASE_OUT)
	current_tween.tween_property(map_1, "position:y", target_y, 0.5)
	current_tween.parallel().tween_property(map_2, "position:y", target_y - MAP_HEIGHT, 0.5)
	await current_tween.finished
	
	current_tween = null
	slot_state = State.STOPPED

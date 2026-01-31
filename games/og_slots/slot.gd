extends Node2D
class_name Slot

signal result_ready(result: int)
signal stopped

const TILE_SIZE := 24
const SYMBOL_COUNT := 8
const MAP_HEIGHT := TILE_SIZE * SYMBOL_COUNT
const MAX_SPEED := 1000
const FRICTION := 0.99
const MIN_SPEED_THRESHOLD := 10.0
const SNAP_DURATION := 0.5

enum State { IDLE, SPINNING, DECELERATING, SNAPPING }

var state: State = State.IDLE
var current_speed: float = 0.0
var snap_tween: Tween = null
var last_tile_position: int = 0

@export var click_sound: AudioStream = preload("uid://ll0gsulda8bq")

@onready var map_1: TileMapLayer = $Fruits1
@onready var map_2: TileMapLayer = $Fruits2

func _ready() -> void:
	init_map_positions()

func _process(delta) -> void:
	match state:
		State.SPINNING, State.DECELERATING:
			update_spinning(delta)

# Actually spin the thing
func spin(stop_time: float = 1.0) -> void:
	if state != State.IDLE:
		return
	
	start_spinning()
	await get_tree().create_timer(stop_time).timeout
	begin_deceleration()
	
	await stopped

# Move maps and stop when told to slow down
func update_spinning(delta: float) -> void:
	if state == State.DECELERATING:
		current_speed *= FRICTION
		
		if current_speed < MIN_SPEED_THRESHOLD:
			snap_to_position()
			return
	
	move_maps(current_speed * delta)

# Move maps on the y-axis
func move_maps(amount) -> void:
	map_1.position.y = fmod(map_1.position.y + amount, MAP_HEIGHT)
	map_2.position.y = map_1.position.y - MAP_HEIGHT
	
	var current_tile_position = int(floor(map_1.position.y / TILE_SIZE))
	
	if current_tile_position != last_tile_position:
		Sound.play_sound(click_sound, 0.25)
		last_tile_position = current_tile_position

# Tween to closest symbol
func snap_to_position() -> void:
	state = State.SNAPPING
	current_speed = 0.0
	
	var target_y: int = round(map_1.position.y / TILE_SIZE) * TILE_SIZE
	
	# Clean up any existing tween
	if snap_tween and snap_tween.is_valid():
		snap_tween.kill()
	
	Sound.play_sound(click_sound, 1)
	
	# TWEEN THE BITCH
	snap_tween = create_tween()
	snap_tween.set_trans(Tween.TRANS_BACK)
	snap_tween.set_ease(Tween.EASE_OUT)
	snap_tween.tween_property(map_1, "position:y", target_y, SNAP_DURATION)
	snap_tween.parallel().tween_property(map_2, "position:y", target_y - MAP_HEIGHT, SNAP_DURATION)
	await snap_tween.finished
	snap_tween = null
	
	finalize_spin()

# Get winning index and send signals
func finalize_spin() -> void:
	var winning_index := calculate_winning_index()
	
	state = State.IDLE
	result_ready.emit(winning_index)
	stopped.emit()

# Helper function to get index of symbol in middle
func calculate_winning_index() -> int:
	var raw_index := int(round(map_1.position.y / TILE_SIZE))
	return (SYMBOL_COUNT - raw_index) % SYMBOL_COUNT

# Set map positions to the beginning
func init_map_positions() -> void:
	map_1.position.y = 0
	map_2.position.y = -MAP_HEIGHT

# Start spinning
func start_spinning() -> void:
	state = State.SPINNING
	current_speed = MAX_SPEED

# Start Slowing down
func begin_deceleration() -> void:
	if state == State.SPINNING:
		state = State.DECELERATING

# Clean up our mess when we're done
func _exit_tree() -> void:
	if snap_tween and snap_tween.is_valid():
		snap_tween.kill()

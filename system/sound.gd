extends Node

func play_sound(sound: AudioStream, volume: float = 1.0) -> void:
	if not sound:
		push_warning("Invalid AudioStream")
		return

	var player := AudioStreamPlayer.new()
	add_child(player)
	
	player.volume_linear = volume
	player.stream = sound
	player.finished.connect(player.queue_free)
	player.play()

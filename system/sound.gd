extends Node

func play_sound(sound: AudioStream) -> void:
	if not sound:
		push_warning("Invalid AudioStream")
		return

	var player := AudioStreamPlayer.new()
	add_child(player)
	
	player.stream = sound
	player.finished.connect(player.queue_free)
	player.play()

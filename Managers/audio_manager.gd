extends Node

func play_audio(audio_stream: AudioStream):
	var audio_stream_player: AudioStreamPlayer = AudioStreamPlayer.new()
	audio_stream_player.stream = audio_stream
	audio_stream_player.finished.connect(
		_on_finished.bind(audio_stream_player)
	)
	add_child(audio_stream_player)
	audio_stream_player.play()

func _on_finished(audio_stream_player: AudioStreamPlayer):
	audio_stream_player.queue_free()

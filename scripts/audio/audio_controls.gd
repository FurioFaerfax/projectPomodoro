extends HBoxContainer
@onready var start: Button = %audioStart
@onready var pause: Button = %audioPause
@onready var stop: Button = %audioStop
@onready var skip: Button = %audioSkip
@onready var timer: Timer = %audioTimer
@onready var audio: AudioStreamPlayer = %MusicStreamPlayer
@onready var audio_visuals: Control = %audio_visuals
@onready var audio_progress_bar: TextureProgressBar = %audio_progress_bar

var paused := false

func _on_start_pressed() -> void:
	if paused:
		audio.startTimerStop(true, false)
		audio.stream_paused = false
		paused = false
	else:
		audio.startTimerStop(true, false)
		audio.play()
	start.hide()
	pause.show()
	
	if timer.is_stopped():
		if !paused:
			pass
		else:
			timer.start()

#Curently resets the current round
func _on_stop_pressed() -> void:
	audio.stop()
	start.show()
	pause.hide()
	audio.startTimerStop(false, true)
	if paused:
		paused = false

func _on_pause_pressed() -> void:
	start.show()
	pause.hide()
	paused = true
	audio.stream_paused = true
	audio.startTimerStop(false, false)
	#timer.stop()

func _on_skip_pressed() -> void:#Currently no sound when skipping
	_on_stop_pressed()
	audio.startTimerStop(true, true)
	audio.get_next_track()
	audio.play()
	start.hide()
	pause.show()

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
	start.hide()
	pause.show()
	if !paused:
		audio.stop()
		match timer.state:
			timer.STATES.WORK:
				audio.set_sound("work_start")
			timer.STATES.MINI_BREAK:
				audio.set_sound("break_start")
			timer.STATES.MAIN_BREAK:
				audio.set_sound("break_start")
			_:
				pass
		audio.play(0.0)
	
	if timer.is_stopped():
		if !paused:
			timer.setting_up_timer(true)
		else:
			timer.start()

#Curently resets the current round
func _on_stop_pressed() -> void:
	start.show()
	pause.hide()
	if paused:
		paused = false
	timer.stop()
	timer.time_in_seconds_left = timer.time_in_seconds
	audio_visuals.update_visuals()
	audio_progress_bar.value = audio_progress_bar.max_value

func _on_pause_pressed() -> void:
	start.show()
	pause.hide()
	paused = true
	timer.stop()

func _on_skip_pressed() -> void:#Currently no sound when skipping
	_on_stop_pressed()
	if timer.autoplay:
		start.hide()
		pause.show()
	
	timer.choose_next_time()

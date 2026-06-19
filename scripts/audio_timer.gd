extends Timer

@onready var progress_bar: TextureProgressBar = %audio_progress_bar
@onready var audio_visuals: Control = %audio_visuals
@onready var audio: AudioStreamPlayer = %MusicStreamPlayer
@onready var btn_start: Button = %audioStart
@onready var pause: Button = %audioPause

@export var working_time := 25
@export var mini_break_time := 5
@export var main_break_time := 20

enum STATES {
	IDLE,
	PLAY,
	PAUSE,
	STOPPED,
}

var hours := 0
var minutes := 0
var seconds := 0

var timer_step := 1
var time_in_minutes: int = 1
var time_in_seconds :int = 0
var time_in_seconds_left := time_in_seconds
var time_counting :int = 0

var state: STATES = STATES.IDLE

var max_rounds := 4
var _round := 1
var cycle := 1

var autoplay := false


func _on_timeout() -> void:
	pass # Replace with function body.
